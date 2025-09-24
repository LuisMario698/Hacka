

import 'dart:ui';
import 'package:flutter/material.dart';

/// Pantalla de perfil/cuenta de usuario, elegante y completa.
class PantallaPerfil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF181C2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mi cuenta', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Fondo premium con degradado y glass
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF23243A),
                  Color(0xFF181C2E),
                  Color(0xFF23243A),
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
                  color: Colors.white.withOpacity(0.07),
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
                          backgroundColor: const Color(0xFF23243A),
                          child: const Icon(Icons.person, color: Colors.white, size: 68),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Usuario Simulado',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'usuario@simulado.com',
                      style: TextStyle(color: Colors.white70, fontSize: 17, letterSpacing: 0.1),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Tarjeta de información glass
                  _TarjetaGlass(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.verified_user, color: Colors.white70, size: 28),
                            SizedBox(width: 12),
                            Text('Cuenta verificada', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 19)),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: const [
                            Icon(Icons.phone_android, color: Colors.white38, size: 24),
                            SizedBox(width: 12),
                            Text('Teléfono: +52 55 1234 5678', style: TextStyle(color: Colors.white70, fontSize: 17)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: const [
                            Icon(Icons.location_on, color: Colors.white38, size: 24),
                            SizedBox(width: 12),
                            Text('Ciudad: CDMX', style: TextStyle(color: Colors.white70, fontSize: 17)),
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
                    onTap: () {},
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
                        backgroundColor: const Color(0xCCFF3B30), // Rojo transparente
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                      label: const Text('Cerrar sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sesión cerrada (simulado)')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Versión 1.0.0',
                    style: TextStyle(color: Colors.white24, fontSize: 13),
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
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.13), width: 1.2),
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
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 30),
        title: Text(
          texto,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 22),
        onTap: onTap,
      ),
    );
  }
}
