import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../servicios/nodo_service.dart';
import '../../modelos/nodo_model.dart';

class PantallaReportesNueva extends StatefulWidget {
  @override
  State<PantallaReportesNueva> createState() => _PantallaReportesNuevaState();
}

class _PantallaReportesNuevaState extends State<PantallaReportesNueva> {
  String _filtroEstado = 'todos';
  String _filtroTipo = 'todos';
  String _busqueda = '';
  bool _mostrarMapa = true;
  List<Nodo> _sensores = [];
  bool _cargandoSensores = false;

  // Datos de ejemplo de reportes - luego conectar con la BD
  List<Map<String, dynamic>> _reportes = [
    {
      'id': 'REP-001',
      'usuario': 'Juan Pérez',
      'tipo': 'Iluminación deficiente',
      'estado': 'nuevo',
      'ubicacion': 'Calle 5 #23-45',
      'lat': 19.4326,
      'lng': -99.1332,
      'fecha': '2025-01-05 18:30',
      'descripcion': 'Poste de luz apagado desde hace 3 días',
      'evidencia': 'foto_001.jpg',
      'prioridad': 'critica',
    },
    {
      'id': 'REP-002',
      'usuario': 'María López',
      'tipo': 'Acoso callejero',
      'estado': 'en_proceso',
      'ubicacion': 'Av. Principal #12-34',
      'lat': 19.4350,
      'lng': -99.1350,
      'fecha': '2025-01-05 20:15',
      'descripcion': 'Grupo de personas acosando transeúntes',
      'evidencia': 'video_002.mp4',
      'prioridad': 'alta',
    },
    {
      'id': 'REP-003',
      'usuario': 'Carlos Ruiz',
      'tipo': 'Ruido excesivo',
      'estado': 'resuelto',
      'ubicacion': 'Calle 8 #45-67',
      'lat': 19.4300,
      'lng': -99.1300,
      'fecha': '2025-01-04 22:00',
      'descripcion': 'Fiesta con música a alto volumen',
      'evidencia': null,
      'prioridad': 'media',
    },
    {
      'id': 'REP-004',
      'usuario': 'Ana García',
      'tipo': 'Robo',
      'estado': 'nuevo',
      'ubicacion': 'Parque Central',
      'lat': 19.4380,
      'lng': -99.1380,
      'fecha': '2025-01-05 19:45',
      'descripcion': 'Intento de robo de celular',
      'evidencia': 'foto_004.jpg',
      'prioridad': 'alta',
    },
    {
      'id': 'REP-005',
      'usuario': 'Luis Martínez',
      'tipo': 'Vía obstruida',
      'estado': 'en_proceso',
      'ubicacion': 'Calle 3 #56-78',
      'lat': 19.4320,
      'lng': -99.1320,
      'fecha': '2025-01-05 17:20',
      'descripcion': 'Árbol caído bloqueando paso peatonal',
      'evidencia': 'foto_005.jpg',
      'prioridad': 'media',
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarSensores();
  }

  Future<void> _cargarSensores() async {
    setState(() {
      _cargandoSensores = true;
    });

    try {
      final sensores = await NodoService.obtenerTodosLosNodos();
      setState(() {
        _sensores = sensores;
        _cargandoSensores = false;
      });
    } catch (e) {
      print('Error al cargar sensores: $e');
      setState(() {
        _cargandoSensores = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar sensores: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportesFiltrados = _filtrarReportes();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.report_problem, size: 32, color: Colors.orange),
                    SizedBox(width: 12),
                    Text(
                      'Gestión de Reportes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    // Botón refrescar sensores
                    IconButton(
                      icon: _cargandoSensores
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.refresh),
                      tooltip: 'Refrescar sensores',
                      onPressed: _cargandoSensores ? null : _cargarSensores,
                    ),
                    // Toggle Vista
                    IconButton(
                      icon: Icon(_mostrarMapa ? Icons.table_chart : Icons.map),
                      tooltip: _mostrarMapa ? 'Ver tabla' : 'Ver mapa',
                      onPressed: () {
                        setState(() {
                          _mostrarMapa = !_mostrarMapa;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Estadísticas rápidas
                Row(
                  children: [
                    _buildStatChip('Reportes', _reportes.length.toString(), Colors.blue),
                    SizedBox(width: 12),
                    _buildStatChip('Nuevos', _reportes.where((r) => r['estado'] == 'nuevo').length.toString(), Colors.orange),
                    SizedBox(width: 12),
                    _buildStatChip('En Proceso', _reportes.where((r) => r['estado'] == 'en_proceso').length.toString(), Colors.amber),
                    SizedBox(width: 12),
                    _buildStatChip('Sensores', _sensores.length.toString(), Colors.green),
                  ],
                ),
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: _mostrarMapa ? _buildMapaCalor() : _buildTablaReportes(reportesFiltrados),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapaCalor() {
    return Container(
      margin: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(19.4326, -99.1332),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                // Marcadores de SENSORES
                MarkerLayer(
                  markers: _sensores.map((sensor) {
                    Color markerColor;
                    IconData markerIcon;
                    String estado = sensor.obtenerEstado();

                    switch (estado) {
                      case 'online':
                        markerColor = Colors.green;
                        markerIcon = Icons.sensors;
                        break;
                      case 'alerta':
                        markerColor = Colors.orange;
                        markerIcon = Icons.warning;
                        break;
                      case 'offline':
                        markerColor = Colors.grey;
                        markerIcon = Icons.sensors_off;
                        break;
                      default:
                        markerColor = Colors.grey.shade400;
                        markerIcon = Icons.help_outline;
                    }

                    return Marker(
                      point: LatLng(sensor.latitud, sensor.longitud),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _mostrarDetalleSensor(sensor),
                        child: Container(
                          decoration: BoxDecoration(
                            color: markerColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            markerIcon,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                // Marcadores de REPORTES
                MarkerLayer(
                  markers: _reportes.map((reporte) {
                    Color markerColor;
                    switch (reporte['prioridad']) {
                      case 'critica':
                        markerColor = Colors.red;
                        break;
                      case 'alta':
                        markerColor = Colors.deepOrange;
                        break;
                      case 'media':
                        markerColor = Colors.yellow.shade700;
                        break;
                      default:
                        markerColor = Colors.blue;
                    }

                    return Marker(
                      point: LatLng(reporte['lat'], reporte['lng']),
                      width: 36,
                      height: 36,
                      child: GestureDetector(
                        onTap: () => _mostrarDetalleReporte(reporte),
                        child: Container(
                          decoration: BoxDecoration(
                            color: markerColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.report,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            // Leyenda del mapa
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Leyenda',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildLeyendaItem(Colors.green, Icons.sensors, 'Sensor En Línea'),
                    _buildLeyendaItem(Colors.orange, Icons.warning, 'Sensor con Alerta'),
                    _buildLeyendaItem(Colors.grey, Icons.sensors_off, 'Sensor Fuera de Línea'),
                    Divider(height: 16),
                    _buildLeyendaItem(Colors.red, Icons.report, 'Reporte Crítico'),
                    _buildLeyendaItem(Colors.deepOrange, Icons.report, 'Reporte Alta'),
                    _buildLeyendaItem(Colors.yellow.shade700, Icons.report, 'Reporte Media'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeyendaItem(Color color, IconData icon, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 12,
            ),
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _mostrarDetalleSensor(Nodo sensor) {
    final estado = sensor.obtenerEstado();
    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.sensors, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                sensor.nombre,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', sensor.claveDelDispositivo),
              _buildDetailRow('Ubicación', '${sensor.latitud.toStringAsFixed(6)}, ${sensor.longitud.toStringAsFixed(6)}'),
              SizedBox(height: 12),
              // Estado con badge
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      'Estado:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: estado == 'online'
                            ? [Colors.green.shade400, Colors.green.shade600]
                            : estado == 'alerta'
                                ? [Colors.orange.shade400, Colors.orange.shade600]
                                : estado == 'offline'
                                    ? [Colors.grey.shade400, Colors.grey.shade600]
                                    : [Colors.grey.shade300, Colors.grey.shade400],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          estado == 'online'
                              ? Icons.check_circle
                              : estado == 'alerta'
                                  ? Icons.warning
                                  : estado == 'offline'
                                      ? Icons.cloud_off
                                      : Icons.help_outline,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          estado == 'online'
                              ? 'En Línea'
                              : estado == 'alerta'
                                  ? 'Con Alerta'
                                  : estado == 'offline'
                                      ? 'Fuera de Línea'
                                      : 'Sin Datos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Lecturas
              if (sensor.ultimoLux != null || sensor.ultimoRuido != null) ...[
                Text(
                  'Últimas Lecturas:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                if (sensor.ultimoLux != null)
                  _buildLecturaRow('Luz', '${sensor.ultimoLux!.toStringAsFixed(1)} lux', Icons.light_mode),
                if (sensor.ultimoRuido != null)
                  _buildLecturaRow('Ruido', '${sensor.ultimoRuido!.toStringAsFixed(1)} dB', Icons.volume_up),
                if (sensor.fechaUltimaLectura != null)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Última actualización: ${formatter.format(sensor.fechaUltimaLectura!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ] else ...[
                Text(
                  'No hay datos de lecturas disponibles',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              // Aquí podrías navegar a la pantalla de detalles del sensor
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ver historial completo en Sensores'),
                  action: SnackBarAction(
                    label: 'IR',
                    onPressed: () {
                      // TODO: Navegar a pantalla de sensores
                    },
                  ),
                ),
              );
            },
            icon: Icon(Icons.history, size: 18),
            label: Text('Ver Historial'),
          ),
        ],
      ),
    );
  }

  Widget _buildLecturaRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTablaReportes(List<Map<String, dynamic>> reportes) {
    return Center(
      child: Text('Vista de tabla - Próximamente'),
    );
  }

  List<Map<String, dynamic>> _filtrarReportes() {
    return _reportes.where((reporte) {
      if (_filtroEstado != 'todos' && reporte['estado'] != _filtroEstado) {
        return false;
      }
      if (_filtroTipo != 'todos' && reporte['tipo'] != _filtroTipo) {
        return false;
      }
      if (_busqueda.isNotEmpty) {
        final busquedaLower = _busqueda.toLowerCase();
        return reporte['usuario'].toString().toLowerCase().contains(busquedaLower) ||
            reporte['ubicacion'].toString().toLowerCase().contains(busquedaLower) ||
            reporte['tipo'].toString().toLowerCase().contains(busquedaLower);
      }
      return true;
    }).toList();
  }

  void _mostrarDetalleReporte(Map<String, dynamic> reporte) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.report_problem, color: Colors.orange),
            SizedBox(width: 8),
            Text(reporte['id']),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Usuario', reporte['usuario']),
              _buildDetailRow('Tipo', reporte['tipo']),
              _buildDetailRow('Estado', reporte['estado']),
              _buildDetailRow('Ubicación', reporte['ubicacion']),
              _buildDetailRow('Fecha', reporte['fecha']),
              _buildDetailRow('Prioridad', reporte['prioridad']),
              SizedBox(height: 12),
              Text(
                'Descripción:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(reporte['descripcion']),
              if (reporte['evidencia'] != null) ...[
                SizedBox(height: 12),
                Text(
                  'Evidencia:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(reporte['evidencia']),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cerrar'),
          ),
          if (reporte['estado'] != 'resuelto')
            ElevatedButton(
              onPressed: () {
                // Cambiar estado
                Navigator.pop(ctx);
              },
              child: Text('Cambiar Estado'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
