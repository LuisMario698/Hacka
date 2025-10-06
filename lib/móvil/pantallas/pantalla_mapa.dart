
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Pantalla principal con mapa interactivo OpenStreetMap, búsqueda y botón SOS.
class PantallaMapa extends StatelessWidget {
  void _irAlInicio(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  final LatLng ubicacionUsuario = LatLng(19.4326, -99.1332); // CDMX ejemplo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181C2E),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: ubicacionUsuario,
              zoom: 15.5,
              maxZoom: 18,
              minZoom: 3,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.rutasseguras',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 60,
                    height: 60,
                    point: ubicacionUsuario,
                    child: Icon(Icons.location_on, size: 48, color: Color(0xFF00CFFF)),
                  ),
                ],
              ),
            ],
          ),
          // Encabezado y búsqueda
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Guardián',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Text(
                              '¿A dónde vas?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(Icons.search, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Botón SOS y megáfono
          Positioned(
            left: 24,
            bottom: 36,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'sos',
                  backgroundColor: Color(0xFFFFA726),
                  icon: Icon(Icons.shield, color: Colors.white),
                  label: Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    // Acción SOS simulada
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('¡Alerta SOS enviada! (simulado)')),
                    );
                  },
                ),
                SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'inicio',
                  backgroundColor: Color(0xFF415A77),
                  child: Icon(Icons.home, color: Colors.white),
                  onPressed: () => _irAlInicio(context),
                  tooltip: 'Volver al menú',
                ),
              ],
            ),
          ),
          Positioned(
            right: 24,
            bottom: 36,
            child: FloatingActionButton(
              heroTag: 'megafono',
              backgroundColor: Colors.white,
              child: Icon(Icons.campaign, color: Color(0xFF181C2E)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notificación enviada (simulado)')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
