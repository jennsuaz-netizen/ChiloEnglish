/**
 * CHILO ENGLISH - Cliente PostgreSQL con Pool SSL y Transacciones Seguras
 */
const { Pool } = require("pg");

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: true } : false,
  max: 20,
  idleTimeoutMillis: 30000
});

async function query(sql, params = []) {
  return pool.query(sql, params);
}

async function withTransaction(workFn) {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const result = await workFn(client);
    await client.query("COMMIT");
    return result;
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
}

module.exports = { pool, query, withTransaction };
