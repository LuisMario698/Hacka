import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../servicios/nodo_service.dart';

/// Diálogo mejorado para agregar sensores con selector de mapa interactivo
class DialogoAgregarSensor extends StatefulWidget {
  final VoidCallback onCrear;

  const DialogoAgregarSensor({Key? key, required this.onCrear}) : super(key: key);

  @override
  State<DialogoAgregarSensor> createState() => _DialogoAgregarSensorState();
}

class _DialogoAgregarSensorState extends State<DialogoAgregarSensor> {
  final nombreController = TextEditingController();
  final claveController = TextEditingController();
  final latitudController = TextEditingController(text: '19.4326');
  final longitudController = TextEditingController(text: '-99.1332');
  
  LatLng _ubicacionSeleccionada = LatLng(19.4326, -99.1332);
  final MapController _mapController = MapController();
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    latitudController.addListener(_actualizarMarcadorDesdeTexto);
    longitudController.addListener(_actualizarMarcadorDesdeTexto);
  }

  void _actualizarMarcadorDesdeTexto() {
    try {
      final lat = double.parse(latitudController.text);
      final lng = double.parse(longitudController.text);
      if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
        setState(() {
          _ubicacionSeleccionada = LatLng(lat, lng);
        });
        _mapController.move(_ubicacionSeleccionada, _mapController.camera.zoom);
      }
    } catch (e) {
      // Ignorar errores mientras escribe
    }
  }

  void _actualizarCoordenadas(LatLng posicion) {
    setState(() {
      _ubicacionSeleccionada = posicion;
      latitudController.text = posicion.latitude.toStringAsFixed(6);
      longitudController.text = posicion.longitude.toStringAsFixed(6);
    });
  }

  Future<void> _crearSensor() async {
    if (nombreController.text.isEmpty || claveController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      await NodoService.crearNodo(
        nombre: nombreController.text,
        claveDelDispositivo: claveController.text,
        latitud: _ubicacionSeleccionada.latitude,
        longitud: _ubicacionSeleccionada.longitude,
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('✓ Sensor creado exitosamente'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onCrear();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Contenido
            Expanded(
              child: Row(
                children: [
                  // Formulario
                  Container(
                    width: 350,
                    child: _buildFormulario(),
                  ),

                  // Mapa
                  Expanded(child: _buildMapa()),
                ],
              ),
            ),

            // Botones
            _buildBotones(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.purple.shade600],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.add_location_alt, color: Colors.white, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agregar Nuevo Sensor',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Selecciona la ubicación haciendo clic en el mapa',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del Sensor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          
          // Nombre
          TextField(
            controller: nombreController,
            decoration: InputDecoration(
              labelText: 'Nombre del Sensor',
              hintText: 'Ej: Sensor Parque Central',
              prefixIcon: Icon(Icons.sensors),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          SizedBox(height: 16),
          
          // Clave
          TextField(
            controller: claveController,
            decoration: InputDecoration(
              labelText: 'Clave del Dispositivo',
              hintText: 'Ej: ESP32_PARK_001',
              prefixIcon: Icon(Icons.qr_code),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          SizedBox(height: 20),
          
          Divider(),
          SizedBox(height: 12),
          
          Text(
            'Coordenadas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Haz clic en el mapa o edita manualmente',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          
          // Latitud
          TextField(
            controller: latitudController,
            decoration: InputDecoration(
              labelText: 'Latitud',
              prefixIcon: Icon(Icons.my_location),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
          ),
          SizedBox(height: 16),
          
          // Longitud
          TextField(
            controller: longitudController,
            decoration: InputDecoration(
              labelText: 'Longitud',
              prefixIcon: Icon(Icons.my_location),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
          ),
          SizedBox(height: 24),
          
          // Nota informativa
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Haz clic en cualquier parte del mapa para seleccionar la ubicación',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapa() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _ubicacionSeleccionada,
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                _actualizarCoordenadas(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _ubicacionSeleccionada,
                    width: 60,
                    height: 60,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.purple],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.5),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.sensors,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          width: 3,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Controles de zoom
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                  child: Icon(Icons.add),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                ),
                SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                  child: Icon(Icons.remove),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotones() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _cargando ? null : () => Navigator.pop(context),
            child: Text('Cancelar'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _cargando ? null : _crearSensor,
            icon: _cargando
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.add_location_alt),
            label: Text(_cargando ? 'Creando...' : 'Crear Sensor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    claveController.dispose();
    latitudController.dispose();
    longitudController.dispose();
    super.dispose();
  }
}
