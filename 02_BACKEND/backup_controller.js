/**
 * CHILO ENGLISH - Controlador de Respaldo y Portabilidad de Datos
 */
async function exportBackup(db, userId) {
  const { rows } = await db.query(`SELECT sp_export_user_backup($1) AS backup`, [userId]);
  return rows[0].backup;
}

module.exports = { exportBackup };
