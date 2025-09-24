import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pantalla_reporte.dart';



import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'pantalla_perfil.dart';
import 'dart:async';
import 'dart:math' as math;



/// Pantalla de inicio y mapa principal, moderna, móvil, con animaciones y transparencias.
class PantallaInicio extends StatefulWidget {
  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> with SingleTickerProviderStateMixin {
  // Genera puntos de un círculo para PolygonLayer
  List<LatLng> _circlePoints(LatLng center, double radius, int points) {
    final d2r = (3.141592653589793 / 180.0);
    final r = radius / 111320.0; // metros a grados aprox
    final pts = List.generate(points, (i) {
      final angle = (360 / points) * i * d2r;
      return LatLng(
        center.latitude + r * math.cos(angle),
        center.longitude + r * math.sin(angle) / math.cos(center.latitude * d2r),
      );
    });
    // Cerrar el polígono repitiendo el primer punto al final
    return [...pts, pts.first];
  }
  // Zonas seguras y peligrosas (ejemplo)
  final List<Map<String, dynamic>> zonasSeguras = [
    {
      'centro': LatLng(31.3200, -113.5310),
      'radio': 220.0,
      'descripcion': 'Zona turística, bien iluminada y patrullada.'
    },
    {
      'centro': LatLng(31.3150, -113.5400),
      'radio': 180.0,
      'descripcion': 'Zona residencial segura, vigilancia vecinal.'
    },
  ];
  final List<Map<String, dynamic>> zonasPeligrosas = [
    {
      'centro': LatLng(31.3185, -113.5450),
      'radio': 180.0,
      'motivo': 'Asaltos recientes en la zona. Evita transitar de noche.',
      'ultimoReporte': 'Asalto reportado hace 1h.'
    },
    {
      'centro': LatLng(31.3120, -113.5340),
      'radio': 150.0,
      'motivo': 'Zona con poca iluminación y actividad sospechosa.',
      'ultimoReporte': 'Actividad sospechosa reportada hace 3h.'
    },
  ];
  int? zonaPeligrosaTocada; // índice de la zona peligrosa tocada
  // --- Para búsqueda y rutas ---
  final TextEditingController _busquedaController = TextEditingController();
  List<Map<String, dynamic>> _sugerencias = [];
  bool _mostrandoSugerencias = false;
  LatLng? _destinoSeleccionado;
  List<LatLng> _ruta = [];
  LatLng? _pinSeleccionado;

  Future<void> _buscarSugerencias(String query) async {
    if (query.isEmpty) {
      setState(() => _sugerencias = []);
      return;
    }
    // Bounding box de Sonora, México (aprox):
    // left,top,right,bottom: -115.0, 32.7, -108.4, 26.5
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?'
      'q=$query&format=json&addressdetails=1&limit=6'
      '&countrycodes=mx'
      '&viewbox=-115.0,32.7,-108.4,26.5&bounded=1'
    );
    final resp = await http.get(url, headers: {'User-Agent': 'tefrontend-app'});
    if (resp.statusCode == 200) {
      final List data = json.decode(resp.body);
      setState(() {
        _sugerencias = data
          .where((e) =>
            (e['display_name']?.toLowerCase().contains('sonora') ?? false) ||
            (e['address']?['state']?.toLowerCase() == 'sonora')
          )
          .map<Map<String, dynamic>>((e) => {
            'display_name': e['display_name'],
            'lat': double.tryParse(e['lat'] ?? ''),
            'lon': double.tryParse(e['lon'] ?? ''),
          })
          .where((e) => e['lat'] != null && e['lon'] != null)
          .toList();
      });
    }
  }

  Future<void> _seleccionarSugerencia(Map<String, dynamic> sug) async {
    final destino = LatLng(sug['lat'], sug['lon']);
    setState(() {
      _destinoSeleccionado = destino;
      _mostrandoSugerencias = false;
      _busquedaController.text = sug['display_name'];
      _sugerencias = [];
      _ruta = [];
      _pinSeleccionado = null;
    });
    // No calcular ruta aún
  }

