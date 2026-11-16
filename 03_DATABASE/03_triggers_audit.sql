-- ============================================================================
-- CHILO ENGLISH - 03_triggers_audit.sql
-- Triggers de integridad, auditoría de seguridad y recompensas automáticas
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_touch_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_users_updated_at ON users;
CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION fn_touch_updated_at();

DROP TRIGGER IF EXISTS trg_progress_updated_at ON user_lesson_progress;
CREATE TRIGGER trg_progress_updated_at
BEFORE UPDATE ON user_lesson_progress FOR EACH ROW EXECUTE FUNCTION fn_touch_updated_at();

DROP TRIGGER IF EXISTS trg_garden_plots_updated_at ON garden_plots;
CREATE TRIGGER trg_garden_plots_updated_at
BEFORE UPDATE ON garden_plots FOR EACH ROW EXECUTE FUNCTION fn_touch_updated_at();

CREATE OR REPLACE FUNCTION fn_init_user_stats()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_stats (user_id, total_xp, leaves_balance, streak_days)
    VALUES (NEW.id, 0, 5, 0)
    ON CONFLICT (user_id) DO NOTHING;

    INSERT INTO security_audit_logs (user_id, event_type, severity, details)
    VALUES (NEW.id, 'ACCOUNT_CREATED', 'info', jsonb_build_object('role', NEW.role));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_init_user_stats ON users;
CREATE TRIGGER trg_init_user_stats
AFTER INSERT ON users FOR EACH ROW EXECUTE FUNCTION fn_init_user_stats();

CREATE OR REPLACE FUNCTION fn_audit_password_change()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.password_hash IS DISTINCT FROM OLD.password_hash THEN
        INSERT INTO security_audit_logs (user_id, event_type, severity, details)
        VALUES (NEW.id, 'PASSWORD_CHANGED', 'warning', jsonb_build_object('changed_at', NOW()));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_password_change ON users;
CREATE TRIGGER trg_audit_password_change
AFTER UPDATE ON users FOR EACH ROW EXECUTE FUNCTION fn_audit_password_change();
