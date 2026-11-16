/**
 * CHILO ENGLISH - Sincronización local segura (localStorage + SHA-256)
 */
export async function sha256Hex(msg) {
  const buf = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(msg));
  return Array.from(new Uint8Array(buf)).map(b => b.toString(16).padStart(2, "0")).join("");
}

export function saveLocalState(key, payload) {
  localStorage.setItem(key, JSON.stringify(payload));
}

export function loadLocalState(key, fallback = null) {
  try {
    const raw = localStorage.getItem(key);
    return raw ? JSON.parse(raw) : fallback;
  } catch {
    return fallback;
  }
}
