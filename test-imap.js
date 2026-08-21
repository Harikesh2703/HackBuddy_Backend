import { ImapFlow } from 'imapflow';
import 'dotenv/config';

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

async function main() {
  await client.connect();
  const lock = await client.getMailboxLock('INBOX');
  try {
    console.log(`Total messages in INBOX: ${client.mailbox.exists}`);
    let count = 0;
    for await (const msg of client.fetch('1:*', { envelope: true })) {
      count++;
      console.log(`${count}. Subject: ${msg.envelope.subject}`);
    }
  } finally {
    lock.release();
    await client.logout();
  }
}

main().catch(console.error);
