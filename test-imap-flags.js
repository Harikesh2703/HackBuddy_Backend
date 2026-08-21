import { ImapFlow } from 'imapflow';
import 'dotenv/config';

const client = new ImapFlow({
  host: 'imap.gmail.com', port: 993, secure: true,
  auth: { user: 'hackbuddy.verify@gmail.com', pass: process.env.EMAIL_APP_PASSWORD },
  logger: false
});

async function main() {
  await client.connect();
  const lock = await client.getMailboxLock('INBOX');
  try {
    for await (const msg of client.fetch('1:*', { envelope: true, flags: true })) {
      const isUnread = !msg.flags.has('\\Seen');
      console.log(`Subject: "${msg.envelope.subject}" | Unread: ${isUnread} | Flags: ${Array.from(msg.flags).join(',')}`);
    }
  } finally {
    lock.release();
    await client.logout();
  }
}
main().catch(console.error);
