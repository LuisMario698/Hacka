-- ================================================
-- SCRIPT SQL PARA LLENAR BASE DE DATOS DE PRUEBA
-- ================================================
-- Ejecutar en el SQL Editor de Supabase
-- ================================================

-- 1. INSERTAR USUARIOS DE PRUEBA
INSERT INTO usuarios (id, email, nombre, telefono, rol, created_at) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'admin@test.com', 'Administrador Sistema', '+52 638 123 4567', 'administrador', NOW()),
('550e8400-e29b-41d4-a716-446655440002', 'user1@test.com', 'María González', '+52 638 234 5678', 'usuario', NOW()),
('550e8400-e29b-41d4-a716-446655440003', 'user2@test.com', 'Juan Pérez', '+52 638 345 6789', 'usuario', NOW()),
('550e8400-e29b-41d4-a716-446655440004', 'user3@test.com', 'Ana Rodríguez', '+52 638 456 7890', 'usuario', NOW()),
('550e8400-e29b-41d4-a716-446655440005', 'user4@test.com', 'Carlos López', '+52 638 567 8901', 'usuario', NOW());

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

-- 3. INSERTAR RUTAS DE HISTORIAL
INSERT INTO rutas_historial (usuario_id, origen, destino, origen_lat, origen_lon, destino_lat, destino_lon, distancia_km, tiempo_minutos, created_at) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Centro de Puerto Peñasco', 'Zona Hotelera', 31.3167, -113.5361, 31.3200, -113.5300, 4.2, 12, NOW() - INTERVAL '1 day'),
('550e8400-e29b-41d4-a716-446655440002', 'Mercado Municipal', 'Playa Bonita', 31.3150, -113.5380, 31.3220, -113.5280, 6.8, 18, NOW() - INTERVAL '2 days'),
('550e8400-e29b-41d4-a716-446655440003', 'OXXO Constitución', 'Hospital General', 31.3180, -113.5340, 31.3160, -113.5360, 2.1, 7, NOW() - INTERVAL '3 days'),
('550e8400-e29b-41d4-a716-446655440004', 'Escuela Primaria', 'Plaza Comercial', 31.3210, -113.5310, 31.3190, -113.5330, 3.5, 10, NOW() - INTERVAL '5 days'),
('550e8400-e29b-41d4-a716-446655440005', 'Gasolinera PEMEX', 'Restaurante El Capitán', 31.3140, -113.5400, 31.3170, -113.5350, 1.8, 5, NOW() - INTERVAL '1 week'),
('550e8400-e29b-41d4-a716-446655440001', 'Banco Santander', 'Farmacia Guadalajara', 31.3175, -113.5355, 31.3185, -113.5345, 2.9, 8, NOW() - INTERVAL '10 days'),
('550e8400-e29b-41d4-a716-446655440002', 'Casa de Usuario', 'Trabajo en Centro', 31.3130, -113.5390, 31.3167, -113.5361, 5.1, 15, NOW() - INTERVAL '2 weeks'),
('550e8400-e29b-41d4-a716-446655440003', 'Supermercado Ley', 'Casa Familiar', 31.3195, -113.5325, 31.3155, -113.5365, 3.2, 9, NOW() - INTERVAL '3 weeks');

-- 4. INSERTAR NODOS DE SENSORES (OPCIONAL)
INSERT INTO nodos (nombre, descripcion, lat, lon, activo, created_at) VALUES
('Sensor Centro', 'Sensor de calidad del aire en centro de la ciudad', 31.3167, -113.5361, true, NOW()),
('Sensor Zona Hotelera', 'Monitor ambiental en área turística', 31.3200, -113.5300, true, NOW()),
('Sensor Mercado', 'Detector de ruido y calidad del aire', 31.3150, -113.5380, true, NOW()),
('Sensor Escuela', 'Monitor de seguridad escolar', 31.3210, -113.5310, false, NOW()),
('Sensor Malecón', 'Sensor costero de condiciones ambientales', 31.3190, -113.5320, true, NOW());

