-- ================================================
-- SCRIPT PARA CREAR USUARIOS EN SUPABASE AUTH
-- ================================================
-- IMPORTANTE: Ejecutar DESPUÉS del script principal
-- Este script usa funciones internas de Supabase
-- ================================================

-- Crear usuarios en el sistema de autenticación
-- NOTA: Esto podría requerir permisos especiales

-- Alternativa: Usar la función de Supabase para registrar usuarios
-- Este approach funciona mejor desde el código de la aplicación

-- ================================================
-- OPCIÓN RECOMENDADA: CREAR VÍA DASHBOARD
-- ================================================
-- Es más seguro crear los usuarios manualmente desde:
-- Authentication > Users > Add user
-- 
-- Usuarios a crear:
-- 1. admin@test.com / password123
-- 2. user1@test.com / password123  
-- 3. user2@test.com / password123
-- 4. user3@test.com / password123
-- 5. user4@test.com / password123
--
-- IMPORTANTE: Marcar "Auto Confirm User" para cada uno
-- ================================================

-- Si prefieres usar código, crea un script Flutter temporal:
/*
// Script temporal en Flutter para crear usuarios
void main() async {
  await Supabase.initialize(url: 'tu-url', anonKey: 'tu-key');
  
  final usuarios = [
    {'email': 'admin@test.com', 'password': 'password123'},
    {'email': 'user1@test.com', 'password': 'password123'},
    {'email': 'user2@test.com', 'password': 'password123'},
    {'email': 'user3@test.com', 'password': 'password123'},
    {'email': 'user4@test.com', 'password': 'password123'},
  ];
  
  for (final user in usuarios) {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: user['email']!,
        password: user['password']!,
      );
      print('✅ Usuario creado: ${user['email']}');
    } catch (e) {
      print('❌ Error: ${user['email']} - $e');
    }
  }
}
*/