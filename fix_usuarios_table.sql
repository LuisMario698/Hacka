-- ========================================
-- FIX: Hacer password_hash compatible con Supabase Auth
-- ========================================
-- Supabase Auth maneja las contraseñas en auth.users
-- La tabla usuarios no necesita password_hash porque es redundante
-- Este script modifica la tabla para que sea compatible

-- OPCIÓN 1: Eliminar la columna password_hash (RECOMENDADO)
-- Supabase Auth ya maneja las contraseñas en auth.users
ALTER TABLE public.usuarios DROP COLUMN IF EXISTS password_hash;

-- OPCIÓN 2 (alternativa): Si quieres mantener la columna por compatibilidad
-- Hacerla nullable y sin constraint
-- ALTER TABLE public.usuarios ALTER COLUMN password_hash DROP NOT NULL;
-- ALTER TABLE public.usuarios DROP CONSTRAINT IF EXISTS usuarios_password_hash_check;
-- ALTER TABLE public.usuarios ALTER COLUMN password_hash SET DEFAULT 'auth_handled';

-- ========================================
-- CREAR TRIGGER para sincronizar con auth.users
-- ========================================
-- Este trigger crea automáticamente el registro en usuarios cuando se crea un usuario en auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.usuarios (id, email, nombre, rol_id, esta_activo)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'nombre', split_part(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'rol_id')::INTEGER, 1),
    true
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Crear trigger en auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ========================================
-- DESACTIVAR CONFIRMACIÓN DE EMAIL (para desarrollo)
-- ========================================
-- Esto se debe hacer en la UI de Supabase:
-- 1. Ve a Authentication > Settings
-- 2. En "Email Auth" desactiva "Enable email confirmations"
-- 3. O ejecuta este SQL (requiere permisos de superadmin):
-- UPDATE auth.config SET enable_signup = true;
-- 
-- Alternativamente, puedes confirmar usuarios manualmente:
-- UPDATE auth.users SET email_confirmed_at = NOW() WHERE email = 'usuario@ejemplo.com';

-- ========================================
-- SCRIPT DE CONFIRMACIÓN AUTOMÁTICA (para desarrollo)
-- ========================================
-- Este trigger confirma automáticamente el email al crear el usuario
CREATE OR REPLACE FUNCTION public.auto_confirm_user()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE auth.users
  SET email_confirmed_at = NOW()
  WHERE id = NEW.id AND email_confirmed_at IS NULL;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_user_created_confirm_email ON auth.users;
CREATE TRIGGER on_user_created_confirm_email
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.auto_confirm_user();

-- ========================================
-- VERIFICAR CAMBIOS
-- ========================================
-- Verificar estructura de tabla
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'usuarios' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Verificar triggers
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE event_object_schema = 'auth' OR event_object_schema = 'public';