  Future<void> _calcularRuta(LatLng origen, LatLng destino) async {
    final url = Uri.parse('https://router.project-osrm.org/route/v1/foot/${origen.longitude},${origen.latitude};${destino.longitude},${destino.latitude}?overview=full&geometries=geojson');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final coords = data['routes'][0]['geometry']['coordinates'] as List;
      setState(() {
        _ruta = coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
      });
    }
  }
  // Puerto Peñasco, Sonora, México
  final LatLng ubicacionUsuario = LatLng(31.3167, -113.5361); // Simulado: Puerto Peñasco, Sonora
  bool mostrarMenuReporte = false;
  bool activandoSOS = false;
  double progresoSOS = 0.0;
  Timer? _timer;

  void _abrirMenuReporte() {
    setState(() => mostrarMenuReporte = true);
  }
  void _cerrarMenuReporte() {
    setState(() => mostrarMenuReporte = false);
  }

  void _iniciarSOS() {
    setState(() {
      activandoSOS = true;
      progresoSOS = 0.0;
    });
    _timer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      setState(() {
        progresoSOS += 0.02;
        if (progresoSOS >= 1.0) {
          progresoSOS = 1.0;
          activandoSOS = false;
          timer.cancel();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('¡SOS activado! (simulado)')),
          );
        }
      });
    });
  }
  void _cancelarSOS() {
    setState(() {
      activandoSOS = false;
      progresoSOS = 0.0;
    });
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181C2E),
      body: Stack(
        children: [
          // Mapa interactivo OSM
          Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  center: _destinoSeleccionado ?? _pinSeleccionado ?? ubicacionUsuario,
                  zoom: 15.5,
                  maxZoom: 18,
                  minZoom: 3,
                  onTap: (tapPos, latlng) {
                    // Detectar si tocó una zona peligrosa
                    for (int i = 0; i < zonasPeligrosas.length; i++) {
                      final zona = zonasPeligrosas[i];
                      final dist = Distance().as(LengthUnit.Meter, latlng, zona['centro']);
                      if (dist < zona['radio']) {
                        setState(() { zonaPeligrosaTocada = i; });
                        return;
                      }
                    }
                    // Si no tocó zona peligrosa, colocar pin normal
                    setState(() {
                      _pinSeleccionado = latlng;
                      _destinoSeleccionado = null;
                      _ruta = [];
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                    subdomains: ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.example.rutasseguras',
                    backgroundColor: Colors.transparent,
                  ),
                  // Un solo PolygonLayer para todas las zonas, con opacidad alta
                  // Círculos fijos en pantalla para zonas seguras y peligrosas
                  MarkerLayer(
                    markers: [
                      ...zonasSeguras.map((zona) => Marker(
                        point: zona['centro'],
                        width: 90,
                        height: 90,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green.withOpacity(0.32),
                            border: Border.all(color: Colors.green.withOpacity(0.7), width: 2),
                          ),
                        ),
                      )),
                      ...zonasPeligrosas.map((zona) => Marker(
                        point: zona['centro'],
                        width: 90,
                        height: 90,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.32),
                            border: Border.all(color: Colors.red.withOpacity(0.7), width: 2),
                          ),
                        ),
                      )),
                    ],
                  ),
