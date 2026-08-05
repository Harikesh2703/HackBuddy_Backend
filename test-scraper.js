const dotenv = require('dotenv');
const db = require('./db');
const { scrapeHackathons } = require('./scraper');

dotenv.config();

const hasGeminiKey = false;
const model = null;

const testUrls = ['https://www.ecell.in/nec/'];

async function main() {
  await db.query('SELECT 1');
  const results = await scrapeHackathons({
    urls: testUrls,
    db,
    model,
    hasGeminiKey,
    headless: false,
  });
  console.log(JSON.stringify(results, null, 2));
  process.exit(0);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
