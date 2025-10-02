-- ================================================
-- SCRIPT SQL ACTUALIZADO PARA LLENAR BASE DE DATOS DE PRUEBA
-- ================================================
-- Basado en el esquema real de la base de datos
-- Ejecutar en el SQL Editor de Supabase
-- ================================================

-- 1. INSERTAR USUARIOS DE PRUEBA (sin teléfono, con password_hash)
INSERT INTO usuarios (id, email, password_hash, nombre, rol, esta_activo, created_at) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'admin@test.com', '$2b$10$abcdefghijklmnopqrstuvwxyzABCDEF', 'Administrador Sistema', 'administrador', true, NOW()),
('550e8400-e29b-41d4-a716-446655440002', 'user1@test.com', '$2b$10$abcdefghijklmnopqrstuvwxyzABCDEF', 'María González', 'usuario', true, NOW()),
('550e8400-e29b-41d4-a716-446655440003', 'user2@test.com', '$2b$10$abcdefghijklmnopqrstuvwxyzABCDEF', 'Juan Pérez', 'usuario', true, NOW()),
('550e8400-e29b-41d4-a716-446655440004', 'user3@test.com', '$2b$10$abcdefghijklmnopqrstuvwxyzABCDEF', 'Ana Rodríguez', 'usuario', true, NOW()),
('550e8400-e29b-41d4-a716-446655440005', 'user4@test.com', '$2b$10$abcdefghijklmnopqrstuvwxyzABCDEF', 'Carlos López', 'usuario', true, NOW());

-- 2. INSERTAR REPORTES DE PRUEBA EN PUERTO PEÑASCO
INSERT INTO reportes (usuario_id, titulo, descripcion, lat, lon, estado, created_at) VALUES
-- Reportes recientes (últimas 24 horas)
('550e8400-e29b-41d4-a716-446655440001', 'Foco fundido en Av. Constitución', 'El alumbrado público no funciona desde hace 3 días, zona muy oscura por las noches', 31.3180, -113.5340, 'nuevo', NOW() - INTERVAL '2 hours'),
('550e8400-e29b-41d4-a716-446655440002', 'Actividad sospechosa cerca del mercado', 'Personas merodeando vehículos estacionados durante la madrugada', 31.3150, -113.5380, 'nuevo', NOW() - INTERVAL '5 hours'),
('550e8400-e29b-41d4-a716-446655440003', 'Asalto en Calle Benito Juárez', 'Reportan asalto a peatón cerca de la tienda OXXO a las 9:30 PM', 31.3200, -113.5320, 'en_proceso', NOW() - INTERVAL '8 hours'),
('550e8400-e29b-41d4-a716-446655440004', 'Banqueta dañada en Boulevard Costero', 'Banqueta con hoyos profundos, peligroso para peatones y ciclistas', 31.3140, -113.5400, 'nuevo', NOW() - INTERVAL '12 hours'),
('550e8400-e29b-41d4-a716-446655440005', 'Robo de vehículo en zona hotelera', 'Vehículo sustraído del estacionamiento del hotel durante la noche', 31.3220, -113.5300, 'en_proceso', NOW() - INTERVAL '18 hours'),
('550e8400-e29b-41d4-a716-446655440001', 'Alumbrado deficiente en Av. Libertad', 'Varios focos sin funcionar, área muy oscura e insegura', 31.3160, -113.5360, 'nuevo', NOW() - INTERVAL '22 hours'),

