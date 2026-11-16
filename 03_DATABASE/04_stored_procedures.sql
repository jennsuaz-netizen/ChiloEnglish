-- ============================================================================
-- CHILO ENGLISH - 04_stored_procedures.sql
-- Procedimientos almacenados transaccionales y de seguridad
-- ============================================================================

-- 1. Registrar intento de inicio de sesión con bloqueo tras 5 fallos (15 min)
CREATE OR REPLACE FUNCTION sp_record_login_attempt(
    p_user_id UUID,
    p_success BOOLEAN,
    p_ip INET DEFAULT NULL
) RETURNS TABLE(is_locked BOOLEAN, locked_until TIMESTAMPTZ) AS $$
DECLARE
    v_attempts INTEGER;
    v_locked_until TIMESTAMPTZ;
BEGIN
    IF p_success THEN
        UPDATE users SET failed_login_attempts = 0, locked_until = NULL WHERE id = p_user_id;
        INSERT INTO security_audit_logs (user_id, event_type, severity, ip_address)
        VALUES (p_user_id, 'LOGIN_SUCCESS', 'info', p_ip);
        RETURN QUERY SELECT FALSE, NULL::TIMESTAMPTZ;
    ELSE
        UPDATE users
        SET failed_login_attempts = failed_login_attempts + 1,
            locked_until = CASE WHEN failed_login_attempts + 1 >= 5 THEN NOW() + INTERVAL '15 minutes' ELSE locked_until END
        WHERE id = p_user_id
        RETURNING failed_login_attempts, users.locked_until INTO v_attempts, v_locked_until;

        INSERT INTO security_audit_logs (user_id, event_type, severity, ip_address, details)
        VALUES (p_user_id, 'LOGIN_FAILED', 'warning', p_ip, jsonb_build_object('attempts', v_attempts));

        RETURN QUERY SELECT (v_locked_until IS NOT NULL AND v_locked_until > NOW()), v_locked_until;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 2. Completar unidad de aprendizaje y otorgar XP + Hojas + Racha
CREATE OR REPLACE FUNCTION sp_complete_lesson_unit(
    p_user_id UUID,
    p_unit_id VARCHAR(24),
    p_accuracy SMALLINT,
    p_xp INTEGER,
    p_duration_sec INTEGER
) RETURNS VOID AS $$
DECLARE
    v_already_done BOOLEAN;
    v_leaves_reward INTEGER := 2;
BEGIN
    SELECT completed INTO v_already_done
    FROM user_lesson_progress
    WHERE user_id = p_user_id AND unit_id = p_unit_id;

    INSERT INTO user_lesson_progress (user_id, unit_id, completed, accuracy_pct, xp_earned, duration_sec, completed_at)
    VALUES (p_user_id, p_unit_id, TRUE, p_accuracy, p_xp, p_duration_sec, NOW())
    ON CONFLICT (user_id, unit_id) DO UPDATE SET
        completed = TRUE,
        accuracy_pct = GREATEST(user_lesson_progress.accuracy_pct, EXCLUDED.accuracy_pct),
        xp_earned = user_lesson_progress.xp_earned + EXCLUDED.xp_earned,
        duration_sec = user_lesson_progress.duration_sec + EXCLUDED.duration_sec,
        completed_at = COALESCE(user_lesson_progress.completed_at, NOW());

    IF NOT COALESCE(v_already_done, FALSE) THEN
        UPDATE user_stats
        SET total_xp = total_xp + p_xp,
            leaves_balance = leaves_balance + v_leaves_reward,
            streak_days = CASE
                WHEN last_activity_date = CURRENT_DATE THEN streak_days
                WHEN last_activity_date = CURRENT_DATE - 1 THEN streak_days + 1
                ELSE 1
            END,
            last_activity_date = CURRENT_DATE
        WHERE user_id = p_user_id;

        INSERT INTO garden_transactions (user_id, tx_type, leaves_delta, item_id)
        VALUES (p_user_id, 'earn', v_leaves_reward, p_unit_id);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 3. Compra atómica en la Tienda del Jardín 3D
CREATE OR REPLACE FUNCTION sp_buy_garden_item(
    p_user_id UUID,
    p_item_id VARCHAR(50),
    p_qty INTEGER DEFAULT 1
) RETURNS INTEGER AS $$
DECLARE
    v_cost INTEGER;
    v_balance INTEGER;
    v_total INTEGER;
BEGIN
    IF p_qty <= 0 THEN RAISE EXCEPTION 'Cantidad inválida'; END IF;
    SELECT leaf_cost INTO v_cost FROM garden_shop_catalog WHERE id = p_item_id;
    IF v_cost IS NULL THEN RAISE EXCEPTION 'Artículo no encontrado en catálogo'; END IF;

    v_total := v_cost * p_qty;
    SELECT leaves_balance INTO v_balance FROM user_stats WHERE user_id = p_user_id FOR UPDATE;
    IF v_balance < v_total THEN RAISE EXCEPTION 'Saldo de hojas insuficiente'; END IF;

    UPDATE user_stats SET leaves_balance = leaves_balance - v_total WHERE user_id = p_user_id RETURNING leaves_balance INTO v_balance;

    INSERT INTO garden_inventory (user_id, item_id, quantity)
    VALUES (p_user_id, p_item_id, p_qty)
    ON CONFLICT (user_id, item_id) DO UPDATE SET quantity = garden_inventory.quantity + EXCLUDED.quantity;

    INSERT INTO garden_transactions (user_id, tx_type, leaves_delta, item_id)
    VALUES (p_user_id, 'spend', -v_total, p_item_id);

    RETURN v_balance;
END;
$$ LANGUAGE plpgsql;

-- 4. Revocar todas las sesiones activas de un usuario
CREATE OR REPLACE FUNCTION sp_revoke_all_sessions(p_user_id UUID) RETURNS INTEGER AS $$
DECLARE v_count INTEGER;
BEGIN
    UPDATE user_sessions SET is_revoked = TRUE WHERE user_id = p_user_id AND is_revoked = FALSE;
    GET DIAGNOSTICS v_count = ROW_COUNT;
    INSERT INTO security_audit_logs (user_id, event_type, severity, details)
    VALUES (p_user_id, 'SESSIONS_REVOKED', 'warning', jsonb_build_object('revoked_count', v_count));
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- 5. Exportar respaldo completo en JSONB por usuario
CREATE OR REPLACE FUNCTION sp_export_user_backup(p_user_id UUID) RETURNS JSONB AS $$
BEGIN
    RETURN jsonb_build_object(
        'exported_at', NOW(),
        'profile', (SELECT row_to_json(u) FROM (SELECT id, username, email, full_name, preferred_name, english_level, voice_accent FROM users WHERE id = p_user_id) u),
        'stats', (SELECT row_to_json(s) FROM user_stats s WHERE s.user_id = p_user_id),
        'onboarding', (SELECT row_to_json(o) FROM onboarding_answers o WHERE o.user_id = p_user_id),
        'progress', COALESCE((SELECT jsonb_agg(row_to_json(p)) FROM user_lesson_progress p WHERE p.user_id = p_user_id), '[]'::jsonb),
        'garden_plots', COALESCE((SELECT jsonb_agg(row_to_json(g)) FROM garden_plots g WHERE g.user_id = p_user_id), '[]'::jsonb),
        'achievements', COALESCE((SELECT jsonb_agg(row_to_json(a)) FROM user_achievements a WHERE a.user_id = p_user_id), '[]'::jsonb)
    );
END;
$$ LANGUAGE plpgsql;
