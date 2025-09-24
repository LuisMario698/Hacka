import 'package:flutter/material.dart';

/// Pantalla para mostrar y seleccionar rutas simuladas con detalles visuales.
class PantallaRutas extends StatelessWidget {
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
              color: Colors.black.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Botón SOS y botón de inicio
          Positioned(
            top: 40,
            right: 24,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'sos_rutas',
                  backgroundColor: Color(0xFFFFA726),
                  child: Icon(Icons.shield, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('¡Alerta SOS enviada! (simulado)')),
                    );
                  },
                ),
                SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'inicio_rutas',
                  backgroundColor: Color(0xFF415A77),
                  child: Icon(Icons.home, color: Colors.white),
                  onPressed: () => _irAlInicio(context),
                  tooltip: 'Volver al menú',
                ),
              ],
            ),
          ),
          // Tarjetas de rutas
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 24),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _RutaCard(
                    nombre: 'Ruta Guardián',
                    tiempo: '20 min',
                    distancia: '1.8 km',
                    iluminacion: '95%',
                    color: Color(0xFFFFD600),
                    seleccionada: true,
                  ),
                  SizedBox(height: 12),
                  _RutaCard(
                    nombre: 'Ruta Equilibrada',
                    tiempo: '15 min',
                    distancia: '1.5 km',
                    iluminacion: '80%',
                    color: Color(0xFF00CFFF),
                  ),
                  SizedBox(height: 12),
                  _RutaCard(
                    nombre: 'Ruta Rápida',
                    tiempo: '10 min',
                    distancia: '1.0 km',
                    iluminacion: '60%',
                    color: Color(0xFF1DE9B6),
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

class _RutaCard extends StatelessWidget {
  final String nombre;
  final String tiempo;
  final String distancia;
  final String iluminacion;
  final Color color;
  final bool seleccionada;

  const _RutaCard({
    required this.nombre,
    required this.tiempo,
    required this.distancia,
    required this.iluminacion,
    required this.color,
    this.seleccionada = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: seleccionada ? color.withOpacity(0.15) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: seleccionada ? 2 : 1),
      ),
      child: ListTile(
        leading: Icon(
          seleccionada ? Icons.shield : Icons.directions_walk,
          color: color,
          size: 32,
        ),
        title: Text(
          nombre,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        subtitle: Text('$tiempo • $distancia • $iluminacion iluminada'),
        trailing: seleccionada
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.black,
                  shape: StadiumBorder(),
                ),
                child: Text('[ INICIAR ]'),
                onPressed: () {
                  // Acción de iniciar ruta
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ruta iniciada (simulado)')),
                  );
                },
              )
            : null,
      ),
    );
  }
}
