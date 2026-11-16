/**
 * CHILO ENGLISH - Controlador del Jardín Virtual 3D y Tienda
 */
async function buyItem(db, { userId, itemId, quantity = 1 }) {
  const { rows } = await db.query(`SELECT sp_buy_garden_item($1, $2, $3) AS leaves_balance`, [userId, itemId, quantity]);
  return rows[0];
}

async function getGardenState(db, userId) {
  const plots = await db.query(`SELECT plot_index, item_id, growth_stage, hydration, fertilized FROM garden_plots WHERE user_id = $1 ORDER BY plot_index`, [userId]);
  const inv = await db.query(`SELECT item_id, quantity FROM garden_inventory WHERE user_id = $1 AND quantity > 0`, [userId]);
  return { plots: plots.rows, inventory: inv.rows };
}

module.exports = { buyItem, getGardenState };
