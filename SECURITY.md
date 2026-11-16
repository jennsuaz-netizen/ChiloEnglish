# Seguridad de la Información — CHILO ENGLISH
- **Hashing de Contraseñas:** PBKDF2-HMAC-SHA512 con 310,000 iteraciones y salt aleatorio de 16 bytes por usuario (`02_BACKEND/security.js`), más `SHA-256` en modo offline (`index.html`).
- **Comparación en Tiempo Constante:** `crypto.timingSafeEqual` para mitigar ataques de temporización.
- **Sesiones:** Tokens de 256 bits (`crypto.randomBytes(32)`); en BD solo se almacena el hash SHA-256 (`token_hash`).
- **Anti-Fuerza Bruta:** Bloqueo automático tras 5 intentos fallidos durante 15 minutos (`rate_limits` + `sp_record_login_attempt`).
- **Aislamiento de Datos (RLS):** Cada tabla de usuario exige `auth.uid() = user_id`.
- **Auditoría:** Registro inmutable en `security_audit_logs` de creación de cuentas, inicios fallidos, cambios de contraseña y revocación de sesiones.
- **Anti-XSS y SQLi:** Sanitización HTML (`sanitizeText` / `esc`) y consultas parametrizadas (`$1, $2...`).
