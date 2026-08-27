const { ImapFlow } = require('imapflow');
const { simpleParser } = require('mailparser');
const db = require('./db');

async function processUnreadEmails() {
  if (!process.env.EMAIL_APP_PASSWORD) {
     console.log('Skipping email check: EMAIL_APP_PASSWORD not set.');
     return;
  }
  
  const client = new ImapFlow({
    host: 'imap.gmail.com',
    port: 993,
    secure: true,
    auth: {
      user: 'hackbuddy.verify@gmail.com',
      pass: process.env.EMAIL_APP_PASSWORD
    },
    logger: false
  });
  
  await client.connect();
  const lock = await client.getMailboxLock('INBOX');
  try {
    // 1. Fetch all unread messages into memory first
    // We cannot run mutating commands (like marking as read) while the fetch stream is open!
    const messages = [];
    for await (const msg of client.fetch({ seen: false }, { source: true, uid: true })) {
      messages.push({ uid: msg.uid, source: msg.source });
    }

    // 2. Process them sequentially
    for (const msg of messages) {
      const parsed = await simpleParser(msg.source);
      
      const studentEmail = parsed.from?.value[0]?.address || 'Unknown';
      const subject = parsed.subject || 'No Subject';
      const bodyText = parsed.text || '';

      // Skip internal system emails or non-forwarded emails
      const subj = subject.toLowerCase();
      if (!subj.startsWith('fwd:') && !subj.startsWith('fw:') && !subj.includes('forwarded')) {
        console.log(`⏭️ [SKIPPED] Non-forwarded email from: ${studentEmail} (Subject: ${subject})`);
        await client.messageFlagsAdd({ uid: msg.uid }, ['\\Seen'], { uid: true });
        continue;
      }

      console.log(`📬 [NEW FORWARD DETECTED] From: ${studentEmail}`);
      console.log(`Subject: ${subject}`);

      await verifyProofWithAI({
        forwardedBy: studentEmail,
        subject: subject,
        body: bodyText,
        date: parsed.date,
        uid: msg.uid
      });
      
      await client.messageFlagsAdd({ uid: msg.uid }, ['\\Seen'], { uid: true });
    }
  } catch (err) {
    console.error('Error parsing mailbox:', err);
  } finally {
    if (lock) lock.release();
    await client.logout();
  }
}

async function verifyProofWithAI({ forwardedBy, subject, body, uid }) {
  console.log('🤖 Sending parsed text to Hugging Face Qwen 2.5 for validation...');

  const prompt = `
You are a proof verification system. Analyze this forwarded confirmation email:
STUDENT SENDER: ${forwardedBy}
SUBJECT: ${subject}
BODY:
${body}

Extract the following JSON strictly:
{
  "is_valid_hackathon_proof": true/false,
  "hackathon_title": "string or null",
  "original_sender": "string (e.g., Unstop, Devfolio, MLH, IQOO) or null",
  "rejection_reason": "string or null"
}
`;

  try {
    const token = process.env.Qwen_3b || process.env.HF_TOKEN;
    if (!token) throw new Error('HF_TOKEN missing');

    const response = await fetch('https://router.huggingface.co/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        model: "Qwen/Qwen2.5-72B-Instruct",
        messages: [{ role: 'user', content: prompt }],
        max_tokens: 500
      })
    });

    if (!response.ok) {
        throw new Error('HF API error: ' + await response.text());
    }

    const data = await response.json();
    let resultText = data.choices[0].message.content;
    
    // Clean up potential markdown formatting from Qwen
    resultText = resultText.replace(/```json/g, '').replace(/```/g, '').trim();
    const result = JSON.parse(resultText);

    console.log('✅ AI Decision:', result);

    // 1. Always try to identify the user first
    let userId = null;
    const userRes = await db.query('SELECT id FROM users WHERE email = $1', [forwardedBy]);
    if (userRes.rowCount > 0) {
      userId = userRes.rows[0].id;
    } else {
      console.log(`User ${forwardedBy} not found in database.`);
    }

    let matchedHackathonId = null;

    if (result.is_valid_hackathon_proof && userId) {
      // Find pending teams for this user
      const teamsRes = await db.query(`
        SELECT tm.team_id, h.title as hackathon_title, h.id as hackathon_id
        FROM team_members tm
        JOIN teams t ON tm.team_id = t.id
        JOIN hackathons h ON t.hackathon_id = h.id
        WHERE tm.user_id = $1 AND (tm.proof_url IS NULL OR tm.proof_url = '')
      `, [userId]);

      let matchedTeamId = null;
      for (const row of teamsRes.rows) {
        // Simple case-insensitive include match
        if (result.hackathon_title && row.hackathon_title.toLowerCase().includes(result.hackathon_title.toLowerCase())) {
           matchedTeamId = row.team_id;
           matchedHackathonId = row.hackathon_id;
           break;
        }
      }
      
      // If we couldn't match exactly by title but they only have one pending team, we can assume it's that one.
      if (!matchedTeamId && teamsRes.rowCount === 1) {
          matchedTeamId = teamsRes.rows[0].team_id;
          matchedHackathonId = teamsRes.rows[0].hackathon_id;
      }

      if (matchedTeamId) {
        const proofUrl = 'email_verified'; 
        
        await db.query(
          'UPDATE team_members SET proof_url = $1 WHERE team_id = $2 AND user_id = $3',
          [proofUrl, matchedTeamId, userId]
        );
        
        // Check if all accepted members have uploaded proof
        const members = await db.query('SELECT proof_url, invite_status FROM team_members WHERE team_id = $1', [matchedTeamId]);
        const allAcceptedHaveProof = members.rows
          .filter(m => m.invite_status === 'accepted')
          .every(m => m.proof_url !== null && m.proof_url !== '');
          
        if (allAcceptedHaveProof) {
          await db.query("UPDATE teams SET status = 'registered' WHERE id = $1", [matchedTeamId]);
          console.log(`Team ${matchedTeamId} marked as registered!`);
        }
        
        console.log(`Successfully verified proof for user ${userId} in team ${matchedTeamId}.`);
      } else {
         console.log(`Could not match hackathon title '${result.hackathon_title}' to any pending teams for user ${userId}.`);
      }
    } else if (!result.is_valid_hackathon_proof) {
        console.log(`Proof rejected for ${forwardedBy}: ${result.rejection_reason}`);
    }

    // 2. ALWAYS LOG TO SUBMISSIONS TABLE for the Admin Portal
    // We use the email Subject as a pseudo "proof_url" or identifier for email forwards
    const finalStatus = result.is_valid_hackathon_proof ? 'verified' : 'rejected';
    const finalFeedback = result.is_valid_hackathon_proof ? 'Auto-approved via Email Forward' : (result.rejection_reason || 'Rejected by AI');
    
    await db.query(`
      INSERT INTO submissions (hackathon_id, user_id, proof_url, ai_status, ai_feedback, ai_confidence) 
      VALUES ($1, $2, $3, $4, $5, $6)
    `, [
      matchedHackathonId, 
      userId, 
      `(Email Forward) ${subject}`, 
      finalStatus, 
      finalFeedback, 
      0.95 // Arbitrary high confidence for email forwarding AI model
    ]);
    
    console.log(`Logged ${finalStatus} submission to admin portal!`);

  } catch (error) {
    console.error('AI Extraction Failed:', error);
  }
}

module.exports = { processUnreadEmails };
