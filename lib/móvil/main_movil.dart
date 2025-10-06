import 'package:flutter/material.dart';
import 'pantallas/pantalla_login.dart';
import 'pantallas/pantalla_home.dart';
import '../servicios/theme_service.dart';
import '../servicios/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar servicios
  await ThemeService().initialize();
  await SupabaseService.initialize();
  
  runApp(AppMovilSegura());
}

class AppMovilSegura extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, child) {
        return MaterialApp(
          title: 'Rutas Seguras',
          theme: ThemeService.lightTheme, // Nuevo tema claro accesible
          darkTheme: ThemeService.darkTheme, // Nuevo tema oscuro
          themeMode: ThemeService().isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: LoginScreen(),
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

