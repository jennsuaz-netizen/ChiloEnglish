/**
 * CHILO ENGLISH - API Server HTTP (Sin dependencias externas obligatorias)
 */
const http = require("http");
const db = require("../BASE_DE_DATOS/db_client");
const auth = require("./auth_service");
const lessons = require("./lessons_controller");
const garden = require("./garden_controller");

const PORT = process.env.API_PORT || 4000;

function sendJson(res, status, data) {
  res.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "DENY"
  });
  res.end(JSON.stringify(data));
}

const server = http.createServer(async (req, res) => {
  if (req.url === "/api/health" && req.method === "GET") {
    return sendJson(res, 200, { status: "ok", platform: "CHILO ENGLISH" });
  }
  sendJson(res, 404, { error: "Ruta no encontrada" });
});

if (require.main === module) {
  server.listen(PORT, () => console.log(`API CHILO ENGLISH escuchando en puerto ${PORT}`));
}

module.exports = { server, db, auth, lessons, garden };
