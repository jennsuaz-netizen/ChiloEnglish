/**
 * CHILO ENGLISH - Motor de Puntuación y Recompensas para 12 Juegos Educativos
 */
const GAME_CATEGORIES = [
  "Sopa de letras", "Crucigrama", "Rompecabezas", "Juego de vocabulario",
  "Traducciones", "Relacionar palabras", "Completar oraciones", "Memoria",
  "Comprensión lectora", "Zona de retos", "Audio-Quiz", "Velocidad Bilingüe"
];

function evaluateGameSession({ category, correctAnswers, totalQuestions, streak = 0 }) {
  if (!GAME_CATEGORIES.includes(category)) throw new Error("Categoría de juego inválida.");
  const accuracy = totalQuestions > 0 ? Math.round((correctAnswers / totalQuestions) * 100) : 0;
  const baseXp = correctAnswers * 10;
  const bonusXp = streak >= 3 ? streak * 5 : 0;
  const leavesRewarded = accuracy >= 80 ? 3 : accuracy >= 50 ? 2 : 1;
  return { category, accuracy, totalXp: baseXp + bonusXp, leavesRewarded };
}

module.exports = { GAME_CATEGORIES, evaluateGameSession };
