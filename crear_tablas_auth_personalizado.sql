-- ============================================
-- SISTEMA DE AUTENTICACIÓN PERSONALIZADO
-- Sin usar Supabase Auth
-- ============================================

-- 1. Crear tabla de roles
CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Insertar roles por defecto
INSERT INTO roles (id, nombre, descripcion) VALUES
(1, 'usuario', 'Usuario final de la aplicación móvil'),
(2, 'moderador', 'Puede gestionar reportes y usuarios'),
(3, 'administrador', 'Acceso completo al sistema'),
(4, 'super_admin', 'Administrador con permisos totales')
ON CONFLICT (nombre) DO NOTHING;

-- Reiniciar el contador de la secuencia
SELECT setval('roles_id_seq', (SELECT MAX(id) FROM roles));

-- 3. Crear tabla de usuarios (sin Supabase Auth)
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password TEXT NOT NULL, -- Se guardará hasheado (bcrypt, SHA-256, etc.)
    rol_id INTEGER NOT NULL DEFAULT 1,
    esta_activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ultimo_login TIMESTAMP WITH TIME ZONE,
    
    -- Relación con tabla roles
    CONSTRAINT fk_rol FOREIGN KEY (rol_id) 
        REFERENCES roles(id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
);

-- 4. Crear índices para mejorar rendimiento
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_rol_id ON usuarios(rol_id);
CREATE INDEX idx_usuarios_esta_activo ON usuarios(esta_activo);
CREATE INDEX idx_usuarios_created_at ON usuarios(created_at);

-- 5. Crear función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. Crear trigger para updated_at
CREATE TRIGGER trigger_actualizar_updated_at
    BEFORE UPDATE ON usuarios
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_updated_at();

-- 7. Crear vista para usuarios con información de rol
CREATE OR REPLACE VIEW v_usuarios_completo AS
SELECT 
    u.id,
    u.nombre,
    u.email,
    u.rol_id,
    r.nombre as rol_nombre,
    r.descripcion as rol_descripcion,
    u.esta_activo,
    u.created_at,
    u.updated_at,
    u.ultimo_login
FROM usuarios u
INNER JOIN roles r ON u.rol_id = r.id;

-- 8. Políticas de seguridad RLS (Row Level Security)
-- Activar RLS
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios pueden ver su propia información
CREATE POLICY "Usuarios pueden ver su propio perfil"
    ON usuarios
    FOR SELECT
    USING (true); -- Temporalmente permisivo, ajustar según necesidad

-- Política: Solo admins pueden insertar usuarios
CREATE POLICY "Solo admins pueden crear usuarios"
    ON usuarios
    FOR INSERT
    WITH CHECK (true); -- Ajustar según lógica de negocio

-- Política: Usuarios pueden actualizar su propio perfil
CREATE POLICY "Usuarios pueden actualizar su perfil"
    ON usuarios
    FOR UPDATE
    USING (true); -- Ajustar según lógica de negocio

-- Política: Solo super admins pueden eliminar usuarios
CREATE POLICY "Solo super admins pueden eliminar"
    ON usuarios
    FOR DELETE
    USING (true); -- Ajustar según lógica de negocio

-- Política: Todos pueden leer roles
CREATE POLICY "Todos pueden ver roles"
    ON roles
    FOR SELECT
    USING (true);

-- 9. Crear función para login (validación de credenciales)
CREATE OR REPLACE FUNCTION login_usuario(
    p_email VARCHAR,
    p_password TEXT
)
RETURNS TABLE (
    id INTEGER,
    nombre VARCHAR,
    email VARCHAR,
    rol_id INTEGER,
    rol_nombre VARCHAR,
    esta_activo BOOLEAN,
    token TEXT -- Puedes generar un token JWT aquí si lo necesitas
) AS $$
DECLARE
    v_usuario usuarios%ROWTYPE;
BEGIN
    -- Buscar usuario por email
    SELECT * INTO v_usuario
    FROM usuarios
    WHERE usuarios.email = p_email
    AND usuarios.esta_activo = true;
    
    -- Verificar si existe el usuario
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Credenciales inválidas';
    END IF;
    
    -- IMPORTANTE: En producción, aquí deberías verificar el password hasheado
    -- Ejemplo con bcrypt: IF crypt(p_password, v_usuario.password) != v_usuario.password
    -- Por ahora, comparación directa (NO SEGURO EN PRODUCCIÓN)
    IF v_usuario.password != p_password THEN
        RAISE EXCEPTION 'Credenciales inválidas';
    END IF;
    
    -- Actualizar último login
    UPDATE usuarios 
    SET ultimo_login = NOW()
    WHERE usuarios.id = v_usuario.id;
    
    -- Retornar información del usuario
    RETURN QUERY
    SELECT 
        v_usuario.id,
        v_usuario.nombre,
        v_usuario.email,
        v_usuario.rol_id,
        r.nombre as rol_nombre,
        v_usuario.esta_activo,
        'TOKEN_PLACEHOLDER' as token -- Aquí generarías un JWT real
    FROM roles r
    WHERE r.id = v_usuario.rol_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Crear función para registrar nuevo usuario
