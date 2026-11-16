/**
 * CHILO ENGLISH - Controlador de Lógica del Jardín Virtual 3D
 * Herramientas: 1=Inventario, 2=Regadera, 3=Pala, 4=Fertilizante, 5=Cesta, 6=Tijeras
 */
function createEmptyGarden(plotCount = 9) {
  return Array.from({ length: plotCount }, (_, idx) => ({
    plotIndex: idx, prepared: false, itemId: null, growthStage: 0, hydration: 0, fertilized: false
  }));
}

function applyGardenTool(plot, toolId, seedId = null) {
  const next = { ...plot };
  if (toolId === 3) next.prepared = true;
  else if (toolId === 1 && next.prepared && !next.itemId && seedId) {
    next.itemId = seedId;
    next.growthStage = 0;
  } else if (toolId === 2 && next.itemId) {
    next.hydration = Math.min(100, next.hydration + 50);
    if (next.growthStage < 3) next.growthStage += 1;
  } else if (toolId === 4 && next.itemId && !next.fertilized) {
    next.fertilized = true;
    next.growthStage = Math.min(3, next.growthStage + 1);
  } else if (toolId === 5 && next.itemId && next.growthStage === 3) {
    return { plot: { ...next, itemId: null, growthStage: 0, hydration: 0, fertilized: false, prepared: false }, harvestedLeaves: 4 };
  } else if (toolId === 6 && next.itemId) {
    next.hydration = Math.min(100, next.hydration + 10);
  }
  return { plot: next, harvestedLeaves: 0 };
}

module.exports = { createEmptyGarden, applyGardenTool };
