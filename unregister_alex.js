const { Client } = require('pg');

async function removeRegistrations() {
  const client = new Client({
    connectionString: 'postgresql://postgres:postgres@localhost:5432/hackbuddy'
  });
  
  await client.connect();
  
  await client.query('DELETE FROM registrations WHERE user_id = 2');
  
  console.log('Removed all registrations for user ID 2.');
  await client.end();
}

removeRegistrations().catch(console.error);
