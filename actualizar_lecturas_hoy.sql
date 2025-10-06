-- ============================================
-- ACTUALIZAR LECTURAS A FECHA ACTUAL
-- Ejecutar DESPUÉS de insertar_datos_sensores.sql
-- ============================================

-- Este script elimina las lecturas antiguas y genera nuevas
-- lecturas para el día de hoy, así los sensores aparecerán "online"

-- 1. Limpiar lecturas antiguas (opcional)
-- DESCOMENTAR si quieres empezar desde cero:
-- DELETE FROM public.lecturas;

-- 2. Generar lecturas de HOY (últimas 12 horas)
DO $$
DECLARE
    nodo_record RECORD;
    fecha_lectura TIMESTAMP;
    hora_actual INT;
    hora_inicio INT;
    lux_valor DOUBLE PRECISION;
    ruido_valor DOUBLE PRECISION;
BEGIN
    hora_actual := EXTRACT(HOUR FROM NOW());
    
    -- Para cada nodo activo
    FOR nodo_record IN SELECT id, nombre FROM public.nodos WHERE activo = true
    LOOP
        -- Generar lecturas de las últimas 12 horas (cada 30 minutos)
        FOR hora_inicio IN 0..23 LOOP
            -- Solo generar si es dentro de las últimas 12 horas
            IF hora_inicio <= hora_actual OR hora_inicio >= (hora_actual - 12) THEN
                
                -- Lecturas cada 30 minutos
                FOR minuto IN ARRAY[0, 30] LOOP
                    fecha_lectura := DATE_TRUNC('day', NOW()) + 
                                    INTERVAL '1 hour' * hora_inicio + 
                                    INTERVAL '1 minute' * minuto;
                    
                    -- Solo insertar si es antes de ahora
                    IF fecha_lectura <= NOW() THEN
                        -- Simular patrones realistas según la hora
                        IF hora_inicio >= 6 AND hora_inicio <= 18 THEN
                            -- Día: Luz alta, ruido moderado
                            lux_valor := 350 + RANDOM() * 450; -- 350-800 lux
                            ruido_valor := 52 + RANDOM() * 18; -- 52-70 dB
                        ELSIF hora_inicio >= 19 AND hora_inicio <= 23 THEN
                            -- Tarde-noche: Luz media, ruido variable
                            lux_valor := 120 + RANDOM() * 180; -- 120-300 lux
                            ruido_valor := 58 + RANDOM() * 22; -- 58-80 dB
                        ELSE
                            -- Madrugada: Luz baja, ruido bajo
                            lux_valor := 25 + RANDOM() * 75; -- 25-100 lux
                            ruido_valor := 32 + RANDOM() * 23; -- 32-55 dB
                        END IF;
                        
                        -- Ocasionalmente generar alertas (12% de probabilidad)
                        IF RANDOM() < 0.12 THEN
                            IF RANDOM() < 0.5 THEN
                                -- Alerta por luz baja
                                lux_valor := 12 + RANDOM() * 33; -- 12-45 lux
                            ELSE
                                -- Alerta por ruido alto
                                ruido_valor := 83 + RANDOM() * 14; -- 83-97 dB
                            END IF;
                        END IF;
                        
                        -- Insertar lectura
                        INSERT INTO public.lecturas (nodo_id, lux, ruido, fecha)
                        VALUES (nodo_record.id, lux_valor, ruido_valor, fecha_lectura);
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
        
        RAISE NOTICE 'Lecturas de HOY generadas para: %', nodo_record.nombre;
    END LOOP;
END $$;

-- 3. Generar lecturas de los últimos 15 minutos (cada 5 minutos)
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
    
    FOR nodo_record IN SELECT id, nombre FROM public.nodos WHERE activo = true
    LOOP
        -- Lecturas cada 5 minutos en los últimos 15 minutos
        FOR minuto IN 0..2 LOOP
            fecha_lectura := NOW() - INTERVAL '5 minutes' * minuto;
            
            -- Valores según hora del día
            IF hora_actual >= 6 AND hora_actual <= 18 THEN
                lux_valor := 420 + RANDOM() * 280;
                ruido_valor := 56 + RANDOM() * 18;
            ELSIF hora_actual >= 19 AND hora_actual <= 23 THEN
                lux_valor := 130 + RANDOM() * 170;
                ruido_valor := 62 + RANDOM() * 18;
            ELSE
                lux_valor := 35 + RANDOM() * 65;
                ruido_valor := 37 + RANDOM() * 18;
            END IF;
            
            -- Alertas ocasionales (15%)
            IF RANDOM() < 0.15 THEN
                IF RANDOM() < 0.5 THEN
                    lux_valor := 18 + RANDOM() * 27;
                ELSE
                    ruido_valor := 84 + RANDOM() * 11;
                END IF;
            END IF;
            
            INSERT INTO public.lecturas (nodo_id, lux, ruido, fecha)
            VALUES (nodo_record.id, lux_valor, ruido_valor, fecha_lectura);
        END LOOP;
        
        RAISE NOTICE 'Lecturas RECIENTES generadas para: %', nodo_record.nombre;
    END LOOP;
END $$;

-- 4. Verificar que todo esté actualizado
SELECT 
    n.nombre,
    n.activo,
    COUNT(l.identificacion) as lecturas_hoy,
    MAX(l.fecha) as ultima_lectura,
    EXTRACT(EPOCH FROM (NOW() - MAX(l.fecha)))/60 as minutos_desde_ultima
FROM public.nodos n
LEFT JOIN public.lecturas l ON n.id = l.nodo_id 
    AND l.fecha > NOW() - INTERVAL '24 hours'
GROUP BY n.id, n.nombre, n.activo
ORDER BY n.activo DESC, minutos_desde_ultima;

-- 5. Ver estado de sensores
SELECT 
    n.nombre,
    n.activo,
    MAX(l.fecha) as ultima_lectura,
    CASE 
        WHEN n.activo = false THEN '🔴 Offline (Inactivo)'
        WHEN MAX(l.fecha) IS NULL THEN '⚫ Sin Datos'
        WHEN NOW() - MAX(l.fecha) > INTERVAL '24 hours' THEN '🔴 Offline (>24h)'
        WHEN MAX(l.lux) < 50 OR MAX(l.ruido) > 80 THEN '🟠 Alerta'
        ELSE '🟢 Online'
    END as estado
FROM public.nodos n
LEFT JOIN public.lecturas l ON n.id = l.nodo_id
GROUP BY n.id, n.nombre, n.activo
ORDER BY n.activo DESC, estado;

RAISE NOTICE '✅ Lecturas actualizadas a fecha de HOY!';
RAISE NOTICE '📊 Ahora los sensores deberían aparecer como ONLINE';
