const fs = require('fs');
const readline = require('readline');
const dotenv = require('dotenv');
const db = require('./db');
const { scrapeSingleUrl, launchBrowser, closeBrowser, insertHackathon } = require('./scraper');

dotenv.config();

const MAX_RETRIES = 3; // Maximum retry attempts before abandoning a URL

// We strictly use qwen2.5:3b via DevTunnels Ollama
const MODEL_CONFIG = { 
  name: 'qwen2.5:3b', 
  model: null 
};

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// Strict Rate Limiter State
const RPM_LIMIT = Infinity; // Temporarily removed for on-prem API
const callTimestamps = [];

async function enforceRateLimit() {
  return 1; // Limit temporarily removed
}

function promptUser(query) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  return new Promise(resolve => rl.question(query, ans => {
    rl.close();
    resolve(ans);
  }));
}

async function main() {
  await db.query('SELECT 1'); // verify db connection
  
  const isTestRun = process.argv.includes('--test');
  
  // Fetch pending URLs from the text file and deduplicate them
  const text = fs.readFileSync('hackathon_links.txt', 'utf8');
  let rawUrls = [...new Set(text.split('\n').map(u => u.trim()).filter(u => u.startsWith('http')))];

  if (isTestRun) {
    console.log('🧪 RUNNING IN TEST MODE (3 URLs only)...');
    rawUrls = rawUrls.slice(0, 3);
  } else {
    // Enforce Requests Per Day limit (250) - TEMPORARILY DISABLED
    // if (rawUrls.length > 250) {
    //   console.log(`⚠️ Input contains ${rawUrls.length} URLs. Truncating to 250 to respect RPD limit.`);
    //   rawUrls = rawUrls.slice(0, 250);
    // }
  }

  // 1. Convert simple string URLs into task objects with attempt counters
  const queue = rawUrls.map((url) => ({ url, attempts: 0 }));
  const failedUrls = []; // Track permanently failed URLs for reporting
  const skippedUrls = []; // Track explicitly skipped URLs

  console.log(`Starting sequential interactive scraper for ${queue.length} URLs with ${MODEL_CONFIG.name}.`);
  const browser = await launchBrowser(false);

  const { name: modelName, model } = MODEL_CONFIG;

  // 2. Process sequentially to ensure no batch processing and strict limit adherence
  while (queue.length > 0) {
    const task = queue.shift();
    if (!task) break;

    const { url } = task;
    console.log(`\n================================================================================`);
    console.log(`🌐 Processing: ${url}`);
    
    // Ensure we don't exceed rate limit before calling API
    const callsThisMin = await enforceRateLimit();
    console.log(`📊 Calls made in the current 1-minute window: ${callsThisMin}/${RPM_LIMIT}`);

    try {
      // 1. Get parsed data (does not insert into DB yet)
      const data = await scrapeSingleUrl({ url, db, model, browser });

      if (data.alreadyInDB) {
        console.log(`⏭️  Already in DB (Skipping extraction & insertion).`);
        continue;
      }

      // 2. Preview data
      console.log(`\n✨ AI Extracted Data for ${url}:`);
      console.log(JSON.stringify(data, null, 2));

      // 3. Check auto-proceed condition
      let autoProceed = false;
      if (!data.error && typeof data === 'object') {
        const fields = Object.keys(data);
        const filledFields = fields.filter(k => {
          const val = data[k];
          if (Array.isArray(val)) return val.length > 0;
          return val !== null && val !== undefined && val !== '';
        });
        const hasDescription = data.description && typeof data.description === 'string' && data.description.trim().length > 0;
        
        if ((fields.length > 0 && (filledFields.length / fields.length) > 0.7) || hasDescription) {
          autoProceed = true;
        }
      }

      if (autoProceed) {
        console.log(`\n🤖 Auto-proceeding to DB (Condition met: >70% fields present OR description exists)...`);
        const result = await insertHackathon(db, data);
        if (result) {
          console.log(`✅ Success: ${url}`);
        } else {
          console.log(`❌ DB Insert Failed for ${url}`);
        }
        continue;
      }

      // 4. Prompt user for action if condition not met
      let validAction = false;
      while (!validAction) {
        const answer = await promptUser(`\n[y] Proceed to DB | [r] Try Again | [s] Skip | [q] Quit >> `);
        
        switch(answer.trim().toLowerCase()) {
          case 'y':
            console.log(`Inserting into DB...`);
            const result = await insertHackathon(db, data);
            if (result) {
              console.log(`✅ Success: ${url}`);
            } else {
              console.log(`❌ DB Insert Failed for ${url}`);
            }
            validAction = true;
            break;
          case 'r':
            console.log(`Re-queueing URL to try again...`);
            task.attempts += 1;
            queue.unshift(task); // Put back to front
            validAction = true;
            break;
          case 's':
            console.log(`Skipping URL...`);
            skippedUrls.push(url);
            validAction = true;
            break;
          case 'q':
            console.log(`Quitting...`);
            await closeBrowser(browser);
            process.exit(0);
            break;
          default:
            console.log(`Invalid option. Please enter y, r, s, or q.`);
        }
      }

    } catch (error) {
      task.attempts += 1;
      const isRateLimit = error.status === 429 || error.message?.includes('429') || error.message?.includes('Quota') || error.message?.includes('RESOURCE_EXHAUSTED');
      const is404 = error.message?.includes('404') || error.message?.includes('Not Found');

      if (is404) {
           console.error(`🚨 [${modelName}] 404 NOT FOUND. Model string may be invalid. Error: ${error.message}`);
           failedUrls.push({ url, attempts: task.attempts, lastError: error.message });
           continue;
      }

      if (task.attempts >= MAX_RETRIES) {
        console.error(`🚨 [${modelName}] ABANDONING ${url} after ${task.attempts} failed attempt(s). Error: ${error.message}`);
        failedUrls.push({ url, attempts: task.attempts, lastError: error.message });
        continue;
      }

      if (isRateLimit) {
        console.warn(`⚠️ Rate limited (429) on ${url} (Attempt ${task.attempts}/${MAX_RETRIES}). Backing off...`);
        queue.unshift(task);
        await sleep(30000); // Strict wait on actual 429
      } else {
        console.warn(`⚠️ Soft error on ${url} (Attempt ${task.attempts}/${MAX_RETRIES}): ${error.message}. Re-queueing...`);
        queue.push(task);
        await sleep(5000);
      }
    }
  }

  console.log(`\n🎉 [${modelName}] Finished processing all URLs.`);

  // Clean up
  await closeBrowser(browser);

  // Final summary
  console.log('\n================ Execution Summary ================');
  console.log(`Total Processed: ${rawUrls.length - failedUrls.length - skippedUrls.length}`);
  console.log(`Permanently Failed: ${failedUrls.length}`);
  if (failedUrls.length > 0) {
    console.log('Failed URLs:', failedUrls);
  }
  console.log(`Skipped: ${skippedUrls.length}`);
  if (skippedUrls.length > 0) {
    console.log('Skipped URLs:', skippedUrls);
  }
  console.log('===================================================\n');

  process.exit(0);
}

main().catch((err) => {
  console.error('Fatal execution error:', err);
  process.exit(1);
});
