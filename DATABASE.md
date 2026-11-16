# Documentación Técnica de Base de Datos — CHILO ENGLISH
- **Motor:** PostgreSQL 15+ / Supabase (`pgcrypto` habilitado).
- **Archivos en `03_DATABASE/`:**
  1. `01_schema.sql`: 18 tablas con restricciones `CHECK`, `FOREIGN KEY` e índices.
  2. `02_rls_policies.sql`: Row Level Security por usuario y rol (`student`, `moderator`, `admin`).
  3. `03_triggers_audit.sql`: Triggers para `updated_at`, inicialización de cuenta, auditoría de cambio de contraseña, recompensa automática de lecciones y transacciones del jardín.
  4. `04_stored_procedures.sql`: Procedimientos almacenados (`sp_register_user`, `sp_record_login_attempt`, `sp_complete_lesson_unit`, `sp_buy_garden_item`, `sp_harvest_garden_plot`, `sp_revoke_all_sessions`, `sp_export_user_backup`).
  5. `05_seed_curriculum.sql`: Semilla completa de 3 niveles, 60 temas, 300 unidades y 600 palabras.
  6. `06_seed_catalogs.sql`: Catálogo de tienda del jardín, 15 logros, 27 categorías de audio y 8 categorías de foro.
  7. `07_views_reports.sql`: 5 vistas SQL para progreso (`0/180`, `0/60`, `0/60`), matriz de temas, alertas de seguridad, ranking y resumen del jardín.
- **Archivo unificado en `BASE_DE_DATOS/`:** `chilo_english_full_db.sql` + `db_client.js` + exportaciones JSON.
