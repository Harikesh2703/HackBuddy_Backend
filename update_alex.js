const { Client } = require('pg');
const bcrypt = require('bcryptjs');

async function updateAlex() {
  const client = new Client({
    connectionString: 'postgresql://postgres:postgres@localhost:5432/hackbuddy'
  });
  
  await client.connect();
  const hash = await bcrypt.hash('@Admin', 10);
  
  await client.query(
    'UPDATE users SET email = $1, password_hash = $2 WHERE id = 2',
    ['admin@123', hash]
  );
  
  console.log('Alex credentials updated in live DB.');
  await client.end();
}

updateAlex().catch(console.error);
