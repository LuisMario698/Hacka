import 'package:flutter/material.dart';
import 'pantallas/pantalla_login.dart';
import 'pantallas/pantalla_home.dart';
import '../servicios/supabase_service.dart';
import '../servicios/auth_service.dart';
import 'tema/servicio_tema.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar servicios
  await ServicioTema().inicializar();
  await SupabaseService.initialize();
  
  // Cargar sesión guardada
  await AuthService.cargarSesion();
  
  runApp(AppMovilSegura());
}

class AppMovilSegura extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ServicioTema(),
      builder: (context, child) {
        final servicioTema = ServicioTema();
        return MaterialApp(
          title: 'Rutas Seguras',
          theme: servicioTema.temaClaro,
          darkTheme: servicioTema.temaOscuro,
          themeMode: servicioTema.esTemaOscuro ? ThemeMode.dark : ThemeMode.light,
          // Verificar si hay sesión activa
          home: AuthService.estaAutenticado()
              ? PantallaHome()
              : LoginScreen(),
          debugShowCheckedModeBanner: false,
          // Rutas nombradas para navegación fácil
          routes: {
            '/login': (context) => LoginScreen(),
            '/home': (context) => PantallaHome(),
          },
        );
      },
    );
  }
}

