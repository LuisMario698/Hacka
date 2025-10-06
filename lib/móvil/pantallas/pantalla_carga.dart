import 'dart:async';
import 'package:flutter/material.dart';
import 'pantalla_inicio.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;
  late Widget _pantallaPrecargada;
  late final AnimationController _dotsController;
  late final List<Animation<double>> _dotOpacities;

  @override
  void initState() {
    super.initState();

    // ✅ Preconstruimos PantallaInicio
    _pantallaPrecargada = PantallaInicio();

    // Pulso del logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animación de los 3 puntos
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _dotOpacities = List.generate(3, (i) {
      final start = i * 0.15;
      final end = start + 0.6;
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.0), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.2), weight: 50),
      ]).animate(
        CurvedAnimation(
          parent: _dotsController,
          curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeInOut),
        ),
      );
    });

    // ✅ Precargar y luego navegar
    _iniciarPrecarga();
  }

  Future<void> _iniciarPrecarga() async {
    await precargarMapa();
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => _pantallaPrecargada));
    }
  }

  /// Aquí simulas carga del mapa/datos
  Future<void> precargarMapa() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0D2C47);
    const titleColor = Colors.white;
    const subtitleColor = Colors.white70;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo con pulso
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 110,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 22),

                const Text(
                  'INICIA SESIÓN',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Accede a tus rutas seguras.',
                  style: TextStyle(color: subtitleColor, fontSize: 14),
                ),
                const SizedBox(height: 36),

                // Indicador de carga
                Column(
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        return AnimatedBuilder(
                          animation: _dotsController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _dotOpacities[i].value,
                              child: child,
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
