-- ============================================
-- SCRIPT SQL PARA INSERTAR DATOS DE PRUEBA
-- Sistema de Sensores IoT - Rutas Seguras
-- ============================================

-- IMPORTANTE: Ejecutar después de crear las tablas base

-- ============================================
-- 1. INSERTAR NODOS/SENSORES ESP32
-- ============================================

INSERT INTO public.nodos (nombre, clave_del_dispositivo, latitud, longitud, activo) VALUES
('Sensor Parque Central', 'ESP32_PARK_001', 19.4326, -99.1332, true),
('Sensor Av. Juárez Norte', 'ESP32_JUAREZ_002', 19.4350, -99.1350, true),
('Sensor Calle Principal', 'ESP32_MAIN_003', 19.4300, -99.1300, true),
('Sensor Plaza Municipal', 'ESP32_PLAZA_004', 19.4380, -99.1380, true),
('Sensor Zona Escolar', 'ESP32_SCHOOL_005', 19.4320, -99.1320, true),
('Sensor Terminal de Autobuses', 'ESP32_TERM_006', 19.4365, -99.1365, true),
('Sensor Mercado Centro', 'ESP32_MARKET_007', 19.4310, -99.1310, true),
('Sensor Estadio Municipal', 'ESP32_STADIUM_008', 19.4340, -99.1340, false),
('Sensor Parque Deportivo', 'ESP32_SPORT_009', 19.4355, -99.1355, true),
('Sensor Zona Industrial', 'ESP32_INDUST_010', 19.4290, -99.1290, true);

-- ============================================
-- 2. INSERTAR LECTURAS DE LOS ÚLTIMOS 7 DÍAS
-- ============================================

-- Función auxiliar para generar lecturas aleatorias
-- Luz: Rango normal 50-800 lux (baja <50 genera alerta)
-- Ruido: Rango normal 30-75 dB (alto >80 genera alerta)

DO $$
DECLARE
    nodo_record RECORD;
    fecha_lectura TIMESTAMP;
    hora_inicio INT;
    hora_fin INT;
    i INT;
    lux_valor DOUBLE PRECISION;
    ruido_valor DOUBLE PRECISION;
BEGIN
    -- Para cada nodo activo
    FOR nodo_record IN SELECT id, clave_del_dispositivo FROM public.nodos WHERE activo = true
    LOOP
        -- Generar lecturas de los últimos 7 días
        FOR i IN 0..6 LOOP
            fecha_lectura := NOW() - INTERVAL '1 day' * i;
            
            -- Lecturas cada 2 horas (12 lecturas por día)
            FOR hora_inicio IN 0..23 BY 2 LOOP
                fecha_lectura := DATE_TRUNC('day', NOW() - INTERVAL '1 day' * i) + INTERVAL '1 hour' * hora_inicio;
                
                -- Simular patrones realistas según la hora
                IF hora_inicio >= 6 AND hora_inicio <= 18 THEN
                    -- Día: Luz alta, ruido moderado
                    lux_valor := 300 + RANDOM() * 500; -- 300-800 lux
                    ruido_valor := 50 + RANDOM() * 20; -- 50-70 dB
                ELSIF hora_inicio >= 19 AND hora_inicio <= 23 THEN
                    -- Tarde-noche: Luz media, ruido variable
                    lux_valor := 100 + RANDOM() * 200; -- 100-300 lux
                    ruido_valor := 55 + RANDOM() * 25; -- 55-80 dB
                ELSE
                    -- Madrugada: Luz baja, ruido bajo
                    lux_valor := 20 + RANDOM() * 80; -- 20-100 lux
                    ruido_valor := 30 + RANDOM() * 25; -- 30-55 dB
                END IF;
                
                -- Ocasionalmente generar alertas (10% de probabilidad)
                IF RANDOM() < 0.10 THEN
                    IF RANDOM() < 0.5 THEN
                        -- Alerta por luz baja
                        lux_valor := 10 + RANDOM() * 35; -- 10-45 lux
                    ELSE
                        -- Alerta por ruido alto
                        ruido_valor := 82 + RANDOM() * 15; -- 82-97 dB
                    END IF;
                END IF;
                
                -- Insertar lectura
                INSERT INTO public.lecturas (nodo_id, lux, ruido, fecha)
                VALUES (nodo_record.id, lux_valor, ruido_valor, fecha_lectura);
            END LOOP;
        END LOOP;
        
        RAISE NOTICE 'Lecturas generadas para nodo: %', nodo_record.clave_del_dispositivo;
    END LOOP;
END $$;

-- ============================================
-- 3. INSERTAR LECTURAS RECIENTES (ÚLTIMA HORA)
-- ============================================

-- Generar lecturas de los últimos 60 minutos (cada 5 minutos)
DO $$
DECLARE
    nodo_record RECORD;
    fecha_lectura TIMESTAMP;
    minuto INT;
    lux_valor DOUBLE PRECISION;
    ruido_valor DOUBLE PRECISION;
    hora_actual INT;
