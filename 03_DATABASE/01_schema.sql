-- ============================================================================
-- CHILO ENGLISH - 01_schema.sql (PostgreSQL 15+ / Supabase)
-- 18 Tablas normalizadas con restricciones, índices y relaciones
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Usuarios y control de acceso
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(60) UNIQUE NOT NULL,
    email VARCHAR(160) UNIQUE NOT NULL,
    full_name VARCHAR(120) NOT NULL,
    preferred_name VARCHAR(60),
    role VARCHAR(20) NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'moderator', 'admin')),
    password_hash TEXT NOT NULL,
    password_salt TEXT NOT NULL,
    english_level VARCHAR(20) NOT NULL DEFAULT 'Principiante' CHECK (english_level IN ('Principiante', 'Intermedio', 'Avanzado')),
    voice_accent VARCHAR(10) NOT NULL DEFAULT 'en-US' CHECK (voice_accent IN ('en-US', 'en-GB')),
    visual_theme VARCHAR(20) NOT NULL DEFAULT 'classic',
    ranking_visible BOOLEAN NOT NULL DEFAULT TRUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    failed_login_attempts INTEGER NOT NULL DEFAULT 0,
    locked_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Sesiones activas
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash TEXT UNIQUE NOT NULL,
    device_label VARCHAR(120),
    ip_address INET,
    user_agent TEXT,
    is_revoked BOOLEAN NOT NULL DEFAULT FALSE,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Tokens de recuperación de contraseña
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash TEXT UNIQUE NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Cuestionario de bienvenida de Chilo (10 preguntas)
CREATE TABLE IF NOT EXISTS onboarding_answers (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    preferred_name VARCHAR(60),
    age_private INTEGER CHECK (age_private IS NULL OR (age_private BETWEEN 5 AND 110)),
    country VARCHAR(80),
    main_language VARCHAR(60),
    learning_reason VARCHAR(120),
    self_level VARCHAR(40),
    focus_skill VARCHAR(60),
    daily_time VARCHAR(40),
    learning_style VARCHAR(60),
    main_goal VARCHAR(120),
    completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Currículo: Niveles, Temas, Unidades y Vocabulario
CREATE TABLE IF NOT EXISTS levels (
    id SMALLINT PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    name VARCHAR(40) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    total_topics INTEGER NOT NULL,
    total_units INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS topics (
    id SERIAL PRIMARY KEY,
    level_id SMALLINT NOT NULL REFERENCES levels(id) ON DELETE CASCADE,
    topic_order SMALLINT NOT NULL,
    name VARCHAR(120) NOT NULL,
    UNIQUE(level_id, topic_order)
);

CREATE TABLE IF NOT EXISTS units (
    id VARCHAR(24) PRIMARY KEY,
    topic_id INTEGER NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
    unit_order SMALLINT NOT NULL,
    kind VARCHAR(16) NOT NULL CHECK (kind IN ('learn', 'review', 'final')),
    title VARCHAR(160) NOT NULL,
    objective TEXT NOT NULL,
    intro_text TEXT NOT NULL,
    UNIQUE(topic_id, unit_order)
);

CREATE TABLE IF NOT EXISTS vocabulary_items (
    id SERIAL PRIMARY KEY,
    unit_id VARCHAR(24) NOT NULL REFERENCES units(id) ON DELETE CASCADE,
    word_en VARCHAR(120) NOT NULL,
    meaning_es VARCHAR(160) NOT NULL,
    phonetic VARCHAR(120) NOT NULL,
    example_en TEXT NOT NULL,
    example_es TEXT NOT NULL,
    emoji VARCHAR(16)
);

-- 6. Progreso y estadísticas
CREATE TABLE IF NOT EXISTS user_lesson_progress (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    unit_id VARCHAR(24) NOT NULL REFERENCES units(id) ON DELETE CASCADE,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    current_step SMALLINT NOT NULL DEFAULT 0,
    accuracy_pct SMALLINT NOT NULL DEFAULT 0 CHECK (accuracy_pct BETWEEN 0 AND 100),
    xp_earned INTEGER NOT NULL DEFAULT 0,
    duration_sec INTEGER NOT NULL DEFAULT 0,
    completed_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, unit_id)
);

CREATE TABLE IF NOT EXISTS user_stats (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    total_xp INTEGER NOT NULL DEFAULT 0,
    leaves_balance INTEGER NOT NULL DEFAULT 0 CHECK (leaves_balance >= 0),
    streak_days INTEGER NOT NULL DEFAULT 0,
    last_activity_date DATE
);

-- 7. Logros
CREATE TABLE IF NOT EXISTS achievements_catalog (
    id VARCHAR(50) PRIMARY KEY,
    category VARCHAR(40) NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS user_achievements (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id VARCHAR(50) NOT NULL REFERENCES achievements_catalog(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, achievement_id)
);

-- 8. Centro de Audios
CREATE TABLE IF NOT EXISTS audio_categories (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(60) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    sort_order SMALLINT NOT NULL
);

CREATE TABLE IF NOT EXISTS audio_favorites (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vocab_id INTEGER NOT NULL REFERENCES vocabulary_items(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, vocab_id)
);

-- 9. Jardín Virtual 3D, Tienda, Inventario y Transacciones
CREATE TABLE IF NOT EXISTS garden_shop_catalog (
    id VARCHAR(50) PRIMARY KEY,
    item_kind VARCHAR(20) NOT NULL CHECK (item_kind IN ('flower', 'plant', 'shrub', 'tree', 'decor', 'fertilizer')),
    name VARCHAR(100) NOT NULL,
    leaf_cost INTEGER NOT NULL CHECK (leaf_cost >= 0),
    stages_json JSONB,
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS garden_inventory (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_id VARCHAR(50) NOT NULL REFERENCES garden_shop_catalog(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    PRIMARY KEY (user_id, item_id)
);

CREATE TABLE IF NOT EXISTS garden_plots (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plot_index SMALLINT NOT NULL CHECK (plot_index BETWEEN 0 AND 24),
    item_id VARCHAR(50) REFERENCES garden_shop_catalog(id),
    growth_stage SMALLINT NOT NULL DEFAULT 0 CHECK (growth_stage BETWEEN 0 AND 3),
    hydration SMALLINT NOT NULL DEFAULT 100 CHECK (hydration BETWEEN 0 AND 100),
    fertilized BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, plot_index)
);

CREATE TABLE IF NOT EXISTS garden_transactions (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tx_type VARCHAR(20) NOT NULL CHECK (tx_type IN ('earn', 'spend', 'harvest')),
    leaves_delta INTEGER NOT NULL,
    item_id VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 10. Juegos Educativos
CREATE TABLE IF NOT EXISTS game_sessions (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    game_category VARCHAR(60) NOT NULL,
    variant_number INTEGER NOT NULL DEFAULT 1,
    score INTEGER NOT NULL DEFAULT 0,
    accuracy_pct SMALLINT NOT NULL DEFAULT 0,
    leaves_rewarded INTEGER NOT NULL DEFAULT 0,
    played_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 11. Foros Educativos y Moderación
CREATE TABLE IF NOT EXISTS forum_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category VARCHAR(40) NOT NULL,
    title VARCHAR(140) NOT NULL,
    body TEXT NOT NULL,
    is_hidden BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS forum_replies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES forum_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS forum_reports (
    id BIGSERIAL PRIMARY KEY,
    post_id UUID NOT NULL REFERENCES forum_posts(id) ON DELETE CASCADE,
    reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'dismissed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 12. Seguridad, Auditoría y Rate Limiting
CREATE TABLE IF NOT EXISTS security_audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    event_type VARCHAR(60) NOT NULL,
    severity VARCHAR(16) NOT NULL DEFAULT 'info' CHECK (severity IN ('info', 'warning', 'critical')),
    ip_address INET,
    details JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rate_limits (
    rate_key VARCHAR(160) PRIMARY KEY,
    attempts INTEGER NOT NULL DEFAULT 0,
    window_start TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    blocked_until TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_progress_user ON user_lesson_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_user ON security_audit_logs(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_details_gin ON security_audit_logs USING GIN (details);
CREATE INDEX IF NOT EXISTS idx_vocab_unit ON vocabulary_items(unit_id);
