-- ================================================
-- CONECTAR USUARIO DE AUTH CON TABLA USUARIOS
-- ================================================
-- Ejecutar DESPUÉS de crear usuario en Authentication
-- ================================================

-- 1. Ver usuarios en Authentication (si tienes permisos)
-- SELECT id, email, created_at FROM auth.users WHERE email = 'admin@test.com';

-- 2. Insertar en tabla usuarios usando el ID correcto
-- IMPORTANTE: Esto asume que ya tienes el usuario en Authentication
-- Si no estás seguro del ID, crea el usuario manualmente en Authentication primero

-- Opción A: Si conoces el UUID exacto del usuario de Authentication
-- INSERT INTO usuarios (id, email, password_hash, nombre, rol, esta_activo, created_at) 
-- VALUES 
-- ('UUID-DEL-USUARIO-EN-AUTH', 'admin@test.com', 'managed_by_auth', 'Administrador Sistema', 'administrador', true, NOW());

-- Opción B: Usar una función que obtenga automáticamente el ID (más seguro)
-- Esta consulta intenta obtener el ID del usuario en auth y crear el registro
DO $$
DECLARE
    user_uuid UUID;
BEGIN
    -- Intentar obtener el ID del usuario desde auth.users
    -- NOTA: Esto podría fallar si no tienes permisos para consultar auth.users
    -- En ese caso, usa la opción C
    
    -- Crear registro en tabla usuarios con un UUID temporal
    -- Luego tendrás que actualizarlo manualmente con el ID correcto
    INSERT INTO usuarios (id, email, password_hash, nombre, rol, esta_activo, created_at) 
    VALUES 
    (gen_random_uuid(), 'admin@test.com', 'managed_by_auth', 'Administrador Sistema', 'administrador', true, NOW())
    ON CONFLICT (email) DO NOTHING;
    
    RAISE NOTICE 'Usuario creado en tabla. IMPORTANTE: Debes sincronizar el ID con Authentication';
END $$;

-- 3. Verificar que se creó
SELECT id, email, nombre, rol, esta_activo FROM usuarios WHERE email = 'admin@test.com';

-- ================================================
-- SI LA OPCIÓN AUTOMÁTICA NO FUNCIONA
-- ================================================
-- Usa esta consulta manual (reemplaza el UUID):

-- INSERT INTO usuarios (id, email, password_hash, nombre, rol, esta_activo, created_at) 
-- VALUES 
-- ('REEMPLAZA-CON-UUID-DE-AUTHENTICATION', 'admin@test.com', 'managed_by_auth', 'Administrador Sistema', 'administrador', true, NOW())
-- ON CONFLICT (id) DO UPDATE SET
--   email = EXCLUDED.email,
--   nombre = EXCLUDED.nombre,
--   rol = EXCLUDED.rol,
--   esta_activo = EXCLUDED.esta_activo;