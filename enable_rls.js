const db = require('./db');

async function enableRLS() {
  const tables = [
    'student_submissions',
    'submissions',
    'leaderboard',
    'teams',
    'users',
    'registrations',
    'tasks',
    'team_members',
    'winners',
    'hackathons'
  ];

  try {
    for (const table of tables) {
      console.log(`Enabling RLS on ${table}...`);
      await db.query(`ALTER TABLE ${table} ENABLE ROW LEVEL SECURITY;`);
    }
    console.log('Successfully enabled RLS on all tables!');
  } catch (err) {
    console.error('Error enabling RLS:', err);
  } finally {
    process.exit(0);
  }
}

enableRLS();