// Modal de zona peligrosa
if (zonaPeligrosaTocada != null)
  _ModalZonaPeligrosa(
    motivo: zonasPeligrosas[zonaPeligrosaTocada!]['motivo'],
    ultimoReporte: zonasPeligrosas[zonaPeligrosaTocada!]['ultimoReporte'],
    onClose: () => setState(() => zonaPeligrosaTocada = null),
  ),
                  // Polyline de la ruta solo si existe
                  if (_ruta.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _ruta,
                          color: Color(0xFF00CFFF),
                          strokeWidth: 7,
                        ),
                      ],
                    ),
                  // Marcadores
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80,
                        height: 80,
                        point: ubicacionUsuario,
                        child: _MarcadorAnimado(),
                      ),
                      if (_pinSeleccionado != null)
                        Marker(
                          width: 48,
                          height: 48,
                          point: _pinSeleccionado!,
                          child: const Icon(Icons.location_pin, color: Color(0xFF00CFFF), size: 48),
                        ),
                      if (_destinoSeleccionado != null)
                        Marker(
                          width: 48,
                          height: 48,
                          point: _destinoSeleccionado!,
                          child: const Icon(Icons.flag, color: Color(0xFFFF3B30), size: 44),
                        ),
                    ],
                  ),
                ],
              ),
          // Botón flotante para iniciar ruta (si hay pin manual o destino seleccionado y no hay ruta)
          if ((_pinSeleccionado != null || _destinoSeleccionado != null) && _ruta.isEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 110,
              child: Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00CFFF),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    elevation: 8,
                  ),
                  icon: Icon(Icons.directions, size: 24),
                  label: Text('Iniciar ruta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    if (_pinSeleccionado != null) {
                      setState(() {
                        _destinoSeleccionado = _pinSeleccionado;
                        _pinSeleccionado = null;
                      });
                      await _calcularRuta(ubicacionUsuario, _destinoSeleccionado!);
                    } else if (_destinoSeleccionado != null) {
                      await _calcularRuta(ubicacionUsuario, _destinoSeleccionado!);
                    }
                  },
                ),
              ),
            ),

          // Botón pequeño para quitar el pin manual (solo si hay pin manual y no hay ruta)
          if (_pinSeleccionado != null && _ruta.isEmpty)
            Positioned(
              bottom: 120,
              left: 24,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                onPressed: () {
                  setState(() {
                    _pinSeleccionado = null;
                  });
                },
                child: Icon(Icons.close, color: Colors.black87),
                heroTag: 'quitar_pin',
                elevation: 4,
                tooltip: 'Quitar pin',
              ),
            ),
              // Filtro de color/transparencia sobre el mapa
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Color(0xFF181C2E).withOpacity(0.18),
                  ),
                ),
              ),
            ],
          ),
          // Buscador premium interactivo (centrado arriba, fuente más pequeña)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 340,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.white, size: 26),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _busquedaController,
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  hintText: '¿A dónde vas?',
                                  hintStyle: TextStyle(color: Colors.white38, fontSize: 18, fontWeight: FontWeight.w600),
                                  border: InputBorder.none,
                                ),
                                onChanged: (v) {
                                  setState(() => _mostrandoSugerencias = true);
                                  _buscarSugerencias(v);
                                },
                                onTap: () => setState(() => _mostrandoSugerencias = true),
                              ),
                            ),
                            if (_busquedaController.text.isNotEmpty)
                              IconButton(
                                icon: Icon(Icons.clear, color: Colors.white38),
                                onPressed: () {
                                  setState(() {
                                    _busquedaController.clear();
                                    _sugerencias = [];
                                    _mostrandoSugerencias = false;
                                    _destinoSeleccionado = null;
                                    _ruta = [];
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                      if (_mostrandoSugerencias && _sugerencias.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.95),
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _sugerencias.length,
                            itemBuilder: (context, i) {
                              final sug = _sugerencias[i];
                              return ListTile(
                                title: Text(sug['display_name'], style: TextStyle(color: Colors.white, fontSize: 15)),
                                onTap: () => _seleccionarSugerencia(sug),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Barra inferior gris oscuro con botones de navegación
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFF23243A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón historial de rutas
                  _BotonBarraInferior(
                    icon: Icons.route,
                    label: 'Historial',
                    onTap: () {
                      // TODO: Navegar a historial de rutas
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Historial de rutas (simulado)')),
                      );
                    },
                  ),
                  // Botón de reportes
                  _BotonBarraInferior(
                    icon: Icons.campaign,
                    label: 'Reportar',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PantallaReporte(),
                        ),
                      );
                    },
                  ),
                  // Botón cuenta
                  _BotonBarraInferior(
                    icon: Icons.person,
                    label: 'Cuenta',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PantallaPerfil(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Botón SOS flotante en la esquina inferior derecha, más arriba de la barra
          Positioned(
            right: 24,
            bottom: 100,
            child: GestureDetector(
              onLongPressStart: (_) => _iniciarSOS(),
              onLongPressEnd: (_) => _cancelarSOS(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFF7043),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFF7043).withOpacity(0.25),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: CircularProgressIndicator(
                      value: activandoSOS ? progresoSOS : 0,
                      backgroundColor: Colors.white.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 6,
                    ),
                  ),
                  Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26)),
                ],
              ),
            ),
          ),
          // Menú flotante de reporte rápido
          if (mostrarMenuReporte)
            _MenuReporte(onClose: _cerrarMenuReporte),
        ],
      ),
    );
  }
}

