import 'package:flutter/material.dart';
import 'pantallas/pantalla_login_web.dart';
import 'pantallas/pantalla_dashboard_principal.dart';
import '../servicios/theme_service.dart';
import '../servicios/supabase_service.dart';
import '../servicios/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar servicios
  await ThemeService().initialize();
  await SupabaseService.initialize();
  
  // Cargar sesión guardada
  await AuthService.cargarSesion();
  
  runApp(AppWebCentroControl());
}

class AppWebCentroControl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, child) {
        return MaterialApp(
          title: 'Centro de Control - Rutas Seguras',
          theme: ThemeService.lightTheme,
          darkTheme: ThemeService.darkTheme,
          themeMode: ThemeService().isDarkMode ? ThemeMode.dark : ThemeMode.light,
          // Verificar si hay sesión activa y si es admin/moderador
          home: AuthService.estaAutenticado() && (AuthService.esAdmin() || AuthService.esModerador())
              ? PantallaDashboardPrincipal()
              : PantallaLoginWeb(),
          debugShowCheckedModeBanner: false,
          // Rutas nombradas
          routes: {
            '/login': (context) => PantallaLoginWeb(),
            '/dashboard': (context) => PantallaDashboardPrincipal(),
          },
        );
      },
    );
  }
}
