-- ================================================
-- SQL PARA SINCRONIZAR USUARIOS EXISTENTES
-- ================================================
-- Ejecutar SOLO si ya tienes usuarios en Authentication
-- ================================================

-- Verificar usuarios en auth.users (tabla interna)
-- NOTA: Esto podría no funcionar sin permisos especiales
-- SELECT id, email, created_at FROM auth.users;

-- Si tienes usuarios específicos en Auth, puedes insertarlos manualmente:
-- REEMPLAZA los UUIDs con los IDs reales de tus usuarios en Auth

-- Ejemplo: Si tienes un usuario admin@test.com en Auth con ID específico
INSERT INTO usuarios (id, email, password_hash, nombre, rol, esta_activo, created_at) 
VALUES 
-- IMPORTANTE: Reemplaza estos UUIDs con los reales de tu Auth
('REEMPLAZA-CON-UUID-REAL-DE-AUTH', 'admin@test.com', 'managed_by_auth', 'Administrador Sistema', 'administrador', true, NOW()),
('REEMPLAZA-CON-UUID-REAL-DE-AUTH', 'user1@test.com', 'managed_by_auth', 'María González', 'usuario', true, NOW())
ON CONFLICT (id) DO NOTHING; -- No duplicar si ya existe

-- ================================================
-- CONSULTA PARA VERIFICAR SINCRONIZACIÓN
-- ================================================
SELECT 
  u.email,
  u.nombre,
  u.rol,
  u.esta_activo,
  u.created_at
FROM usuarios u
ORDER BY u.created_at DESC;