CREATE OR REPLACE FUNCTION registrar_usuario(
    p_nombre VARCHAR,
    p_email VARCHAR,
    p_password TEXT,
    p_rol_id INTEGER DEFAULT 1
)
RETURNS TABLE (
    id INTEGER,
    nombre VARCHAR,
    email VARCHAR,
    mensaje TEXT
) AS $$
DECLARE
    v_nuevo_id INTEGER;
BEGIN
    -- Verificar si el email ya existe
    IF EXISTS (SELECT 1 FROM usuarios WHERE usuarios.email = p_email) THEN
        RAISE EXCEPTION 'El email ya está registrado';
    END IF;
    
    -- IMPORTANTE: En producción, hashear el password
    -- Ejemplo: p_password_hash := crypt(p_password, gen_salt('bf'));
    
    -- Insertar nuevo usuario
    INSERT INTO usuarios (nombre, email, password, rol_id)
    VALUES (p_nombre, p_email, p_password, p_rol_id)
    RETURNING usuarios.id INTO v_nuevo_id;
    
    -- Retornar información del usuario creado
    RETURN QUERY
    SELECT 
        v_nuevo_id,
        p_nombre,
        p_email,
        'Usuario registrado exitosamente' as mensaje;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 11. Crear función para cambiar contraseña
CREATE OR REPLACE FUNCTION cambiar_password(
    p_usuario_id INTEGER,
    p_password_actual TEXT,
    p_password_nuevo TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    v_password_actual TEXT;
BEGIN
    -- Obtener password actual
    SELECT password INTO v_password_actual
    FROM usuarios
    WHERE id = p_usuario_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Usuario no encontrado';
    END IF;
    
    -- Verificar password actual
    IF v_password_actual != p_password_actual THEN
        RAISE EXCEPTION 'Contraseña actual incorrecta';
    END IF;
    
    -- Actualizar password (en producción, hashear)
    UPDATE usuarios
    SET password = p_password_nuevo
    WHERE id = p_usuario_id;
    
    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 12. Insertar usuario administrador por defecto
-- IMPORTANTE: Cambiar estos valores en producción
INSERT INTO usuarios (nombre, email, password, rol_id, esta_activo)
VALUES 
    ('Administrador', 'admin@sistema.com', 'admin123', 3, true),
    ('Usuario Prueba', 'usuario@test.com', 'user123', 1, true)
ON CONFLICT (email) DO NOTHING;

-- ============================================
-- COMENTARIOS IMPORTANTES DE SEGURIDAD
-- ============================================

/*
⚠️ ADVERTENCIAS DE SEGURIDAD:

1. PASSWORDS EN TEXTO PLANO:
   - Este script guarda passwords SIN HASHEAR para simplicidad
   - EN PRODUCCIÓN debes usar bcrypt o SHA-256
   - Instala la extensión pgcrypto: CREATE EXTENSION IF NOT EXISTS pgcrypto;
   - Usa: crypt(password, gen_salt('bf')) para hashear
   - Verifica: crypt(input_password, stored_hash) = stored_hash

2. TOKENS JWT:
   - La función login_usuario retorna un placeholder
   - Debes implementar JWT en tu backend o usar una extensión
   - Considera usar pgjwt: https://github.com/michelp/pgjwt

3. ROW LEVEL SECURITY (RLS):
   - Las políticas están configuradas permisivas (true)
   - Ajusta según tu lógica de negocio
   - Ejemplo: USING (auth.uid() = id) para Supabase Auth

4. VALIDACIÓN DE ENTRADA:
   - Agrega validaciones de email, longitud de password, etc.
   - Usa expresiones regulares para validar formato

5. RATE LIMITING:
   - Implementa límite de intentos de login
   - Considera crear una tabla de intentos_login

6. HTTPS/TLS:
   - Siempre usa conexiones encriptadas en producción

7. AUDITORÍA:
   - Considera crear una tabla de logs de autenticación
   - Registra intentos fallidos, cambios de password, etc.
*/

-- ============================================
-- CONSULTAS ÚTILES PARA VERIFICAR
-- ============================================

-- Ver todos los usuarios con sus roles
SELECT * FROM v_usuarios_completo;

-- Contar usuarios por rol
SELECT r.nombre, COUNT(u.id) as total_usuarios
FROM roles r
LEFT JOIN usuarios u ON r.id = u.rol_id
GROUP BY r.id, r.nombre;

-- Ver usuarios activos
SELECT nombre, email, rol_id, created_at
FROM usuarios
WHERE esta_activo = true
ORDER BY created_at DESC;