/// Marcador animado para la ubicación del usuario
class _MarcadorAnimado extends StatefulWidget {
  @override
  State<_MarcadorAnimado> createState() => _MarcadorAnimadoState();
}
class _MarcadorAnimadoState extends State<_MarcadorAnimado> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat(reverse: true);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double scale = 1 + 0.15 * _controller.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 48 * scale,
              height: 48 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00CFFF).withOpacity(0.18),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00CFFF).withOpacity(0.25),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00CFFF),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Icon(Icons.my_location, color: Colors.white, size: 18),
            ),
          ],
        );
      },
    );
  }
}

/// Menú modal de reporte rápido
class _MenuReporte extends StatelessWidget {
  final VoidCallback onClose;
  const _MenuReporte({required this.onClose});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.25),
        child: Center(
          child: Container(
            margin: EdgeInsets.only(right: 32, bottom: 100),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(28),
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
                Text('Reportar incidente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF181C2E))),
                SizedBox(height: 16),
                _BotonReporte(
                  icon: Icons.lightbulb,
                  label: 'Foco Descompuesto',
                  onTap: () => _enviarReporte(context, 'Foco Descompuesto', onClose),
                  color: Color(0xFFF5F5F5),
                ),
                _BotonReporte(
                  icon: Icons.nightlight_round,
                  label: 'Calle Muy Oscura',
                  onTap: () => _enviarReporte(context, 'Calle Muy Oscura', onClose),
                  color: Color(0xFFF5F5F5),
                ),
                _BotonReporte(
                  icon: Icons.groups,
                  label: 'Actividad Sospechosa',
                  onTap: () => _enviarReporte(context, 'Actividad Sospechosa', onClose),
                  color: Color(0xFFF5F5F5),
                ),
                _BotonReporte(
                  icon: Icons.construction,
                  label: 'Banqueta Rota/Peligro',
                  onTap: () => _enviarReporte(context, 'Banqueta Rota/Peligro', onClose),
                  color: Color(0xFFF5F5F5),
                ),
                _BotonReporte(
                  icon: Icons.local_police,
                  label: 'Presencia Policial',
                  onTap: () => _enviarReporte(context, 'Presencia Policial', onClose),
                  color: Color(0xFFF5F5F5),
                ),
                SizedBox(height: 8),
                TextButton(onPressed: onClose, child: Text('Cancelar')),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _enviarReporte(BuildContext context, String tipo, VoidCallback onClose) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reporte enviado: $tipo (simulado)')),
    );
    onClose();
  }
}

/// Botón individual para el menú de reporte rápido
/// Botón individual para el menú de reporte rápido, menos llamativo y más sutil visualmente

class _BotonReporte extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _BotonReporte({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = const Color(0xFFF5F5F5),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Color(0xFFE0E0E0)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Color(0xFFBDBDBD)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Color(0xFF181C2E),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



/// Botón para la barra inferior de navegación
class _BotonBarraInferior extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BotonBarraInferior({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
// Fin del archivo

// Modal para mostrar motivo de zona peligrosa
class _ModalZonaPeligrosa extends StatelessWidget {
  final String motivo;
  final String ultimoReporte;
  final VoidCallback onClose;
  const _ModalZonaPeligrosa({required this.motivo, required this.ultimoReporte, required this.onClose});
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black.withOpacity(0.35),
          child: Center(
            child: Container(
              width: 320,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 18)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 48),
                  SizedBox(height: 12),
                  Text('Zona peligrosa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF181C2E))),
                  SizedBox(height: 10),
                  Text(motivo, style: TextStyle(fontSize: 16, color: Colors.black87)),
                  SizedBox(height: 14),
                  Text('Último reporte: $ultimoReporte', style: TextStyle(fontSize: 14, color: Colors.black54)),
                  SizedBox(height: 18),
                  ElevatedButton(onPressed: onClose, child: Text('Cerrar')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Fin del archivo