-- 5. INSERTAR LECTURAS DE SENSORES (OPCIONAL)
INSERT INTO lecturas_sensor (nodo_id, tipo_sensor, valor, unidad, created_at) VALUES
-- Lecturas del Sensor Centro
((SELECT id FROM nodos WHERE nombre = 'Sensor Centro'), 'temperatura', 28.5, '°C', NOW() - INTERVAL '1 hour'),
((SELECT id FROM nodos WHERE nombre = 'Sensor Centro'), 'humedad', 65.2, '%', NOW() - INTERVAL '1 hour'),
((SELECT id FROM nodos WHERE nombre = 'Sensor Centro'), 'ruido', 45.8, 'dB', NOW() - INTERVAL '1 hour'),

-- Lecturas del Sensor Zona Hotelera
((SELECT id FROM nodos WHERE nombre = 'Sensor Zona Hotelera'), 'temperatura', 26.8, '°C', NOW() - INTERVAL '2 hours'),
((SELECT id FROM nodos WHERE nombre = 'Sensor Zona Hotelera'), 'humedad', 72.1, '%', NOW() - INTERVAL '2 hours'),
((SELECT id FROM nodos WHERE nombre = 'Sensor Zona Hotelera'), 'calidad_aire', 85.0, 'AQI', NOW() - INTERVAL '2 hours'),

-- Lecturas del Sensor Mercado
((SELECT id FROM nodos WHERE nombre = 'Sensor Mercado'), 'temperatura', 29.2, '°C', NOW() - INTERVAL '3 hours'),
((SELECT id FROM nodos WHERE nombre = 'Sensor Mercado'), 'ruido', 58.3, 'dB', NOW() - INTERVAL '3 hours'),
((SELECT id FROM nodos WHERE nombre = 'Sensor Mercado'), 'calidad_aire', 78.5, 'AQI', NOW() - INTERVAL '3 hours');

-- 6. INSERTAR TRAMOS DE CALLES (OPCIONAL)
INSERT INTO tramos_calle (nombre, descripcion, inicio_lat, inicio_lon, fin_lat, fin_lon, longitud_metros, estado_iluminacion, created_at) VALUES
('Av. Constitución Norte', 'Tramo principal hacia zona hotelera', 31.3167, -113.5361, 31.3200, -113.5340, 850, 'bueno', NOW()),
('Calle Benito Juárez', 'Vía comercial central', 31.3180, -113.5380, 31.3190, -113.5300, 640, 'regular', NOW()),
('Boulevard Costero', 'Malecón turístico', 31.3150, -113.5320, 31.3220, -113.5280, 1200, 'bueno', NOW()),
('Av. Libertad Sur', 'Acceso a zona residencial', 31.3140, -113.5360, 31.3120, -113.5390, 420, 'malo', NOW()),
('Calle Morelos', 'Conexión con mercado municipal', 31.3160, -113.5380, 31.3150, -113.5380, 350, 'regular', NOW());

-- ================================================
-- VERIFICACIÓN DE DATOS INSERTADOS
-- ================================================

-- Contar registros insertados
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
SELECT 'Tramos Calle' as tabla, COUNT(*) as total FROM tramos_calle;

-- ================================================
-- CONSULTAS DE PRUEBA PARA VERIFICAR
-- ================================================

-- Ver reportes recientes (últimas 24 horas)
-- SELECT titulo, descripcion, lat, lon, estado, created_at 
-- FROM reportes 
-- WHERE created_at >= NOW() - INTERVAL '24 hours'
-- ORDER BY created_at DESC;

-- Ver usuarios creados
-- SELECT email, nombre, rol, created_at FROM usuarios;

-- Ver rutas del último mes
-- SELECT origen, destino, distancia_km, tiempo_minutos, created_at 
-- FROM rutas_historial 
-- WHERE created_at >= NOW() - INTERVAL '1 month'
-- ORDER BY created_at DESC;