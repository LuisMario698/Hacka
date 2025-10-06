import 'package:flutter/material.dart';
import '../../servicios/auth_service.dart';
import 'pantalla_login.dart';

class PantallaPerfilUsuario extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtener datos del usuario actual
    final userData = AuthService.obtenerSesion();
    final nombre = userData?['nombre'] ?? 'Usuario';
    final email = userData?['email'] ?? '';
    final rolNombre = userData?['rol_nombre'] ?? 'usuario';

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil'),
        backgroundColor: Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF667eea),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              nombre,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              email,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                rolNombre.toUpperCase(),
                style: TextStyle(
                  color: Color(0xFF667eea),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // Mostrar diálogo de confirmación
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Cerrar Sesión'),
                    content: Text('¿Estás seguro que deseas salir?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Cerrar sesión
                          await AuthService.cerrarSesion();
                          
                          // Volver al login
                          Navigator.of(ctx).pop(); // Cerrar diálogo
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Salir'),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.logout),
              label: Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
