import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../modelos/nodo_model.dart';
import '../../servicios/nodo_service.dart';
import '../tema/tema_profesional.dart';
import '../componentes/componentes_ui_profesionales.dart';
import '../componentes/boton_panico_mejorado.dart';

class PantallaMapaInteractivo extends StatefulWidget {
  @override
  State<PantallaMapaInteractivo> createState() => _PantallaMapaInteractivoState();
}

class _PantallaMapaInteractivoState extends State<PantallaMapaInteractivo> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<Nodo> _nodos = [];
  bool _isLoading = true;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  LatLng? _destinoSeleccionado;
  List<LatLng>? _rutaGenerada;
  
  // Ubicación por defecto (Puerto Peñasco, Sonora)
  final LatLng _centroMapa = LatLng(31.3167, -113.5361);
  LatLng _ubicacionActual = LatLng(31.3167, -113.5361);

  @override
  void initState() {
    super.initState();
    _cargarNodos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarNodos() async {
    try {
      final nodos = await NodoService.obtenerTodosLosNodos();
      setState(() {
        _nodos = nodos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar sensores: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Actualizar PaletaProfesional según el tema actual
    final isDark = Theme.of(context).brightness == Brightness.dark;
    PaletaProfesional.setTemaOscuro(isDark);
    
    return Scaffold(
      appBar: AppBarConsistente(
        titulo: 'Mapa Seguro',
        acciones: [
          Container(
            margin: EdgeInsets.only(right: EspaciadoProfesional.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: PaletaProfesional.secundarioSuave,
                    borderRadius: BorderRadius.circular(RadiosProfesionales.sm),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.my_location_rounded),
                    color: PaletaProfesional.secundario,
                    onPressed: _centrarEnUbicacion,
                    tooltip: 'Mi ubicación',
                  ),
                ),
                SizedBox(width: EspaciadoProfesional.sm),
                Container(
                  decoration: BoxDecoration(
                    color: PaletaProfesional.primarioSuave,
                    borderRadius: BorderRadius.circular(RadiosProfesionales.sm),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.refresh_rounded),
                    color: PaletaProfesional.primario,
                    onPressed: _cargarNodos,
                    tooltip: 'Actualizar sensores',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mapa principal
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _centroMapa,
                    zoom: 15.0,
                    minZoom: 12.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.tefrontend',
                    ),
                    // Línea de ruta si existe
                    if (_rutaGenerada != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _rutaGenerada!,
                            strokeWidth: 4.0,
                            color: PaletaProfesional.primario,
                            borderStrokeWidth: 2.0,
                            borderColor: Colors.white,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        ..._crearMarcadoresSensores(),
                        // Marcador de ubicación actual
                        Marker(
                          point: _ubicacionActual,
                          width: 50,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        // Marcador de destino si existe
                        if (_destinoSeleccionado != null)
                          Marker(
                            point: _destinoSeleccionado!,
                            width: 50,
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.place,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
          
          // Buscador de lugares
          _construirBuscador(),
          
          // Botones de zoom (abajo a la izquierda)
          _construirControlesZoom(),
          
          // Botón SOS (abajo a la derecha)
          _construirBotonSOS(),
          
          // Información de ruta si existe
          if (_rutaGenerada != null)
            _construirInfoRuta(),
        ],
      ),
    );
  }

  List<Marker> _crearMarcadoresSensores() {
    return _nodos.map((nodo) {
      final nivelSeguridad = _calcularNivelSeguridad(nodo);
      final color = _obtenerColorPorSeguridad(nivelSeguridad);
      final icono = _obtenerIconoPorEstado(nodo);
      
      return Marker(
        point: LatLng(nodo.latitud, nodo.longitud),
        width: 60,
        height: 60,
        child: GestureDetector(
          onTap: () => _mostrarInfoSensor(nodo),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icono,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      );
    }).toList();
  }

  int _calcularNivelSeguridad(Nodo nodo) {
    // Simulación de cálculo basado en datos del sensor
    if (!nodo.activo) return 0; // Offline
    
    // En una implementación real, esto vendría de las lecturas del sensor
    final lux = nodo.ultimoLux ?? 500;
    final ruido = nodo.ultimoRuido ?? 40;
    
    int puntuacion = 5; // Base
    
    // Evaluar luminosidad (más luz = más seguro)
    if (lux > 800) puntuacion += 3;
    else if (lux > 400) puntuacion += 1;
    else if (lux < 200) puntuacion -= 2;
    
    // Evaluar ruido (menos ruido = más seguro)
    if (ruido < 35) puntuacion += 2;
    else if (ruido < 50) puntuacion += 1;
    else if (ruido > 70) puntuacion -= 2;
    
    return puntuacion.clamp(1, 10);
  }

  Color _obtenerColorPorSeguridad(int nivel) {
    if (nivel <= 3) return Colors.red.shade700;        // Peligroso
    if (nivel <= 6) return Colors.orange.shade700;     // Precaución
    return Colors.green.shade700;                       // Seguro
  }

  IconData _obtenerIconoPorEstado(Nodo nodo) {
    if (!nodo.activo) return Icons.sensor_occupied;     // Offline
    
    final nivel = _calcularNivelSeguridad(nodo);
    if (nivel <= 3) return Icons.dangerous;
    if (nivel <= 6) return Icons.warning;
    return Icons.shield;
  }

  Widget _construirBuscador() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: PaletaProfesional.fondoTarjeta,
          borderRadius: BorderRadius.circular(RadiosProfesionales.lg),
          border: Border.all(
            color: PaletaProfesional.divider,
            width: 1,
          ),
          boxShadow: SombrasProfesionales.elevacion2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo de búsqueda
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
                borderRadius: BorderRadius.circular(RadiosProfesionales.lg),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: EspaciadoProfesional.md,
                    vertical: EspaciadoProfesional.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: PaletaProfesional.primario,
                        size: 24,
                      ),
                      SizedBox(width: EspaciadoProfesional.sm),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar lugar o dirección...',
                            hintStyle: TextStyle(
                              color: PaletaProfesional.textoSecundario,
                              fontSize: TipografiaProfesional.body2,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(
                            color: PaletaProfesional.textoPrimario,
                            fontSize: TipografiaProfesional.body1,
                          ),
                          onChanged: (value) {
                            if (value.length > 2) {
                              _buscarLugares(value);
                            } else if (value.isEmpty) {
                              setState(() {
                                _searchResults.clear();
                              });
                            }
                          },
                          onTap: () {
                            setState(() {
                              _isSearching = true;
                            });
                          },
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: PaletaProfesional.textoTerciario,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchResults.clear();
                              _isSearching = false;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Resultados de búsqueda con información detallada
            if (_isSearching && _searchResults.isNotEmpty)
              Container(
                constraints: BoxConstraints(maxHeight: 400),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: PaletaProfesional.divider,
                      width: 1,
                    ),
                  ),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    final destino = LatLng(
                      double.parse(result['lat']),
                      double.parse(result['lon']),
                    );
                    final distancia = _calcularDistancia(_ubicacionActual, destino);
                    final tiempoCaminando = (distancia / 5 * 60).round(); // 5 km/h
                    final tiempoCarro = (distancia / 40 * 60).round(); // 40 km/h
                    final categoria = result['category'] ?? 'Lugar';
                    
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: PaletaProfesional.divider.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _seleccionarDestino(result);
                          },
                          child: Padding(
                            padding: EdgeInsets.all(EspaciadoProfesional.md),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ícono del lugar
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: PaletaProfesional.primarioSuave,
                                    borderRadius: BorderRadius.circular(RadiosProfesionales.md),
                                  ),
                                  child: Icon(
                                    _obtenerIconoCategoria(categoria),
                                    color: PaletaProfesional.primario,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: EspaciadoProfesional.md),
                                // Información del lugar
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Nombre del lugar
                                      Text(
                                        result['name'] ?? 'Sin nombre',
                                        style: TextStyle(
                                          color: PaletaProfesional.textoPrimario,
                                          fontSize: TipografiaProfesional.body1,
                                          fontWeight: TipografiaProfesional.semibold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      // Categoría
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: PaletaProfesional.secundarioSuave,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          categoria,
                                          style: TextStyle(
                                            color: PaletaProfesional.secundario,
                                            fontSize: 10,
                                            fontWeight: TipografiaProfesional.medium,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      // Dirección
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            size: 14,
                                            color: PaletaProfesional.textoTerciario,
                                          ),
                                          SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              result['display_name'] ?? '',
                                              style: TextStyle(
                                                color: PaletaProfesional.textoSecundario,
                                                fontSize: TipografiaProfesional.caption,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      // Información de distancia y tiempo
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: PaletaProfesional.fondoApp,
                                          borderRadius: BorderRadius.circular(RadiosProfesionales.sm),
                                        ),
                                        child: Row(
                                          children: [
                                            // Distancia
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.straighten,
                                                    size: 16,
                                                    color: PaletaProfesional.primario,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '${distancia.toStringAsFixed(2)} km',
                                                    style: TextStyle(
                                                      color: PaletaProfesional.textoPrimario,
                                                      fontSize: TipografiaProfesional.caption,
                                                      fontWeight: TipografiaProfesional.semibold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Tiempo caminando
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.directions_walk,
                                                    size: 16,
                                                    color: PaletaProfesional.secundario,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '$tiempoCaminando min',
                                                    style: TextStyle(
                                                      color: PaletaProfesional.textoPrimario,
                                                      fontSize: TipografiaProfesional.caption,
                                                      fontWeight: TipografiaProfesional.medium,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Tiempo en carro
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.directions_car,
                                                    size: 16,
                                                    color: PaletaProfesional.seguro,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '$tiempoCarro min',
                                                    style: TextStyle(
                                                      color: PaletaProfesional.textoPrimario,
                                                      fontSize: TipografiaProfesional.caption,
                                                      fontWeight: TipografiaProfesional.medium,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Botón de dirección
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: PaletaProfesional.textoTerciario,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirControlesZoom() {
    // Calcular el desplazamiento vertical si hay ruta activa
    final bottomOffset = _rutaGenerada != null ? 96.0 : 16.0; // 96 para dar espacio al panel de ruta
    
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: bottomOffset,
      left: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: PaletaProfesional.fondoTarjeta,
              borderRadius: BorderRadius.circular(RadiosProfesionales.sm),
              border: Border.all(
                color: PaletaProfesional.divider,
                width: 1,
              ),
              boxShadow: SombrasProfesionales.elevacion1,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom + 1,
                ),
                borderRadius: BorderRadius.circular(RadiosProfesionales.sm),
                child: Icon(
                  Icons.add,
                  color: PaletaProfesional.primario,
                  size: 24,
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: PaletaProfesional.fondoTarjeta,
              borderRadius: BorderRadius.circular(RadiosProfesionales.sm),
              border: Border.all(
                color: PaletaProfesional.divider,
                width: 1,
              ),
              boxShadow: SombrasProfesionales.elevacion1,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom - 1,
                ),
                borderRadius: BorderRadius.circular(RadiosProfesionales.sm),
                child: Icon(
                  Icons.remove,
                  color: PaletaProfesional.primario,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirBotonSOS() {
    // Calcular el desplazamiento vertical si hay ruta activa
    final bottomOffset = _rutaGenerada != null ? 96.0 : 16.0;
    
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: bottomOffset,
      right: 16,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.orange,
          boxShadow: SombrasProfesionales.elevacion2,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Activar emergencia
              ServicioEmergencia.activarAlertaEmergencia(context);
            },
            borderRadius: BorderRadius.circular(32),
            child: Center(
              child: Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirInfoRuta() {
    final distancia = _calcularDistancia(_ubicacionActual, _destinoSeleccionado!);
    final tiempoEstimado = (distancia / 5 * 60).round(); // Asumiendo 5 km/h caminando
    
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: EdgeInsets.all(EspaciadoProfesional.md),
        decoration: BoxDecoration(
          color: PaletaProfesional.fondoTarjeta,
          borderRadius: BorderRadius.circular(RadiosProfesionales.lg),
          border: Border.all(
            color: PaletaProfesional.divider,
            width: 1,
          ),
          boxShadow: SombrasProfesionales.elevacion2,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PaletaProfesional.primarioSuave,
                borderRadius: BorderRadius.circular(RadiosProfesionales.md),
              ),
              child: Icon(
                Icons.directions_rounded,
                color: PaletaProfesional.primario,
                size: 24,
              ),
            ),
            SizedBox(width: EspaciadoProfesional.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ruta generada',
                    style: TextStyle(
                      color: PaletaProfesional.textoPrimario,
                      fontSize: TipografiaProfesional.body1,
                      fontWeight: TipografiaProfesional.semibold,
                    ),
                  ),
                  Text(
                    '${distancia.toStringAsFixed(2)} km • ~$tiempoEstimado min',
                    style: TextStyle(
                      color: PaletaProfesional.textoSecundario,
                      fontSize: TipografiaProfesional.caption,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: PaletaProfesional.textoTerciario),
              onPressed: () {
                setState(() {
                  _rutaGenerada = null;
                  _destinoSeleccionado = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _obtenerIconoCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'plaza':
      case 'parque':
        return Icons.park_rounded;
      case 'restaurante':
      case 'comida':
        return Icons.restaurant_rounded;
      case 'comercio':
      case 'tienda':
      case 'mercado':
        return Icons.shopping_bag_rounded;
      case 'escuela':
      case 'educación':
        return Icons.school_rounded;
      case 'hospital':
      case 'salud':
        return Icons.local_hospital_rounded;
      case 'playa':
      case 'recreación':
        return Icons.beach_access_rounded;
      case 'centro cultural':
      case 'museo':
        return Icons.museum_rounded;
      case 'transporte':
        return Icons.directions_bus_rounded;
      case 'malecón':
      case 'turismo':
        return Icons.tour_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Future<void> _buscarLugares(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      // Búsqueda usando Nominatim API de OpenStreetMap
      // Centrado en Puerto Peñasco, Sonora
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'q=$query, Puerto Peñasco, Sonora, México&'
        'format=json&'
        'addressdetails=1&'
        'limit=10&'
        'viewbox=-113.6,31.4,-113.4,31.2&'
        'bounded=1'
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'RutasSeguras/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        final resultados = data.map((item) {
          // Determinar categoría basada en el tipo de lugar
          String categoria = _determinarCategoria(item);
          
          // Extraer nombre del lugar
          String nombre = item['name'] ?? item['display_name'].split(',')[0];
          
          return {
            'name': nombre,
            'display_name': item['display_name'],
            'lat': item['lat'],
            'lon': item['lon'],
            'category': categoria,
            'type': item['type'] ?? 'place',
            'class': item['class'] ?? 'unknown',
          };
        }).toList();

        setState(() {
          _searchResults = resultados;
        });
      } else {
        throw Exception('Error en la búsqueda: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en búsqueda: $e');
      
      // Si falla la API, usar búsqueda local con lugares predefinidos
      _buscarLugaresLocal(query);
    }
  }

  void _buscarLugaresLocal(String query) {
    // Lugares de ejemplo en Puerto Peñasco con categorías
    final lugaresEjemplo = [
      {
        'name': 'Plaza Principal',
        'display_name': 'Plaza Principal, Centro, Puerto Peñasco, Sonora',
        'lat': '31.3167',
        'lon': '-113.5361',
        'category': 'Plaza',
      },
      {
        'name': 'Malecón Fundadores',
        'display_name': 'Malecón Fundadores, Puerto Peñasco, Sonora',
        'lat': '31.3200',
        'lon': '-113.5400',
        'category': 'Malecón',
      },
      {
        'name': 'CEDO (Centro Intercultural)',
        'display_name': 'CEDO, Las Conchas, Puerto Peñasco, Sonora',
        'lat': '31.3100',
        'lon': '-113.5200',
        'category': 'Centro Cultural',
      },
      {
        'name': 'Playa Bonita',
        'display_name': 'Playa Bonita, Puerto Peñasco, Sonora',
        'lat': '31.3250',
        'lon': '-113.5500',
        'category': 'Playa',
      },
      {
        'name': 'Mercado Municipal',
        'display_name': 'Mercado Municipal, Centro, Puerto Peñasco, Sonora',
        'lat': '31.3150',
        'lon': '-113.5350',
        'category': 'Mercado',
      },
      {
        'name': 'Hospital General',
        'display_name': 'Hospital General, Puerto Peñasco, Sonora',
        'lat': '31.3180',
        'lon': '-113.5320',
        'category': 'Hospital',
      },
      {
        'name': 'Escuela Primaria Benito Juárez',
        'display_name': 'Escuela Primaria, Centro, Puerto Peñasco, Sonora',
        'lat': '31.3145',
        'lon': '-113.5375',
        'category': 'Escuela',
      },
      {
        'name': 'Restaurante El Capitán',
        'display_name': 'Restaurante El Capitán, Malecón, Puerto Peñasco',
        'lat': '31.3210',
        'lon': '-113.5420',
        'category': 'Restaurante',
      },
      {
        'name': 'Super Ley',
        'display_name': 'Super Ley, Blvd Fremont, Puerto Peñasco, Sonora',
        'lat': '31.3190',
        'lon': '-113.5340',
        'category': 'Tienda',
      },
      {
        'name': 'Parque Recreativo',
        'display_name': 'Parque Recreativo, Col. Obrera, Puerto Peñasco',
        'lat': '31.3130',
        'lon': '-113.5380',
        'category': 'Parque',
      },
    ];

    final resultadosFiltrados = lugaresEjemplo
        .where((lugar) =>
            lugar['name']!.toLowerCase().contains(query.toLowerCase()) ||
            lugar['display_name']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _searchResults = resultadosFiltrados;
    });
  }

  String _determinarCategoria(Map<String, dynamic> item) {
    final type = item['type']?.toLowerCase() ?? '';
    final classification = item['class']?.toLowerCase() ?? '';
    
    // Categorizar según el tipo de OSM
    if (type.contains('hospital') || type.contains('clinic')) return 'Hospital';
    if (type.contains('school') || type.contains('university')) return 'Escuela';
    if (type.contains('restaurant') || type.contains('cafe')) return 'Restaurante';
    if (type.contains('supermarket') || type.contains('shop')) return 'Tienda';
    if (type.contains('park') || type.contains('garden')) return 'Parque';
    if (type.contains('beach')) return 'Playa';
    if (type.contains('museum') || type.contains('gallery')) return 'Centro Cultural';
    if (type.contains('bus_station') || type.contains('station')) return 'Transporte';
    if (classification.contains('highway')) return 'Calle';
    if (classification.contains('amenity')) return 'Servicio';
    if (classification.contains('tourism')) return 'Turismo';
    
    return 'Lugar';
  }

  void _seleccionarDestino(Map<String, dynamic> lugar) {
    final lat = double.parse(lugar['lat']);
    final lon = double.parse(lugar['lon']);
    final destino = LatLng(lat, lon);

    setState(() {
      _destinoSeleccionado = destino;
      _searchResults.clear();
      _isSearching = false;
      _searchController.text = lugar['name'];
    });

    // Generar ruta simple (línea recta)
    _generarRuta(_ubicacionActual, destino);

    // Centrar mapa para mostrar origen y destino
    _mapController.move(destino, 14.0);
  }

  void _generarRuta(LatLng origen, LatLng destino) {
    // Ruta simple en línea recta (en producción usar API de routing)
    setState(() {
      _rutaGenerada = [origen, destino];
    });
  }

  double _calcularDistancia(LatLng punto1, LatLng punto2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, punto1, punto2);
  }

  void _mostrarInfoSensor(Nodo nodo) {
    final nivel = _calcularNivelSeguridad(nodo);
    final estado = _obtenerEstadoTexto(nivel);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _obtenerColorPorSeguridad(nivel),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _obtenerIconoPorEstado(nodo),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nodo.nombre,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        estado,
                        style: TextStyle(
                          fontSize: 14,
                          color: _obtenerColorPorSeguridad(nivel),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _InfoRow(
              icono: Icons.lightbulb_outline,
              titulo: 'Iluminación',
              valor: '${nodo.ultimoLux?.toInt() ?? 'N/A'} lux',
            ),
            _InfoRow(
              icono: Icons.volume_up,
              titulo: 'Nivel de ruido',
              valor: '${nodo.ultimoRuido?.toInt() ?? 'N/A'} dB',
            ),
            _InfoRow(
              icono: Icons.access_time,
              titulo: 'Última actualización',
              valor: _formatearFecha(nodo.fechaUltimaLectura),
            ),
            _InfoRow(
              icono: Icons.security,
              titulo: 'Nivel de seguridad',
              valor: '$nivel/10',
            ),
          ],
        ),
      ),
    );
  }

  String _obtenerEstadoTexto(int nivel) {
    if (nivel <= 3) return 'Zona Peligrosa';
    if (nivel <= 6) return 'Zona de Precaución';
    return 'Zona Segura';
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'No disponible';
    final now = DateTime.now();
    final diff = now.difference(fecha);
    
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} días';
  }

  void _centrarEnUbicacion() {
    _mapController.move(_centroMapa, 15.0);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _InfoRow({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icono, color: Colors.grey.shade600, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