-- Reportes de días anteriores
('550e8400-e29b-41d4-a716-446655440002', 'Personas sospechosas en área residencial', 'Individuos revisando casas y vehículos durante horas no habituales', 31.3190, -113.5330, 'resuelto', NOW() - INTERVAL '2 days'),
('550e8400-e29b-41d4-a716-446655440003', 'Intento de asalto en zona comercial', 'Intento de robo a comerciante, logró escapar y pedir ayuda', 31.3170, -113.5350, 'en_proceso', NOW() - INTERVAL '3 days'),
('550e8400-e29b-41d4-a716-446655440004', 'Calle sin iluminación completa', 'Toda una cuadra sin alumbrado público funcional', 31.3130, -113.5390, 'nuevo', NOW() - INTERVAL '4 days'),
('550e8400-e29b-41d4-a716-446655440005', 'Vehículo sospechoso rondando escuela', 'Auto desconocido merodeando zona escolar en horarios extraños', 31.3210, -113.5310, 'resuelto', NOW() - INTERVAL '5 days'),
('550e8400-e29b-41d4-a716-446655440001', 'Robo a casa habitación', 'Sustracción de objetos de valor durante ausencia de propietarios', 31.3120, -113.5370, 'en_proceso', NOW() - INTERVAL '6 days'),
('550e8400-e29b-41d4-a716-446655440002', 'Semáforo descompuesto en crucero principal', 'Semáforo intermitente genera caos vial y riesgo de accidentes', 31.3185, -113.5345, 'nuevo', NOW() - INTERVAL '7 days'),
('550e8400-e29b-41d4-a716-446655440003', 'Grupo sospechoso en parque público', 'Personas consumiendo sustancias y intimidando a familias', 31.3175, -113.5355, 'resuelto', NOW() - INTERVAL '1 week'),
('550e8400-e29b-41d4-a716-446655440004', 'Asalto a turista en malecón', 'Turista despojado de pertenencias mientras caminaba solo', 31.3195, -113.5325, 'en_proceso', NOW() - INTERVAL '10 days'),
('550e8400-e29b-41d4-a716-446655440005', 'Poste de luz caído por viento', 'Poste derribado bloquea parcialmente la vía y deja área sin luz', 31.3155, -113.5365, 'resuelto', NOW() - INTERVAL '2 weeks');

-- 3. INSERTAR RUTAS DE HISTORIAL (con geojson_ruta requerido)
INSERT INTO rutas_historial (usuario_id, origen_lat, origen_lon, destino_lat, destino_lon, geojson_ruta, distancia_km, duracion_estimada_min, seguridad_promedio, created_at) VALUES
('550e8400-e29b-41d4-a716-446655440001', 31.3167, -113.5361, 31.3200, -113.5300, '{"type":"LineString","coordinates":[[-113.5361,31.3167],[-113.5340,31.3180],[-113.5320,31.3190],[-113.5300,31.3200]]}', 4.2, 12, 7, NOW() - INTERVAL '1 day'),
('550e8400-e29b-41d4-a716-446655440002', 31.3150, -113.5380, 31.3220, -113.5280, '{"type":"LineString","coordinates":[[-113.5380,31.3150],[-113.5350,31.3170],[-113.5320,31.3190],[-113.5280,31.3220]]}', 6.8, 18, 8, NOW() - INTERVAL '2 days'),
('550e8400-e29b-41d4-a716-446655440003', 31.3180, -113.5340, 31.3160, -113.5360, '{"type":"LineString","coordinates":[[-113.5340,31.3180],[-113.5350,31.3170],[-113.5360,31.3160]]}', 2.1, 7, 6, NOW() - INTERVAL '3 days'),
('550e8400-e29b-41d4-a716-446655440004', 31.3210, -113.5310, 31.3190, -113.5330, '{"type":"LineString","coordinates":[[-113.5310,31.3210],[-113.5320,31.3200],[-113.5330,31.3190]]}', 3.5, 10, 7, NOW() - INTERVAL '5 days'),
('550e8400-e29b-41d4-a716-446655440005', 31.3140, -113.5400, 31.3170, -113.5350, '{"type":"LineString","coordinates":[[-113.5400,31.3140],[-113.5380,31.3150],[-113.5360,31.3160],[-113.5350,31.3170]]}', 1.8, 5, 8, NOW() - INTERVAL '1 week'),
('550e8400-e29b-41d4-a716-446655440001', 31.3175, -113.5355, 31.3185, -113.5345, '{"type":"LineString","coordinates":[[-113.5355,31.3175],[-113.5350,31.3180],[-113.5345,31.3185]]}', 2.9, 8, 7, NOW() - INTERVAL '10 days'),
('550e8400-e29b-41d4-a716-446655440002', 31.3130, -113.5390, 31.3167, -113.5361, '{"type":"LineString","coordinates":[[-113.5390,31.3130],[-113.5380,31.3140],[-113.5370,31.3150],[-113.5361,31.3167]]}', 5.1, 15, 6, NOW() - INTERVAL '2 weeks'),
('550e8400-e29b-41d4-a716-446655440003', 31.3195, -113.5325, 31.3155, -113.5365, '{"type":"LineString","coordinates":[[-113.5325,31.3195],[-113.5340,31.3180],[-113.5355,31.3165],[-113.5365,31.3155]]}', 3.2, 9, 7, NOW() - INTERVAL '3 weeks');

