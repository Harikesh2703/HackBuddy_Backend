const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
puppeteer.use(StealthPlugin());

async function run() {
  const browser = await puppeteer.launch({ headless: false, args: ['--no-sandbox', '--disable-setuid-sandbox'] });
  const page = await browser.newPage();
  console.log("Navigating...");
  try {
    await page.goto('https://unstop.com/workshops-webinars/0xcon-2026-students-chennai-institute-of-technology-1715813', { waitUntil: 'networkidle2', timeout: 30000 });
    const text = await page.evaluate(() => document.body.innerText);
    console.log("Length of text:", text.length);
    console.log("Snippet:", text.substring(0, 200));
  } catch (e) {
    console.error("Error:", e.message);
  }
  await browser.close();
}
run();
