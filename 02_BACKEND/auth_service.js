/**
 * CHILO ENGLISH - Servicio de Autenticación y Sesiones
 */
const { hashPassword, verifyPassword, generateSessionToken, checkRateLimit, sanitizeText } = require("./security");

async function registerStudent(db, { username, email, fullName, password }) {
  const { salt, hash } = hashPassword(password);
  const cleanEmail = String(email).trim().toLowerCase();
  const cleanUser = sanitizeText(username.trim());
  const cleanName = sanitizeText(fullName.trim());
  const { rows } = await db.query(
    `INSERT INTO users (username, email, full_name, password_hash, password_salt, role)
     VALUES ($1, $2, $3, $4, $5, 'student') RETURNING id, username, email, role`,
    [cleanUser, cleanEmail, cleanName, hash, salt]
  );
  return rows[0];
}

async function loginStudent(db, { identifier, password, ipAddress }) {
  if (!checkRateLimit(`login:${identifier}:${ipAddress}`)) {
    throw new Error("Demasiados intentos fallidos. Espera 15 minutos.");
  }
  const { rows } = await db.query(`SELECT * FROM users WHERE email = $1 OR username = $1 LIMIT 1`, [String(identifier).trim().toLowerCase()]);
  const user = rows[0];
  if (!user || !verifyPassword(password, user.password_hash, user.password_salt)) {
    if (user) await db.query(`SELECT * FROM sp_record_login_attempt($1, FALSE, $2)`, [user.id, ipAddress || null]);
    throw new Error("Credenciales inválidas.");
  }
  await db.query(`SELECT * FROM sp_record_login_attempt($1, TRUE, $2)`, [user.id, ipAddress || null]);
  const { rawToken, tokenHash } = generateSessionToken();
  await db.query(`INSERT INTO user_sessions (user_id, token_hash, ip_address, expires_at) VALUES ($1, $2, $3, NOW() + INTERVAL '7 days')`, [user.id, tokenHash, ipAddress || null]);
  return { userId: user.id, role: user.role, token: rawToken };
}

async function revokeAllUserSessions(db, userId) {
  const { rows } = await db.query(`SELECT sp_revoke_all_sessions($1) AS count`, [userId]);
  return rows[0].count;
}

module.exports = { registerStudent, loginStudent, revokeAllUserSessions };
