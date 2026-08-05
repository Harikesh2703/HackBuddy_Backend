const db = require('./db');
const readline = require('readline');

async function main() {
  try {
    console.log('Fetching recently added hackathons...');
    const result = await db.query('SELECT id, title, source_url FROM hackathons ORDER BY id DESC');
    
    let toDelete = [];
    result.rows.forEach(row => {
      // If title indicates fallback data or it's a recently added one we want to clear
      if (row.title.startsWith('Extracted Hackathon from') || row.title.startsWith('Hackathon from') || row.id > 4) {
        toDelete.push(row.id);
      }
    });

    if (toDelete.length > 0) {
      console.log(`Found ${toDelete.length} scraped entries to delete.`);
      
      const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
      });

      const answer = await new Promise(resolve => {
        rl.question('⚠️ Are you sure you want to permanently delete these entries? (y/N) ', resolve);
      });
      rl.close();

      if (answer.toLowerCase() === 'y') {
        console.log('Deleting...');
        await db.query(`DELETE FROM hackathons WHERE id = ANY($1::int[])`, [toDelete]);
        console.log('Deletion successful!');
      } else {
        console.log('Deletion aborted. Your data is safe!');
      }
    } else {
      console.log('No recent scraped entries found to delete.');
    }
  } catch (err) {
    console.error('Error:', err);
  } finally {
    process.exit(0);
  }
}

main();
