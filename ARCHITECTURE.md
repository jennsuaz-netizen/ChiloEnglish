# Arquitectura del Sistema — CHILO ENGLISH
1. **Frontend (`01_FRONTEND` / `index.html`):** SPA modular con vistas `welcome`, `auth`, `manual_public`, `onboarding` y `app`.
2. **Backend y Seguridad (`02_BACKEND`):** Servidor API, servicio de autenticación con PBKDF2-HMAC-SHA512, tokens SHA-256, control de acceso RBAC, rate limiting, controladores de lecciones, jardín y respaldos.
3. **Base de Datos (`03_DATABASE` y `BASE_DE_DATOS`):** 18 tablas normalizadas en PostgreSQL 15+, políticas RLS, 5 triggers automáticos, 7 procedimientos almacenados (`sp_*`), semillas de 300 unidades y vistas analíticas.
4. **Módulos de Juegos y Jardín 3D (`05_JUEGOS`, `06_MI_JARDIN_3D`):** Motores dedicados en JavaScript listos para integración cliente/servidor.
