-- ============================================================================
-- CHILO ENGLISH - 07_views_reports.sql (Vistas analíticas y de seguridad)
-- ============================================================================
CREATE OR REPLACE VIEW v_user_level_progress AS
SELECT
    u.id AS user_id,
    l.id AS level_id,
    l.name AS level_name,
    l.total_units,
    COALESCE(COUNT(p.id) FILTER (WHERE p.completed = TRUE), 0) AS completed_units,
    ROUND((COALESCE(COUNT(p.id) FILTER (WHERE p.completed = TRUE), 0)::numeric / GREATEST(l.total_units, 1)) * 100) AS progress_pct
FROM users u
CROSS JOIN levels l
LEFT JOIN topics t ON t.level_id = l.id
LEFT JOIN units un ON un.topic_id = t.id
LEFT JOIN user_lesson_progress p ON p.user_id = u.id AND p.unit_id = un.id
GROUP BY u.id, l.id, l.name, l.total_units;

CREATE OR REPLACE VIEW v_topic_completion_matrix AS
SELECT
    u.id AS user_id,
    l.name AS level_name,
    t.topic_order,
    t.name AS topic_name,
    COUNT(un.id) AS total_units,
    COUNT(p.id) FILTER (WHERE p.completed = TRUE) AS completed_units
FROM users u
CROSS JOIN topics t
JOIN levels l ON l.id = t.level_id
JOIN units un ON un.topic_id = t.id
LEFT JOIN user_lesson_progress p ON p.user_id = u.id AND p.unit_id = un.id
GROUP BY u.id, l.name, t.topic_order, t.name;

CREATE OR REPLACE VIEW v_security_alerts AS
SELECT id, user_id, event_type, severity, ip_address, details, created_at
FROM security_audit_logs
WHERE severity IN ('warning', 'critical')
ORDER BY created_at DESC;

CREATE OR REPLACE VIEW v_leaderboard_public AS
SELECT u.username, COALESCE(u.preferred_name, u.full_name) AS display_name, u.english_level, s.total_xp, s.streak_days
FROM users u
JOIN user_stats s ON s.user_id = u.id
WHERE u.ranking_visible = TRUE AND u.is_active = TRUE
ORDER BY s.total_xp DESC;

CREATE OR REPLACE VIEW v_garden_summary AS
SELECT u.id AS user_id, s.leaves_balance, COUNT(gp.id) FILTER (WHERE gp.item_id IS NOT NULL) AS planted_plots
FROM users u
JOIN user_stats s ON s.user_id = u.id
LEFT JOIN garden_plots gp ON gp.user_id = u.id
GROUP BY u.id, s.leaves_balance;
