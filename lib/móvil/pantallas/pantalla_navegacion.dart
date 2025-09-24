import 'package:flutter/material.dart';

/// Pantalla de navegación en tiempo real durante la ruta, con instrucciones y botón de finalizar/compartir.
class PantallaNavegacion extends StatelessWidget {
  void _irAlInicio(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181C2E),
      body: Stack(
        children: [
          // Fondo de "mapa" simulado
          Positioned.fill(
            child: Image.asset(
              'assets/mapa_simulado.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.4),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Instrucción de navegación
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Gira a la derecha en Av. Sonora - 100 m',
                  style: TextStyle(
                    color: Color(0xFF181C2E),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          // Ruta resaltada
          Center(
            child: CustomPaint(
              painter: _RutaPainter(),
              child: Container(width: 320, height: 320),
            ),
          ),
          // Botón SOS y botón de inicio
          Positioned(
            left: 24,
            bottom: 36,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'sos_nav',
                  backgroundColor: Color(0xFFFFA726),
                  icon: Icon(Icons.shield, color: Colors.white),
                  label: Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('¡Alerta SOS enviada! (simulado)')),
                    );
                  },
                ),
                SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'inicio_nav',
                  backgroundColor: Color(0xFF415A77),
                  child: Icon(Icons.home, color: Colors.white),
                  onPressed: () => _irAlInicio(context),
                  tooltip: 'Volver al menú',
                ),
              ],
            ),
          ),
          // Acciones de viaje
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF181C2E),
                      shape: StadiumBorder(),
                    ),
                    child: Text('[ Finalizar Viaje ]'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white),
                      shape: StadiumBorder(),
                    ),
                    child: Text('Compartir Viaje'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Viaje compartido (simulado)')),
                      );
                    },
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

/// Dibuja la "ruta" resaltada en el mapa
class _RutaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFFFD600)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.5, size.width * 0.9, size.height * 0.2);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
