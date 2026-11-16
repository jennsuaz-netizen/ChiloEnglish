/**
 * Suite de Pruebas Integrales - CHILO ENGLISH
 */
const fs = require("fs");
const path = require("path");
const assert = require("assert");

const root = path.join(__dirname, "..");
const html = fs.readFileSync(path.join(root, "index.html"), "utf8");
assert(html.includes("<title>CHILO ENGLISH"), "Falta título CHILO ENGLISH");

const m = html.match(/^const DATA =(\[.*\]);$/m);
const DATA = JSON.parse(m[1]);
assert.strictEqual(DATA[0].c.length, 20);
assert.strictEqual(DATA[1].c.length, 20);
assert.strictEqual(DATA[2].c.length, 20);
assert.strictEqual(DATA[0].c.reduce((a, c) => a + c.l.length, 0), 180);
assert.strictEqual(DATA[1].c.reduce((a, c) => a + c.l.length, 0), 60);
assert.strictEqual(DATA[2].c.reduce((a, c) => a + c.l.length, 0), 60);

// Seguridad
const sec = require(path.join(root, "02_BACKEND", "security.js"));
const { salt, hash } = sec.hashPassword("ChiloSeguro2026!");
assert.strictEqual(sec.verifyPassword("ChiloSeguro2026!", hash, salt), true);
assert.strictEqual(sec.verifyPassword("Mala123", hash, salt), false);
assert.strictEqual(sec.sanitizeText("<b>x</b>"), "&lt;b&gt;x&lt;/b&gt;");

// Juegos
const games = require(path.join(root, "05_JUEGOS", "game_engine.js"));
const gRes = games.evaluateGameSession({ category: "Memoria", correctAnswers: 9, totalQuestions: 10, streak: 4 });
assert.strictEqual(gRes.leavesRewarded, 3);

// Jardín 3D
const garden = require(path.join(root, "06_MI_JARDIN_3D", "garden_3d_controller.js"));
let plot = garden.createEmptyGarden(1)[0];
plot = garden.applyGardenTool(plot, 3).plot;
plot = garden.applyGardenTool(plot, 1, "sunflower").plot;
plot = garden.applyGardenTool(plot, 2).plot;
plot = garden.applyGardenTool(plot, 2).plot;
plot = garden.applyGardenTool(plot, 4).plot;
const harvest = garden.applyGardenTool(plot, 5);
assert.strictEqual(harvest.harvestedLeaves, 4);

// SQL Files
for (const f of ["01_schema.sql", "02_rls_policies.sql", "03_triggers_audit.sql", "04_stored_procedures.sql", "05_seed_curriculum.sql", "06_seed_catalogs.sql", "07_views_reports.sql"]) {
  assert(fs.existsSync(path.join(root, "03_DATABASE", f)), `Falta ${f}`);
}
assert(fs.existsSync(path.join(root, "BASE_DE_DATOS", "chilo_english_full_db.sql")), "Falta chilo_english_full_db.sql");

console.log("SUITE COMPLETA OK: Currículo (180/60/60), Seguridad, Juegos, Jardín 3D y SQL verificados.");
