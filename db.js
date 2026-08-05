const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgres://postgres:postgres@127.0.0.1:5432/hackbuddy',
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle PG client:', err.message);
});

async function initDb() {
  const client = await pool.connect();
  try {
    console.log('🔄 Checking & initializing HackBuddy database schema...');

    // 1. Create Users Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        role VARCHAR(50) DEFAULT 'student',
        password_hash VARCHAR(255),
        avatar_url TEXT,
        university VARCHAR(255),
        department VARCHAR(255),
        win_count INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await client.query(`
      ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);
      ALTER TABLE users ADD COLUMN IF NOT EXISTS university VARCHAR(255);
      ALTER TABLE users ADD COLUMN IF NOT EXISTS department VARCHAR(255);
      ALTER TABLE users ADD COLUMN IF NOT EXISTS win_count INT DEFAULT 0;
    `);


    // 2. Create Hackathons Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS hackathons (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        source_url TEXT,
        registration_deadline TIMESTAMP,
        event_date TIMESTAMP,
        status VARCHAR(50) DEFAULT 'upcoming',
        event_mode VARCHAR(50) DEFAULT 'online',
        sample_url TEXT,
        prize_pool TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Ensure missing columns if existing table had different structure
    await client.query(`
      ALTER TABLE hackathons ADD COLUMN IF NOT EXISTS event_mode VARCHAR(50) DEFAULT 'online';
      ALTER TABLE hackathons ADD COLUMN IF NOT EXISTS sample_url TEXT;
      ALTER TABLE hackathons ADD COLUMN IF NOT EXISTS description TEXT;
      ALTER TABLE hackathons ADD COLUMN IF NOT EXISTS registration_deadline TIMESTAMP;
      ALTER TABLE hackathons ADD COLUMN IF NOT EXISTS event_date TIMESTAMP;
      ALTER TABLE hackathons ADD COLUMN IF NOT EXISTS source_url TEXT;
      ALTER TABLE hackathons ADD COLUMN IF NOT EXISTS prize_pool TEXT;
      ALTER TABLE hackathons ADD COLUMN IF NOT EXISTS phases JSONB DEFAULT '[]';
      ALTER TABLE hackathons ADD COLUMN IF NOT EXISTS current_phase VARCHAR(100) DEFAULT 'Registration';
    `);

    // 2.5 Create Registrations Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS registrations (
        id SERIAL PRIMARY KEY,
        hackathon_id INT REFERENCES hackathons(id) ON DELETE CASCADE,
        user_id INT REFERENCES users(id) ON DELETE CASCADE,
        status VARCHAR(50) DEFAULT 'registered',
        registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(hackathon_id, user_id)
      );
    `);

    // 2.6 Create Teams Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS teams (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        hackathon_id INT REFERENCES hackathons(id) ON DELETE CASCADE,
        leader_id INT REFERENCES users(id) ON DELETE CASCADE,
        status VARCHAR(50) DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 2.7 Create Team Members Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS team_members (
        id SERIAL PRIMARY KEY,
        team_id INT REFERENCES teams(id) ON DELETE CASCADE,
        user_id INT REFERENCES users(id) ON DELETE SET NULL,
        email VARCHAR(255) NOT NULL,
        register_number VARCHAR(100),
        invite_status VARCHAR(50) DEFAULT 'pending',
        proof_url TEXT,
        joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(team_id, email)
      );
    `);

    // 3. Create Tasks Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS tasks (
        id SERIAL PRIMARY KEY,
        hackathon_id INT REFERENCES hackathons(id) ON DELETE CASCADE,
        user_id INT REFERENCES users(id) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        due_date TIMESTAMP,
        status VARCHAR(50) DEFAULT 'todo',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 4. Create Submissions Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS submissions (
        id SERIAL PRIMARY KEY,
        hackathon_id INT REFERENCES hackathons(id) ON DELETE CASCADE,
        user_id INT REFERENCES users(id) ON DELETE CASCADE,
        proof_url TEXT,
        ai_status VARCHAR(50) DEFAULT 'pending',
        ai_feedback TEXT,
        ai_confidence DOUBLE PRECISION DEFAULT 0.0,
        submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 4.5 Create Winners Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS winners (
        id SERIAL PRIMARY KEY,
        hackathon_id INT REFERENCES hackathons(id) ON DELETE CASCADE,
        user_id INT REFERENCES users(id) ON DELETE CASCADE,
        team_id INT REFERENCES teams(id) ON DELETE CASCADE,
        won_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(hackathon_id, user_id)
      );
    `);

    // 5. Seed Users if empty
    const usersCount = await client.query('SELECT COUNT(*) FROM users');
    if (parseInt(usersCount.rows[0].count, 10) === 0) {
      console.log('🌱 Seeding initial users...');
      const bcrypt = require('bcryptjs');
      const hash = await bcrypt.hash('password123', 10);
      const alexHash = await bcrypt.hash('@Admin', 10);
      await client.query(`
        INSERT INTO users (id, name, email, role, avatar_url, password_hash) VALUES
        (1, 'Sarah Chen', 'sarah.chen@hackbuddy.org', 'admin', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', $1),
        (2, 'Alex Rivers', 'admin@123', 'student', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', $2),
        (3, 'Marcus Vance', 'marcus.v@devs.io', 'student', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', $1);
      `, [hash, alexHash]);
      // reset sequence
      await client.query(`SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));`);
    }

    // Set default password for any users that don't have one (e.g. from previous runs)
    const bcrypt = require('bcryptjs');
    const hash = await bcrypt.hash('password123', 10);
    await client.query('UPDATE users SET password_hash = $1 WHERE password_hash IS NULL', [hash]);


    // 6. Seed Hackathons if empty
    const hackathonsCount = await client.query('SELECT COUNT(*) FROM hackathons');
    if (parseInt(hackathonsCount.rows[0].count, 10) === 0) {
      console.log('🌱 Seeding initial hackathons...');
      await client.query(`
        INSERT INTO hackathons (id, title, description, source_url, registration_deadline, event_date, status, event_mode, sample_url) VALUES
        (1, 'Global AI Agents Sprint 2026', 'Build autonomous AI agents to solve real-world automation challenges using LLMs, multi-agent frameworks, and vector search.', 'https://devpost.com/hackathons/global-ai-agents', '2026-07-28 23:59:59', '2026-08-01 09:00:00', 'active', 'online', 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600'),
        (2, 'Web3 Innovation Summit', 'Develop decentralized applications, cross-chain smart contracts, and zero-knowledge privacy prototypes.', 'https://ethglobal.com/events/innovation2026', '2026-08-05 23:59:59', '2026-08-10 10:00:00', 'upcoming', 'online', 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=600'),
        (3, 'Robotics & Hardware Hackathon', 'Build autonomous hardware controllers, ROS2 robotics nodes, and IoT sensory networks for smart logistics.', 'https://idrea.org/robotic-challenge/', '2026-08-15 23:59:59', '2026-08-20 08:00:00', 'upcoming', 'offline', 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=600'),
        (4, 'GreenTech Sustainable Code Challenge', 'Design energy-efficient algorithms and climate tech carbon footprint monitoring dashboards.', 'https://greentech-hack.org', '2026-08-31 23:59:59', '2026-07-18 10:00:00', 'open', 'online', 'https://images.unsplash.com/photo-1497435334941-8c899ee9e8e9?w=600');
      `);
      await client.query(`SELECT setval('hackathons_id_seq', (SELECT MAX(id) FROM hackathons));`);
    }

    // 6.5 Seed Registrations if empty
    const regCount = await client.query('SELECT COUNT(*) FROM registrations');
    if (parseInt(regCount.rows[0].count, 10) === 0) {
      console.log('🌱 Seeding initial registrations...');
      await client.query(`
        INSERT INTO registrations (hackathon_id, user_id, status) VALUES
        (1, 2, 'registered'),
        (2, 2, 'registered'),
        (4, 2, 'completed');
      `);
    }

    // 7. Seed Tasks if empty
    const tasksCount = await client.query('SELECT COUNT(*) FROM tasks');
    if (parseInt(tasksCount.rows[0].count, 10) === 0) {
      console.log('🌱 Seeding initial sprint tasks...');
      await client.query(`
        INSERT INTO tasks (hackathon_id, user_id, title, description, due_date, status) VALUES
        (1, 2, 'Design UI System & Figma Wireframes', 'Create modern dark mode mockup and UI components for the agent dashboard.', '2026-07-25 18:00:00', 'completed'),
        (1, 2, 'Setup Vector DB & RAG Pipeline', 'Configure Pgvector or Pinecone indexing for fast knowledge extraction.', '2026-07-27 12:00:00', 'in_progress'),
        (1, 2, 'Build Gemini AI Verification Endpoint', 'Integrate multimodal vision verification for student certificate proofs.', '2026-07-28 15:00:00', 'in_progress'),
        (1, 2, 'Record 3-Minute Video Demo & Pitch Deck', 'Record loom video overview and prepare GitHub repository submission.', '2026-07-28 20:00:00', 'todo'),
        (2, 2, 'Smart Contract Audit & Testnet Deployment', 'Deploy ERC-721 credential verification contracts to Sepolia testnet.', '2026-08-04 17:00:00', 'todo');
      `);
    }

    // 8. Seed Submissions if empty
    const subCount = await client.query('SELECT COUNT(*) FROM submissions');
    if (parseInt(subCount.rows[0].count, 10) === 0) {
      console.log('🌱 Seeding initial submissions...');
      await client.query(`
        INSERT INTO submissions (hackathon_id, user_id, proof_url, ai_status, ai_feedback, ai_confidence) VALUES
        (4, 2, 'https://github.com/alexrivers/greentech-dashboard', 'verified', 'VERIFIED: GreenTech Certificate template matched. Verified project submission repository & commit history.', 0.98);
      `);
    }

    console.log('✅ Database schema and seed initialization completed successfully.');
  } catch (err) {
    console.error('❌ Error initializing DB schema:', err.message);
  } finally {
    client.release();
  }
}

module.exports = {
  query: (text, params) => pool.query(text, params),
  initDb,
};

