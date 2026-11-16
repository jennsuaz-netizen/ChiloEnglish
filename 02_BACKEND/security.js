/**
 * CHILO ENGLISH - Módulo Central de Seguridad
 */
const crypto = require("crypto");

const PBKDF2_ITERATIONS = 310000;
const KEY_LEN = 64;
const DIGEST = "sha512";

function hashPassword(plainPassword) {
  if (typeof plainPassword !== "string" || plainPassword.length < 8) {
    throw new Error("La contraseña debe tener al menos 8 caracteres.");
  }
  const salt = crypto.randomBytes(16).toString("hex");
  const hash = crypto.pbkdf2Sync(plainPassword, salt, PBKDF2_ITERATIONS, KEY_LEN, DIGEST).toString("hex");
  return { salt, hash };
}

function verifyPassword(plainPassword, storedHash, storedSalt) {
  const derived = crypto.pbkdf2Sync(plainPassword, storedSalt, PBKDF2_ITERATIONS, KEY_LEN, DIGEST);
  const target = Buffer.from(storedHash, "hex");
  if (derived.length !== target.length) return false;
  return crypto.timingSafeEqual(derived, target);
}

function generateSessionToken() {
  const rawToken = crypto.randomBytes(32).toString("hex");
  const tokenHash = crypto.createHash("sha256").update(rawToken).digest("hex");
  return { rawToken, tokenHash };
}

function sanitizeText(input) {
  return String(input || "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function requireRole(...allowedRoles) {
  return (req, res, next) => {
    if (!req.user || !allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ error: "Acceso denegado: permisos insuficientes." });
    }
    next();
  };
}

const loginAttempts = new Map();
function checkRateLimit(key, maxAttempts = 5, windowMs = 15 * 60 * 1000) {
  const now = Date.now();
  const entry = loginAttempts.get(key) || { count: 0, start: now };
  if (now - entry.start > windowMs) {
    entry.count = 0;
    entry.start = now;
  }
  entry.count += 1;
  loginAttempts.set(key, entry);
  return entry.count <= maxAttempts;
}

module.exports = { hashPassword, verifyPassword, generateSessionToken, sanitizeText, requireRole, checkRateLimit };
