

import 'dart:ui';
import 'package:flutter/material.dart';
import 'configuracion_movil.dart';

/// Pantalla de perfil/cuenta de usuario, elegante y completa.
class PantallaPerfil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Mi cuenta', style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onBackground),
      ),
      body: Stack(
        children: [
          // Fondo premium con degradado y glass
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.background,
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).colorScheme.background,
                ],
              ),
            ),
          ),
          // Glassmorphism sutil
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.07),
                ),
              ),
            ),
          ),
          // Contenido principal
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar sin recuadro detrás
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.85, end: 1.0),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimary, size: 68),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Usuario Simulado',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'usuario@simulado.com',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 17, letterSpacing: 0.1),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Tarjeta de información glass
                  _TarjetaGlass(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified_user, color: Theme.of(context).colorScheme.secondary, size: 28),
                            SizedBox(width: 12),
                            Text('Cuenta verificada', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 19)),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.phone_android, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 24),
                            SizedBox(width: 12),
                            Text('Teléfono: +52 55 1234 5678', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), fontSize: 17)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 24),
                            SizedBox(width: 12),
                            Text('Ciudad: CDMX', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), fontSize: 17)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Opciones de cuenta animadas
                  _OpcionPerfil(
                    icon: Icons.settings,
                    texto: 'Configuración',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ConfiguracionMovil()),
                      );
                    },
                  ),
                  _OpcionPerfil(
                    icon: Icons.security,
                    texto: 'Privacidad y seguridad',
                    onTap: () {},
                  ),
                  _OpcionPerfil(
                    icon: Icons.help_outline,
                    texto: 'Ayuda',
                    onTap: () {},
                  ),
                  _OpcionPerfil(
                    icon: Icons.info_outline,
                    texto: 'Acerca de',
                    onTap: () {},
                  ),
                  const SizedBox(height: 18),
                  // Botón cerrar sesión
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                      ),
                      icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.onError, size: 28),
                      label: Text('Cerrar sesión', style: TextStyle(color: Theme.of(context).colorScheme.onError, fontWeight: FontWeight.bold, fontSize: 20)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sesión cerrada (simulado)')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Versión 1.0.0',
                    style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.4), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta glassmorphism premium
class _TarjetaGlass extends StatelessWidget {
  final Widget child;
  const _TarjetaGlass({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3), width: 1.2),
      ),
      child: child,
    );
  }
}

/// Widget para opción de menú en el perfil

class _OpcionPerfil extends StatelessWidget {
  final IconData icon;
  final String texto;
  final VoidCallback onTap;
  const _OpcionPerfil({required this.icon, required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.15),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 30),
        title: Text(
          texto,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), size: 22),
        onTap: onTap,
      ),
    );
  }
}
