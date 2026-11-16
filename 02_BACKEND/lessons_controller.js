/**
 * CHILO ENGLISH - Controlador de Lecciones y Progreso (180 / 60 / 60)
 */
async function getUserLevelProgress(db, userId) {
  const { rows } = await db.query(`SELECT level_id, level_name, completed_units, total_units, progress_pct FROM v_user_level_progress WHERE user_id = $1 ORDER BY level_id`, [userId]);
  return rows;
}

async function completeUnit(db, { userId, unitId, accuracyPct, xpEarned, durationSec }) {
  await db.query(`SELECT sp_complete_lesson_unit($1, $2, $3, $4, $5)`, [userId, unitId, accuracyPct, xpEarned, durationSec]);
  return getUserLevelProgress(db, userId);
}

module.exports = { getUserLevelProgress, completeUnit };
