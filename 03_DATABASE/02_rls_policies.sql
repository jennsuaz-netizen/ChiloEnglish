-- ============================================================================
-- CHILO ENGLISH - 02_rls_policies.sql
-- Políticas de Row Level Security (RLS) por usuario y rol
-- ============================================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE password_reset_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE onboarding_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE audio_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE garden_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE garden_plots ENABLE ROW LEVEL SECURITY;
ALTER TABLE garden_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_replies ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE security_audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY users_self_select ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY users_self_update ON users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY sessions_owner ON user_sessions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY reset_owner ON password_reset_tokens FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY onboarding_owner ON onboarding_answers FOR ALL USING (auth.uid() = user_id);
CREATE POLICY progress_owner ON user_lesson_progress FOR ALL USING (auth.uid() = user_id);
CREATE POLICY stats_owner ON user_stats FOR ALL USING (auth.uid() = user_id);
CREATE POLICY achievements_owner ON user_achievements FOR ALL USING (auth.uid() = user_id);
CREATE POLICY audio_fav_owner ON audio_favorites FOR ALL USING (auth.uid() = user_id);
CREATE POLICY garden_inv_owner ON garden_inventory FOR ALL USING (auth.uid() = user_id);
CREATE POLICY garden_plots_owner ON garden_plots FOR ALL USING (auth.uid() = user_id);
CREATE POLICY garden_tx_owner ON garden_transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY games_owner ON game_sessions FOR ALL USING (auth.uid() = user_id);

CREATE POLICY forum_read_visible ON forum_posts FOR SELECT USING (is_hidden = FALSE OR auth.uid() = user_id);
CREATE POLICY forum_insert_auth ON forum_posts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY forum_delete_owner ON forum_posts FOR DELETE USING (auth.uid() = user_id);
CREATE POLICY replies_read_all ON forum_replies FOR SELECT USING (TRUE);
CREATE POLICY replies_insert_auth ON forum_replies FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY reports_insert_auth ON forum_reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY audit_self_read ON security_audit_logs FOR SELECT USING (auth.uid() = user_id);