-- 4. INSERTAR NODOS DE SENSORES (con device_key requerido)
INSERT INTO nodos (nombre, lat, lon, device_key, activo, created_at) VALUES
('Sensor Centro', 31.3167, -113.5361, 'SENSOR_CENTRO_001', true, NOW()),
('Sensor Zona Hotelera', 31.3200, -113.5300, 'SENSOR_HOTEL_002', true, NOW()),
('Sensor Mercado', 31.3150, -113.5380, 'SENSOR_MERCADO_003', true, NOW()),
('Sensor Escuela', 31.3210, -113.5310, 'SENSOR_ESCUELA_004', false, NOW()),
('Sensor Malecón', 31.3190, -113.5320, 'SENSOR_MALECON_005', true, NOW());

-- 5. INSERTAR LECTURAS DE SENSORES (usando tabla lecturas_sensor actualizada)
INSERT INTO lecturas_sensor (fecha, luminosidad, ruido) VALUES
-- Lecturas recientes
(NOW() - INTERVAL '1 hour', 850.5, 45.2),
(NOW() - INTERVAL '2 hours', 920.8, 48.7),
(NOW() - INTERVAL '3 hours', 780.3, 52.1),
(NOW() - INTERVAL '4 hours', 650.9, 39.8),
(NOW() - INTERVAL '5 hours', 720.4, 44.5),
(NOW() - INTERVAL '6 hours', 890.1, 47.3),
(NOW() - INTERVAL '12 hours', 320.7, 35.9),
(NOW() - INTERVAL '18 hours', 180.2, 32.4),
(NOW() - INTERVAL '1 day', 850.6, 46.8),
(NOW() - INTERVAL '2 days', 760.3, 41.2);

-- 6. INSERTAR LECTURAS ANTIGUAS (tabla lecturas con nodo_id)
INSERT INTO lecturas (nodo_id, fecha, lux, ruido_db) VALUES
-- Lecturas del Sensor Centro
((SELECT id FROM nodos WHERE device_key = 'SENSOR_CENTRO_001'), NOW() - INTERVAL '1 hour', 850.5, 45.2),
((SELECT id FROM nodos WHERE device_key = 'SENSOR_CENTRO_001'), NOW() - INTERVAL '2 hours', 920.8, 48.7),
((SELECT id FROM nodos WHERE device_key = 'SENSOR_CENTRO_001'), NOW() - INTERVAL '3 hours', 780.3, 52.1),

-- Lecturas del Sensor Zona Hotelera
((SELECT id FROM nodos WHERE device_key = 'SENSOR_HOTEL_002'), NOW() - INTERVAL '1 hour', 650.9, 39.8),
((SELECT id FROM nodos WHERE device_key = 'SENSOR_HOTEL_002'), NOW() - INTERVAL '2 hours', 720.4, 44.5),
((SELECT id FROM nodos WHERE device_key = 'SENSOR_HOTEL_002'), NOW() - INTERVAL '3 hours', 890.1, 47.3),

