const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
puppeteer.use(StealthPlugin());

function buildPrompt({ url, pageText, images = [] }) {
  return `You are a data extraction assistant. I am going to give you raw text and a list of image URLs scraped from a hackathon website.
CRITICAL INSTRUCTION: Give high importance to any dates mentioned in the website. Ensure all extracted phases, deadlines, and events accurately reflect their specific dates.
Also, identify the main theme image or logo of the hackathon from the provided image URLs. IMPORTANT: If this is a platform like Unstop, Devfolio, or Devpost, do NOT select their platform logo. Select the specific hackathon's unique theme image or logo.

Extract the relevant details and return ONLY a valid JSON object (no markdown formatting, no code blocks) with the following exact keys:
- "title": (string)
- "Event mode(offline or online)": (string)
- "description": (string)
- "sumission date": (string)
- "source_url": (string) the original URL of the hackathon
- "phases": (array of strings)
- "registration_deadline": (string YYYY-MM-DD HH:mm:ss or null)
- "event_date": (string YYYY-MM-DD HH:mm:ss or null)
- "theme_image_url": (string or null)
- "prize_pool": (string or null)

URL being scraped: ${url}

Available Image URLs:
${images.join('\n')}

Raw Text:
${pageText.substring(0, 60000)}`;
}

async function launchBrowser(headless = true) {
  try {
    return await puppeteer.launch({
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
      headless,
    });
  } catch (e) {
    console.warn('Puppeteer launch warning:', e.message);
    return null;
  }
}

async function closeBrowser(browser) {
  if (browser) {
    await browser.close().catch(() => {});
  }
}

async function scrapeSingleUrl({ url, db, model, browser }) {
  const existing = await db.query('SELECT * FROM hackathons WHERE source_url = $1', [url]).catch(() => null);
  if (existing && existing.rowCount > 0) {
    return { ...existing.rows[0], alreadyInDB: true };
  }

  if (!browser) {
    const domain = new URL(url).hostname;
    const fallbackData = {
      source_url: url,
      title: `Extracted Hackathon from ${domain}`,
      description: `Automatically extracted event parameters from ${url}.`,
      registration_deadline: '2026-08-15 23:59:59',
      event_date: '2026-08-20 09:00:00',
      event_mode: 'online',
    };
    return { ...fallbackData, isFallback: true };
  }

  const page = await browser.newPage();
  try {
    await page.goto(url, { waitUntil: 'networkidle2', timeout: 30000 }).catch(() => {});
    
    // Auto-scroll the page to trigger lazy loading (crucial for Unstop/Devfolio)
    await page.evaluate(async () => {
      await new Promise((resolve) => {
        let totalHeight = 0;
        const distance = 200;
        const timer = setInterval(() => {
          const scrollHeight = document.body.scrollHeight;
          window.scrollBy(0, distance);
          totalHeight += distance;

          if (totalHeight >= scrollHeight || totalHeight > 10000) {
            clearInterval(timer);
            resolve();
          }
        }, 100); // Fast but sufficient for triggering most lazy load scripts
      });
    });

    const pageText = await page.evaluate(() => {
      const text = document.body?.innerText || '';
      const images = Array.from(document.querySelectorAll('img'))
        .map((img) => img.src)
        .filter((src) => src && src.startsWith('http'));
      return { text, images: [...new Set(images)] };
    });
    await page.close();

    if (pageText.text.length > 50) {
      const prompt = buildPrompt({ url, pageText: pageText.text, images: pageText.images });
      const response = await fetch('https://7gxnpbb2-11434.inc1.devtunnels.ms/api/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          model: 'qwen2.5:3b',
          prompt: prompt,
          stream: false,
          format: 'json'
        })
      });
      if (!response.ok) throw new Error(`Ollama API error: ${response.statusText}`);
      
      const result = await response.json();
      let text = result.response.replace(/```json/gi, '').replace(/```/gi, '').trim();
      const data = JSON.parse(text);
      data.source_url = url;

      return data;
    }

    // Fallback if no model or very little text
    const fallbackData = {
      source_url: url,
      title: `Hackathon from ${new URL(url).hostname}`,
      description: pageText.text.substring(0, 200).replace(/\s+/g, ' ') + '...',
      registration_deadline: '2026-08-15 23:59:59',
      event_date: '2026-08-20 09:00:00',
      event_mode: pageText.text.toLowerCase().includes('offline') ? 'offline' : 'online',
    };
    return { ...fallbackData, isFallback: true };
  } catch (err) {
    await page.close().catch(() => {});
    throw err; // Throw to trigger worker queue retry logic
  }
}

// Ensure backwards compatibility for test-scraper.js
async function scrapeHackathons({ urls, db, model, hasGeminiKey, headless = true }) {
  const browser = await launchBrowser(headless);
  const results = await Promise.all(urls.map(url => scrapeSingleUrl({ url, db, model, browser }).catch(e => ({ source_url: url, error: e.message }))));
  await closeBrowser(browser);
  return results;
}

async function insertHackathon(db, data) {
  if (data.isFallback) {
    const dbResult = await db.query(
      `INSERT INTO hackathons (title, description, source_url, registration_deadline, event_date, event_mode)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
      [data.title, data.description, data.source_url, data.registration_deadline, data.event_date, data.event_mode]
    ).catch((e) => { console.error(e); return null; });
    return dbResult ? dbResult.rows[0] : data;
  } else {
    const dbResult = await db.query(
      `INSERT INTO hackathons (title, description, source_url, event_mode, registration_deadline, event_date, sample_url, prize_pool)
       VALUES ($1, $2, $3, $4, NULLIF($5, '')::TIMESTAMP, NULLIF($6, '')::TIMESTAMP, $7, $8) RETURNING *`,
      [
        data.title || 'Unknown Title',
        data.description || '',
        data.source_url,
        data['Event mode(offline or online)'] || data.event_mode || 'online',
        data.registration_deadline || null,
        data.event_date || null,
        data.theme_image_url || null,
        data.prize_pool || null
      ]
    ).catch((e) => { console.error(e); return null; });
    return dbResult ? dbResult.rows[0] : data;
  }
}

module.exports = { scrapeHackathons, launchBrowser, closeBrowser, scrapeSingleUrl, insertHackathon };
