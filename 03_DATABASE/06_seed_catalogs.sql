-- ============================================================================
-- CHILO ENGLISH - 06_seed_catalogs.sql (Tienda Jardín, Logros y Audios)
-- ============================================================================
INSERT INTO garden_shop_catalog (id, item_kind, name, leaf_cost, stages_json, description) VALUES
  ('sunflower', 'flower', 'Girasol Dorado', 3, '["🌰","🌱","🌿","🌻"]'::jsonb, 'Girasol radiante en maceta de lunares.'),
  ('heart_vine', 'plant', 'Planta Corazón Verde', 4, '["🌰","🌱","🌿","🪴"]'::jsonb, 'Hojas arqueadas en forma de corazón con flor central.'),
  ('cyan_blossom', 'flower', 'Flor Celeste Mágica', 5, '["🌰","🌱","🌷","💠"]'::jsonb, 'Flor turquesa en maceta de cristal azul.'),
  ('rose_royal', 'flower', 'Rosa Real', 4, '["🌰","🌱","🌷","🌹"]'::jsonb, 'Clásica flor perfumada de jardín.'),
  ('shrub_emerald', 'shrub', 'Arbusto Esmeralda', 5, '["🌰","🌱","🌿","🌳"]'::jsonb, 'Arbusto natural para los senderos del jardín.'),
  ('oak_tree', 'tree', 'Roble del Saber', 8, '["🌰","🌱","🌿","🌳"]'::jsonb, 'Árbol frondoso que crece con tus lecciones.'),
  ('cherry_tree', 'tree', 'Cerezo Mágico', 10, '["🌰","🌱","🌳","🌸"]'::jsonb, 'Árbol florido con pétalos suaves.'),
  ('daisy_bright', 'flower', 'Margarita Solar', 2, '["🌰","🌱","🌿","🌼"]'::jsonb, 'Alegre flor de pétalos blancos y centro dorado.'),
  ('bamboo_zen', 'plant', 'Bambú del Aprendizaje', 6, '["🌰","🌱","🎍","🎋"]'::jsonb, 'Planta alta y resistente.'),
  ('fert_boost', 'fertilizer', 'Fertilizante Orgánico', 2, '["🧪"]'::jsonb, 'Acelera el crecimiento en una etapa.'),
  ('butterflies', 'decor', 'Mariposas Celestes', 3, '["🦋"]'::jsonb, 'Mariposas vivas revoloteando entre las flores.'),
  ('stone_path', 'decor', 'Camino de Piedra Natural', 4, '["🪨"]'::jsonb, 'Sendero encantador entre las macetas y el césped.'),
  ('crystal_fountain', 'decor', 'Fuente Cristalina', 7, '["⛲"]'::jsonb, 'Fuente de agua con destellos de luz.'),
  ('garden_lanterns', 'decor', 'Faroles de Luz Suave', 5, '["🏮"]'::jsonb, 'Iluminación cálida para tus plantas.')
ON CONFLICT (id) DO UPDATE SET leaf_cost = EXCLUDED.leaf_cost, name = EXCLUDED.name;

INSERT INTO achievements_catalog (id, category, title, description) VALUES
  ('vuelo_inicial', 'Inicio', 'Vuelo Inicial con Chilo', 'Creaste tu cuenta personal en CHILO ENGLISH.'),
  ('cuestionario_chilo', 'Inicio', 'Compañeros de Aventura', 'Completaste el Cuestionario de Bienvenida de 10 preguntas.'),
  ('primera_leccion', 'Lecciones', 'Primer Paso Firme', 'Completaste tu primera lección interactiva paso a paso.'),
  ('cinco_lecciones', 'Lecciones', 'Ritmo Constante', 'Completaste 5 lecciones dentro de la plataforma.'),
  ('nivel_intermedio', 'Lecciones', 'Impulso Intermedio', 'Avanzaste en la ruta hacia el nivel Intermedio.'),
  ('nivel_avanzado', 'Lecciones', 'Cumbre Avanzada', 'Desbloqueaste o practicaste en el nivel Avanzado.'),
  ('audio_bilingue', 'Audios', 'Oído Internacional', 'Escuchaste audios en inglés estadounidense y británico.'),
  ('pronunciacion_clara', 'Audios', 'Voz Clara', 'Grabaste y comparaste tu pronunciación en el Centro de Audios.'),
  ('coleccion_audios', 'Audios', 'Coleccionista de Frases', 'Guardaste tus expresiones favoritas para repasar.'),
  ('conversacion_activa', 'Práctica', 'Diálogo Fluido', 'Completaste un escenario completo en Conversaciones Interactivas.'),
  ('campeon_juegos', 'Práctica', 'Estratega de Juegos', 'Completaste desafíos en Juegos Educativos.'),
  ('participante_foro', 'Comunidad', 'Voz de la Comunidad', 'Participaste activamente en los Foros Educativos.'),
  ('racha_3', 'Constancia', 'Tres Días Seguidos', 'Mantuviste tu racha de estudio durante 3 días.'),
  ('racha_7', 'Constancia', 'Semana Completa', 'Completaste 7 días consecutivos practicando inglés.'),
  ('jardin_cuidadoso', 'Jardín', 'Guardián del Jardín', 'Regaste y cuidaste tus plantas en el jardín virtual.')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title;