-- Lecturas del Sensor Mercado
((SELECT id FROM nodos WHERE device_key = 'SENSOR_MERCADO_003'), NOW() - INTERVAL '1 hour', 320.7, 35.9),
((SELECT id FROM nodos WHERE device_key = 'SENSOR_MERCADO_003'), NOW() - INTERVAL '2 hours', 180.2, 32.4),
((SELECT id FROM nodos WHERE device_key = 'SENSOR_MERCADO_003'), NOW() - INTERVAL '3 hours', 850.6, 46.8);

-- 7. INSERTAR TRAMOS DE CALLES (usando nombres correctos de columnas)
INSERT INTO tramos_calle (nombre_calle, lat_inicio, lon_inicio, lat_fin, lon_fin, nivel_seguridad, ultima_actualizacion) VALUES
('Av. Constitución Norte', 31.3167, -113.5361, 31.3200, -113.5340, 8, NOW()),
('Calle Benito Juárez', 31.3180, -113.5380, 31.3190, -113.5300, 6, NOW()),
('Boulevard Costero', 31.3150, -113.5320, 31.3220, -113.5280, 9, NOW()),
('Av. Libertad Sur', 31.3140, -113.5360, 31.3120, -113.5390, 4, NOW()),
('Calle Morelos', 31.3160, -113.5380, 31.3150, -113.5380, 6, NOW()),
('Calle Revolución', 31.3130, -113.5350, 31.3140, -113.5320, 5, NOW()),
('Av. Miguel Hidalgo', 31.3200, -113.5370, 31.3210, -113.5340, 7, NOW()),
('Calle Allende', 31.3170, -113.5390, 31.3180, -113.5360, 6, NOW());

-- ================================================
-- VERIFICACIÓN DE DATOS INSERTADOS
-- ================================================

-- Contar registros insertados en cada tabla
SELECT 'Usuarios' as tabla, COUNT(*) as total FROM usuarios
UNION ALL
SELECT 'Reportes' as tabla, COUNT(*) as total FROM reportes  
UNION ALL
SELECT 'Rutas Historial' as tabla, COUNT(*) as total FROM rutas_historial
UNION ALL
SELECT 'Nodos' as tabla, COUNT(*) as total FROM nodos
UNION ALL
SELECT 'Lecturas Sensor' as tabla, COUNT(*) as total FROM lecturas_sensor
UNION ALL
SELECT 'Lecturas' as tabla, COUNT(*) as total FROM lecturas
UNION ALL
SELECT 'Tramos Calle' as tabla, COUNT(*) as total FROM tramos_calle;

-- ================================================
-- CONSULTAS DE PRUEBA PARA VERIFICAR DATOS
-- ================================================

-- Ver reportes recientes (últimas 24 horas)
SELECT titulo, lat, lon, estado, created_at 
FROM reportes 
WHERE created_at >= NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;

-- Ver usuarios creados
SELECT email, nombre, rol, esta_activo FROM usuarios;

-- Ver nodos activos
SELECT nombre, lat, lon, device_key, activo FROM nodos WHERE activo = true;

-- Ver lecturas recientes de sensores
SELECT fecha, luminosidad, ruido FROM lecturas_sensor ORDER BY fecha DESC LIMIT 5;

-- ================================================
-- NOTAS IMPORTANTES
-- ================================================
-- 1. Los usuarios tienen password_hash ficticio - para autenticación real
--    necesitarás crearlos también en Supabase Auth
-- 2. Las rutas incluyen geojson_ruta básico requerido por la tabla
-- 3. Los nodos tienen device_key únicos requeridos
-- 4. Los tramos de calle tienen nivel_seguridad del 0-10
-- 5. Hay dos tablas de lecturas: lecturas_sensor y lecturas