import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PantallaReportesNueva extends StatefulWidget {
  @override
  State<PantallaReportesNueva> createState() => _PantallaReportesNuevaState();
}

class _PantallaReportesNuevaState extends State<PantallaReportesNueva> {
  String _filtroEstado = 'todos';
  String _filtroTipo = 'todos';
  String _busqueda = '';
  bool _mostrarMapa = true;

  // Datos de ejemplo - luego conectar con la BD
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
      'prioridad': 'alta',
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
      'prioridad': 'critica',
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
      'prioridad': 'critica',
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
                    _buildStatChip('Total', _reportes.length.toString(), Colors.blue),
                    SizedBox(width: 12),
                    _buildStatChip('Nuevos', _reportes.where((r) => r['estado'] == 'nuevo').length.toString(), Colors.orange),
                    SizedBox(width: 12),
                    _buildStatChip('En Proceso', _reportes.where((r) => r['estado'] == 'en_proceso').length.toString(), Colors.amber),
                    SizedBox(width: 12),
                    _buildStatChip('Resueltos', _reportes.where((r) => r['estado'] == 'resuelto').length.toString(), Colors.green),
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
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(19.4326, -99.1332),
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            // Marcadores de reportes
            MarkerLayer(
              markers: _reportes.map((reporte) {
                Color markerColor;
                switch (reporte['prioridad']) {
                  case 'critica':
                    markerColor = Colors.red;
                    break;
                  case 'alta':
                    markerColor = Colors.orange;
                    break;
                  case 'media':
                    markerColor = Colors.yellow.shade700;
                    break;
                  default:
                    markerColor = Colors.blue;
                }

                return Marker(
                  point: LatLng(reporte['lat'], reporte['lng']),
                  width: 40,
                  height: 40,
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
                        Icons.warning,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
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
