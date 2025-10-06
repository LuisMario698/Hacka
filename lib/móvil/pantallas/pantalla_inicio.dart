import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pantalla_reporte.dart';
import 'pantalla_historial.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'pantalla_perfil.dart';
import 'dart:async';


// Servicios y modelos
import '../../servicios/reporte_service.dart';
import '../../modelos/modelos.dart';

/// Pantalla de inicio y mapa principal, moderna, móvil, con animaciones y transparencias.
class PantallaInicio extends StatefulWidget {
  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio>
    with SingleTickerProviderStateMixin {


  // Zonas seguras (estáticas - puntos de referencia)
  final List<Map<String, dynamic>> zonasSeguras = [
    {
      'centro': LatLng(31.3200, -113.5310),
      'radio': 220.0,
      'descripcion': 'Zona turística, bien iluminada y patrullada.',
    },
    {
      'centro': LatLng(31.3150, -113.5400),
      'radio': 180.0,
      'descripcion': 'Zona residencial segura, vigilancia vecinal.',
    },
  ];
  
  // Zonas peligrosas (dinámicas - basadas en reportes)
  List<Map<String, dynamic>> zonasPeligrosas = [];
  List<Reporte> reportesRecientes = [];
  bool cargandoDatos = true;
  int? zonaPeligrosaTocada; // índice de la zona peligrosa tocada
  double sosOffset = 0.0;
  late AnimationController _sosController;
  late Animation<double> _sosAnimation;

  @override
  void initState() {
    super.initState();
    _sosController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _sosAnimation = Tween<double>(begin: 0, end: 0).animate(_sosController);
    _sosController.addListener(() {
      setState(() {
        sosOffset = _sosAnimation.value;
      });
    });
    
    // Cargar datos reales al inicializar
    _cargarDatosReales();
  }

  /// Cargar reportes recientes y generar zonas peligrosas
  Future<void> _cargarDatosReales() async {
    try {
      setState(() {
        cargandoDatos = true;
      });

      // Obtener reportes en un área alrededor de Puerto Peñasco (20km de radio)
      final reportes = await ReporteService.obtenerReportesEnArea(
        latCentro: 31.3167,
        lonCentro: -113.5361, 
        radioKm: 20.0,
      );

      // Filtrar reportes recientes (últimas 24 horas)
      final ahora = DateTime.now();
      final reportesRecientesTemp = reportes.where((reporte) {
        final tiempoTranscurrido = ahora.difference(reporte.createdAt);
        return tiempoTranscurrido.inHours <= 24;
      }).toList();

      // Generar zonas peligrosas basadas en reportes
      final zonasPeligrosasTemp = <Map<String, dynamic>>[];
      
      for (final reporte in reportesRecientesTemp) {
        // Determinar el radio según el tipo de reporte
        double radio = 150.0; // default
        if (reporte.titulo.toLowerCase().contains('asalto') || 
            reporte.titulo.toLowerCase().contains('robo')) {
          radio = 200.0;
        } else if (reporte.titulo.toLowerCase().contains('sospechoso') ||
                   reporte.titulo.toLowerCase().contains('actividad')) {
          radio = 180.0;
        }

        final tiempoTranscurrido = ahora.difference(reporte.createdAt);
        String tiempoTexto;
        if (tiempoTranscurrido.inHours < 1) {
          tiempoTexto = '${tiempoTranscurrido.inMinutes}m';
        } else {
          tiempoTexto = '${tiempoTranscurrido.inHours}h';
        }

        zonasPeligrosasTemp.add({
          'centro': LatLng(reporte.lat, reporte.lon),
          'radio': radio,
          'motivo': reporte.descripcion ?? reporte.titulo,
          'ultimoReporte': '${reporte.titulo} reportado hace $tiempoTexto',
          'reporte': reporte,
        });
      }

      setState(() {
        reportesRecientes = reportesRecientesTemp;
        zonasPeligrosas = zonasPeligrosasTemp;
        cargandoDatos = false;
      });

    } catch (e) {
      setState(() {
        cargandoDatos = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando datos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
      '&viewbox=-115.0,32.7,-108.4,26.5&bounded=1',
    );
    final resp = await http.get(url, headers: {'User-Agent': 'tefrontend-app'});
    if (resp.statusCode == 200) {
      final List data = json.decode(resp.body);
      setState(() {
        _sugerencias = data
            .where(
              (e) =>
                  (e['display_name']?.toLowerCase().contains('sonora') ??
                      false) ||
                  (e['address']?['state']?.toLowerCase() == 'sonora'),
            )
            .map<Map<String, dynamic>>(
              (e) => {
                'display_name': e['display_name'],
                'lat': double.tryParse(e['lat'] ?? ''),
                'lon': double.tryParse(e['lon'] ?? ''),
              },
            )
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
    _movementTimer?.cancel();
    // No calcular ruta aún
  }

  Future<void> _calcularRuta(LatLng origen, LatLng destino) async {
 try{   final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/foot/${origen.longitude},${origen.latitude};${destino.longitude},${destino.latitude}?overview=full&geometries=geojson',
    );
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final coords = data['routes'][0]['geometry']['coordinates'] as List;
      setState(() {
        _ruta = coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
        _currentRouteIndex = 0;
      });
      _startMovement();
    }}catch(e){print(e);SnackBar(content: Text("Error: {$e}"),);}
  }

  // Puerto Peñasco, Sonora, México
  LatLng ubicacionUsuario = LatLng(
    31.3167,
    -113.5361,
  ); // Simulado: Puerto Peñasco, Sonora
  bool mostrarMenuReporte = false;
  bool activandoSOS = false;
  double progresoSOS = 0.0;
  Timer? _timer;
  Timer? _movementTimer;
  int _currentRouteIndex = 0;



  void _cerrarMenuReporte() {
    setState(() => mostrarMenuReporte = false);
  }

  void _showSOSCountdown(BuildContext context) {
    int secondsLeft = 5;
    Timer? timer;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            timer ??= Timer.periodic(Duration(seconds: 1), (t) {
              setState(() {
                secondsLeft--;
                if (secondsLeft <= 0) {
                  timer?.cancel();
                  Navigator.of(context).pop();
                  _showSOSSentDialog(context);
                }
              });
            });
            return AlertDialog(
              title: Text('SOS'),
              content: Text('Señal SOS será enviada en $secondsLeft segundos'),
              actions: [
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSOSSentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('SOS Enviado'),
          content: Text('Se ha enviado la señal de emergencia.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('SOS cancelado')));
              },
              child: Text('Cancelar SOS'),
            ),
          ],
        );
      },
    );
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
          _showSOSSentDialog(context);
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

  void _startMovement() {
    _movementTimer?.cancel();
    _movementTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_currentRouteIndex < _ruta.length) {
        setState(() {
          ubicacionUsuario = _ruta[_currentRouteIndex];
        });
        _currentRouteIndex++;
        // check distance
        if (_destinoSeleccionado != null) {
          double dist = Distance().as(
            LengthUnit.Meter,
            ubicacionUsuario,
            _destinoSeleccionado!,
          );
          if (dist <= 25) {
            _markCompleted();
            timer.cancel();
          }
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _markCompleted() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Trayecto completado')));
    setState(() {
      _ruta = [];
      _destinoSeleccionado = null;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _movementTimer?.cancel();
    _sosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Mapa interactivo OSM
          Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  center:
                      _destinoSeleccionado ??
                      _pinSeleccionado ??
                      ubicacionUsuario,
                  zoom: 15.5,
                  maxZoom: 18,
                  minZoom: 3,
                  onTap: (tapPos, latlng) {
                    // Detectar si tocó una zona peligrosa
                    for (int i = 0; i < zonasPeligrosas.length; i++) {
                      final zona = zonasPeligrosas[i];
                      final dist = Distance().as(
                        LengthUnit.Meter,
                        latlng,
                        zona['centro'],
                      );
                      if (dist < zona['radio']) {
                        setState(() {
                          zonaPeligrosaTocada = i;
                        });
                        return;
                      }
                    }
                    // Si no tocó zona peligrosa, colocar pin normal
                    setState(() {
                      _pinSeleccionado = latlng;
                      _destinoSeleccionado = null;
                      _ruta = [];
                    });
                    _movementTimer?.cancel();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: Theme.of(context).brightness == Brightness.dark
                        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                    subdomains: ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.example.rutasseguras',
                    backgroundColor: Colors.transparent,
                  ),
                  // Un solo PolygonLayer para todas las zonas, con opacidad alta
                  // Círculos fijos en pantalla para zonas seguras y peligrosas
                  MarkerLayer(
                    markers: [
                      ...zonasSeguras.map(
                        (zona) => Marker(
                          point: zona['centro'],
                          width: 90,
                          height: 90,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.32),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ...zonasPeligrosas.map(
                        (zona) => Marker(
                          point: zona['centro'],
                          width: 90,
                          height: 90,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.error.withOpacity(0.32),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.error.withOpacity(0.7),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Modal de zona peligrosa
                  if (zonaPeligrosaTocada != null)
                    _ModalZonaPeligrosa(
                      motivo: zonasPeligrosas[zonaPeligrosaTocada!]['motivo'],
                      ultimoReporte:
                          zonasPeligrosas[zonaPeligrosaTocada!]['ultimoReporte'],
                      reporte: zonasPeligrosas[zonaPeligrosaTocada!]['reporte'],
                      onClose: () => setState(() => zonaPeligrosaTocada = null),
                    ),
                  // Polyline de la ruta solo si existe
                  if (_ruta.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _ruta,
                          color: Theme.of(context).colorScheme.primary,
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
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.blue,
                            size: 48,
                          ),
                        ),
                      if (_destinoSeleccionado != null)
                        Marker(
                          width: 48,
                          height: 48,
                          point: _destinoSeleccionado!,
                          child: Icon(
                            Icons.flag,
                            color: Theme.of(context).colorScheme.error,
                            size: 44,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              // Botón flotante para iniciar ruta (si hay pin manual o destino seleccionado y no hay ruta)
              if ((_pinSeleccionado != null || _destinoSeleccionado != null) &&
                  _ruta.isEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 110,
                  child: Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00CFFF),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 8,
                      ),
                      icon: Icon(Icons.directions, size: 24),
                      label: Text(
                        'Iniciar ruta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        if (_pinSeleccionado != null) {
                          setState(() {
                            _destinoSeleccionado = _pinSeleccionado;
                            _pinSeleccionado = null;
                          });
                          await _calcularRuta(
                            ubicacionUsuario,
                            _destinoSeleccionado!,
                          );
                        } else if (_destinoSeleccionado != null) {
                          await _calcularRuta(
                            ubicacionUsuario,
                            _destinoSeleccionado!,
                          );
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
                  child: Container(color: Color(0xFF181C2E).withOpacity(0.18)),
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
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withOpacity(0.38),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface, size: 26),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _busquedaController,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: '¿A dónde vas?',
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  border: InputBorder.none,
                                ),
                                onChanged: (v) {
                                  setState(() => _mostrandoSugerencias = true);
                                  _buscarSugerencias(v);
                                },
                                onTap: () => setState(
                                  () => _mostrandoSugerencias = true,
                                ),
                              ),
                            ),
                            if (_busquedaController.text.isNotEmpty)
                              IconButton(
                                icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38)),
                                onPressed: () {
                                  setState(() {
                                    _busquedaController.clear();
                                    _sugerencias = [];
                                    _mostrandoSugerencias = false;
                                    _destinoSeleccionado = null;
                                    _ruta = [];
                                  });
                                  _movementTimer?.cancel();
                                },
                              ),
                          ],
                        ),
                      ),
                      if (_mostrandoSugerencias && _sugerencias.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.95),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(24),
                            ),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _sugerencias.length,
                            itemBuilder: (context, i) {
                              final sug = _sugerencias[i];
                              return ListTile(
                                title: Text(
                                  sug['display_name'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
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
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.26),
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PantallaHistorial(),
                        ),
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
            bottom: 100 + sosOffset,
            child: GestureDetector(
              onLongPressStart: (_) => _iniciarSOS(),
              onLongPressEnd: (_) => _cancelarSOS(),
              onVerticalDragUpdate: (details) {
                setState(() {
                  sosOffset = (sosOffset - details.delta.dy).clamp(0.0, 200.0);
                });
              },
              onVerticalDragEnd: (details) {
                if (sosOffset > 50) {
                  _showSOSCountdown(context);
                }
                _sosAnimation = Tween<double>(
                  begin: sosOffset,
                  end: 0,
                ).animate(_sosController);
                _sosController.forward(from: 0);
              },
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
                  Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Botón cancelar SOS durante activación por long press
          if (activandoSOS)
            Positioned(
              right: 24,
              bottom: 190,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: _cancelarSOS,
                child: Text('Cancelar SOS'),
              ),
            ),

          // Botón de refrescar datos (esquina superior derecha)
          Positioned(
            top: 100,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: cargandoDatos 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                  : Icon(Icons.refresh, color: Colors.blue),
                onPressed: cargandoDatos ? null : _cargarDatosReales,
                tooltip: 'Actualizar datos',
              ),
            ),
          ),
          // Menú flotante de reporte rápido
          if (mostrarMenuReporte) _MenuReporte(onClose: _cerrarMenuReporte),
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

class _MarcadorAnimadoState extends State<_MarcadorAnimado>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
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
                Text(
                  'Reportar incidente',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF181C2E),
                  ),
                ),
                SizedBox(height: 16),
                _BotonReporte(
                  icon: Icons.lightbulb,
                  label: 'Foco Descompuesto',
                  onTap: () =>
                      _enviarReporte(context, 'Foco Descompuesto', onClose),
                  color: Color(0xFFF5F5F5),
                ),
                _BotonReporte(
                  icon: Icons.nightlight_round,
                  label: 'Calle Muy Oscura',
                  onTap: () =>
                      _enviarReporte(context, 'Calle Muy Oscura', onClose),
                  color: Color(0xFFF5F5F5),
                ),
                _BotonReporte(
                  icon: Icons.groups,
                  label: 'Actividad Sospechosa',
                  onTap: () =>
                      _enviarReporte(context, 'Actividad Sospechosa', onClose),
                  color: Color(0xFFF5F5F5),
                ),
                _BotonReporte(
                  icon: Icons.construction,
                  label: 'Banqueta Rota/Peligro',
                  onTap: () =>
                      _enviarReporte(context, 'Banqueta Rota/Peligro', onClose),
                  color: Color(0xFFF5F5F5),
                ),
                _BotonReporte(
                  icon: Icons.local_police,
                  label: 'Presencia Policial',
                  onTap: () =>
                      _enviarReporte(context, 'Presencia Policial', onClose),
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
  const _BotonBarraInferior({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 30),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
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
  final Reporte? reporte; // Información adicional del reporte
  
  const _ModalZonaPeligrosa({
    required this.motivo,
    required this.ultimoReporte,
    required this.onClose,
    this.reporte,
  });
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
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Zona peligrosa',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF181C2E),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    motivo,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Último reporte: $ultimoReporte',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  if (reporte != null) ...[
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estado: ${reporte!.estado.displayName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (reporte!.descripcion != null)
                            Text(
                              'Detalles: ${reporte!.descripcion}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
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