BEGIN
    hora_actual := EXTRACT(HOUR FROM NOW());
    
    FOR nodo_record IN SELECT id FROM public.nodos WHERE activo = true
    LOOP
        -- Lecturas cada 5 minutos en la última hora
        FOR minuto IN 0..11 LOOP
            fecha_lectura := NOW() - INTERVAL '5 minutes' * minuto;
            
            -- Valores según hora del día
            IF hora_actual >= 6 AND hora_actual <= 18 THEN
                lux_valor := 400 + RANDOM() * 300;
                ruido_valor := 55 + RANDOM() * 20;
            ELSIF hora_actual >= 19 AND hora_actual <= 23 THEN
                lux_valor := 120 + RANDOM() * 180;
                ruido_valor := 60 + RANDOM() * 20;
            ELSE
                lux_valor := 30 + RANDOM() * 70;
                ruido_valor := 35 + RANDOM() * 20;
            END IF;
            
            -- Alertas ocasionales
            IF RANDOM() < 0.15 THEN
                IF RANDOM() < 0.5 THEN
                    lux_valor := 15 + RANDOM() * 30;
                ELSE
                    ruido_valor := 83 + RANDOM() * 12;
                END IF;
            END IF;
            
            INSERT INTO public.lecturas (nodo_id, lux, ruido, fecha)
            VALUES (nodo_record.id, lux_valor, ruido_valor, fecha_lectura);
        END LOOP;
    END LOOP;
END $$;

-- ============================================
-- 4. VERIFICAR DATOS INSERTADOS
-- ============================================

-- Contar nodos
SELECT COUNT(*) as total_nodos FROM public.nodos;

-- Contar nodos activos
SELECT COUNT(*) as nodos_activos FROM public.nodos WHERE activo = true;

-- Contar lecturas totales
SELECT COUNT(*) as total_lecturas FROM public.lecturas;

-- Ver últimas 10 lecturas
SELECT 
    l.identificacion,
    n.nombre as nodo,
    n.clave_del_dispositivo,
    l.lux,
    l.ruido,
    l.fecha
FROM public.lecturas l
JOIN public.nodos n ON l.nodo_id = n.id
ORDER BY l.fecha DESC
LIMIT 10;

-- Ver estadísticas por nodo
SELECT 
    n.nombre,
    n.activo,
    COUNT(l.identificacion) as total_lecturas,
    ROUND(AVG(l.lux)::numeric, 2) as promedio_lux,
    ROUND(AVG(l.ruido)::numeric, 2) as promedio_ruido,
    MAX(l.fecha) as ultima_lectura
FROM public.nodos n
LEFT JOIN public.lecturas l ON n.id = l.nodo_id
GROUP BY n.id, n.nombre, n.activo
ORDER BY n.nombre;

-- Ver lecturas con alertas (últimas 24 horas)
SELECT 
    n.nombre,
    l.lux,
    l.ruido,
    l.fecha,
    CASE 
        WHEN l.lux < 50 AND l.ruido > 80 THEN 'Luz baja y ruido alto'
        WHEN l.lux < 50 THEN 'Iluminación deficiente'
        WHEN l.ruido > 80 THEN 'Ruido excesivo'
    END as tipo_alerta
FROM public.lecturas l
JOIN public.nodos n ON l.nodo_id = n.id
WHERE (l.lux < 50 OR l.ruido > 80)
    AND l.fecha > NOW() - INTERVAL '24 hours'
ORDER BY l.fecha DESC
LIMIT 20;

-- ============================================
-- 5. COMANDOS ÚTILES PARA GESTIÓN
-- ============================================

-- Limpiar todas las lecturas (¡CUIDADO!)
-- DELETE FROM public.lecturas;

-- Desactivar un sensor específico
-- UPDATE public.nodos SET activo = false WHERE clave_del_dispositivo = 'ESP32_STADIUM_008';

-- Activar todos los sensores
-- UPDATE public.nodos SET activo = true;

-- Eliminar lecturas antiguas (más de 30 días)
-- DELETE FROM public.lecturas WHERE fecha < NOW() - INTERVAL '30 days';

-- Ver nodos sin lecturas recientes (últimas 2 horas)
-- SELECT n.* 
-- FROM public.nodos n
-- LEFT JOIN public.lecturas l ON n.id = l.nodo_id AND l.fecha > NOW() - INTERVAL '2 hours'
-- WHERE l.identificacion IS NULL;

RAISE NOTICE '✅ Datos de prueba insertados correctamente!';
RAISE NOTICE '📊 Total de nodos: 10';
RAISE NOTICE '📡 Nodos activos: 9';
RAISE NOTICE '📈 Lecturas generadas: ~900 (7 días + última hora)';
