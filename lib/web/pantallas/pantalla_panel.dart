

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';
import 'pantalla_configuracion.dart';
import 'pantalla_usuarios.dart';
import 'pantalla_sensores.dart';
import 'pantalla_reportes.dart';

import '../../servicios/theme_widgets.dart';

/// Pantalla principal del centro de control web donde se visualizan sensores y reportes.
class PantallaPanel extends StatefulWidget {
  @override
  State<PantallaPanel> createState() => _PantallaPanelState();
}

class _PantallaPanelState extends State<PantallaPanel> {
  late Future<List<Map<String, dynamic>>> _nodosFuture;
  late Future<List<Map<String, dynamic>>> _lecturasFuture;
  late Future<List<Map<String, dynamic>>> _feedFuture;

  // int _selectedMenu = 0; // Duplicado, eliminar

  @override
  void initState() {
    super.initState();
    // Datos de ejemplo para mostrar el mapa
    _nodosFuture = Future.value([
      {
        'id': 'SENSOR001',
        'tipo': 'Luminaria',
        'ubicacion': LatLng(31.3167, -113.5361),
        'estado': 'Activo',
        'ultimaAccion': '2025-10-02 14:30',
        'activo': true,
      },
      {
        'id': 'SENSOR002', 
        'tipo': 'Cámara',
        'ubicacion': LatLng(31.3170, -113.5355),
        'estado': 'Activo',
        'ultimaAccion': '2025-10-02 14:25',
        'activo': true,
      },
      {
        'id': 'SENSOR003',
        'tipo': 'Botón de Pánico',
        'ubicacion': LatLng(31.3160, -113.5370),
        'estado': 'Inactivo',
        'ultimaAccion': '2025-10-02 12:15',
        'activo': false,
      },
    ]);
    _lecturasFuture = Future.value([
      {
        'ubicacion': 'Centro',
        'zona': 'Segura',
        'tipo': 'Reporte de seguridad',
        'fecha': '2025-10-02',
      },
      {
        'ubicacion': 'Norte',
        'zona': 'Peligrosa', 
        'tipo': 'Incidente reportado',
        'fecha': '2025-10-02',
      },
    ]);
    _feedFuture = Future.value([
      {
        'tipo': 'Alerta',
        'msg': 'Sensor SENSOR003 desconectado',
        'hora': '14:30',
      },
      {
        'tipo': 'Reporte',
        'msg': 'Nuevo reporte de incidente en zona Norte',
        'hora': '14:25',
      },
      {
        'tipo': 'Info',
        'msg': 'Sistema funcionando correctamente',
        'hora': '14:00',
      },
    ]);
  }

  int _selectedMenu = 0; // 0: Dashboard, 1: Configuración, 2: Usuarios, 3: Sensores, 4: Reportes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          // Menú lateral fijo con diseño accesible
          Container(
            width: 100,
            color: Theme.of(context).primaryColor,
            child: Column(
              children: [
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => setState(() => _selectedMenu = 0),
                  child: _MenuIconLarge(
                    icon: Icons.dashboard_rounded,
                    label: 'Panel',
                    selected: _selectedMenu == 0,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => setState(() => _selectedMenu = 3),
                  child: _MenuIconLarge(icon: Icons.sensors_rounded, label: 'Sensores', selected: _selectedMenu == 3),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() => _selectedMenu = 4),
                  child: _MenuIconLarge(icon: Icons.bar_chart_rounded, label: 'Lecturas', selected: _selectedMenu == 4),
                ),
                const SizedBox(height: 16),
                _MenuIconLarge(icon: Icons.analytics_rounded, label: 'Analítica', selected: false),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() => _selectedMenu = 1),
                  child: _MenuIconLarge(icon: Icons.settings_rounded, label: 'Config.', selected: _selectedMenu == 1),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() => _selectedMenu = 2),
                  child: _MenuIconLarge(icon: Icons.people_rounded, label: 'Usuarios', selected: _selectedMenu == 2),
                ),
                const Spacer(),
                Icon(Icons.logout_rounded, color: Colors.white70, size: 32),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Pantalla central según menú
          Expanded(
            flex: 2,
            child: _selectedMenu == 0
                ? FutureBuilder<List<List<Map<String, dynamic>>>>(
                    future: Future.wait([
                      _nodosFuture,
                      _lecturasFuture,
                      _feedFuture,
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        print('Supabase error:');
                        print(snapshot.error);
                        return Center(child: Text('Error al cargar datos', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 18)));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No hay datos disponibles', style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 18)));
                      }
                      final List<Map<String, dynamic>> nodos = snapshot.data![0];
                      final List<Map<String, dynamic>> lecturas = snapshot.data![1];
                      final List<Map<String, dynamic>> feedActividad = snapshot.data![2];
                      return _DashboardCentral(
                        sensores: nodos,
                        reportes: lecturas,
                        feedActividad: feedActividad,
                        sensoresActivos: nodos.where((s) => s['activo'] == true).length,
                        sensoresFallo: nodos.where((s) => s['activo'] == false).length,
                        reportesCount: lecturas.length,
                      );
                    },
                  )
                : _selectedMenu == 1
                    ? PantallaConfiguracion()
                    : _selectedMenu == 2
                        ? PantallaUsuarios()
                        : _selectedMenu == 3
                            ? PantallaSensores()
                            : _selectedMenu == 4
                                ? PantallaReportes()
                                : SizedBox(),
          ),
          // Feed de actividad solo en dashboard
          if (_selectedMenu == 0)
            FutureBuilder<List<List<Map<String, dynamic>>>>(
              future: Future.wait([
                _feedFuture,
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: 340,
                    color: const Color(0xFF23243A),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    width: 340,
                    color: const Color(0xFF23243A),
                    child: Center(child: Text('Error al cargar actividad', style: TextStyle(color: Colors.redAccent))),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    width: 340,
                    color: const Color(0xFF23243A),
                    child: Center(child: Text('No hay actividad reciente', style: TextStyle(color: Colors.white70))),
                  );
                }
                final List<Map<String, dynamic>> feedActividad = snapshot.data![0];
                return Container(
                  width: 340,
                  color: const Color(0xFF23243A),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('Feed de Actividad', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: feedActividad.length,
                          itemBuilder: (context, i) {
                            final item = feedActividad[i];
                            Color color;
                            if (item['tipo'] == 'Alerta') color = Colors.redAccent;
                            else if (item['tipo'] == 'Reporte') color = Colors.amberAccent;
                            else color = Colors.greenAccent;
                            return ListTile(
                              leading: Icon(
                                item['tipo'] == 'Alerta' ? Icons.warning_amber_rounded : item['tipo'] == 'Reporte' ? Icons.report : Icons.info,
                                color: color,
                              ),
                              title: Text(item['msg'] ?? item['tipo'] ?? '', style: TextStyle(color: Colors.white)),
                              subtitle: Text(item['hora'] ?? '', style: TextStyle(color: Colors.white54, fontSize: 13)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      // Botón flotante para cambio rápido de tema
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
        child: ThemeToggleSwitch(
          showLabel: false,
          size: 0.9,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}

// Widget central del dashboard (KPIs y mapa)
class _DashboardCentral extends StatelessWidget {
  final List<Map<String, dynamic>> sensores;
  final List<Map<String, dynamic>> reportes;
  final List<Map<String, dynamic>> feedActividad;
  final int sensoresActivos;
  final int sensoresFallo;
  final int reportesCount;
  const _DashboardCentral({required this.sensores, required this.reportes, required this.feedActividad, required this.sensoresActivos, required this.sensoresFallo, required this.reportesCount});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _IndicadorDashboard(
                icon: Icons.sensors,
                label: 'Sensores activos',
                value: sensoresActivos.toString(),
                color: Colors.greenAccent,
              ),
              _IndicadorDashboard(
                icon: Icons.report,
                label: 'Reportes hoy',
                value: reportesCount.toString(),
                color: Colors.amberAccent,
              ),
              _IndicadorDashboard(
                icon: Icons.warning_amber_rounded,
                label: 'Alertas activas',
                value: sensoresFallo.toString(),
                color: Colors.redAccent,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 18, right: 18, bottom: 18),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(31.3167, -113.5361),
                      initialZoom: 15.0,
                      maxZoom: 18,
                      minZoom: 3,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.tefrontend',
                      ),
                      // Heatmap simulado de reportes
                      MarkerLayer(
                        markers: reportes.map((rep) {
                          final color = rep['zona'] == 'Peligrosa' 
                              ? Theme.of(context).colorScheme.error.withOpacity(0.18) 
                              : Theme.of(context).colorScheme.secondary.withOpacity(0.13);
                          final random = Random(rep['ubicacion'].hashCode);
                          final lat = 31.3167 + (random.nextDouble() - 0.5) * 0.01;
                          final lng = -113.5361 + (random.nextDouble() - 0.5) * 0.01;
                          return Marker(
                            point: LatLng(lat, lng),
                            width: 90,
                            height: 90,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      // Sensores urbanos
                      MarkerLayer(
                        markers: sensores.map((sensor) => Marker(
                          point: sensor['ubicacion'],
                          width: 44,
                          height: 44,
                          child: Tooltip(
                            message: '${sensor['tipo']}\n${sensor['id']}\nEstado: ${sensor['estado']}',
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => _ModalSensorInfo(sensor: sensor),
                                );
                              },
                              child: Icon(
                                sensor['tipo'] == 'Luminaria' ? Icons.lightbulb : sensor['tipo'] == 'Cámara' ? Icons.videocam : Icons.sos,
                                color: sensor['estado'] == 'Activo' ? Colors.greenAccent : Colors.redAccent,
                                size: 38,
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Menú lateral accesible: íconos grandes y labels legibles
class _MenuIconLarge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  const _MenuIconLarge({required this.icon, required this.label, this.selected = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon, 
            color: selected ? Colors.white : Colors.white70, 
            size: 36
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70, 
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Modal de información de sensor
class _ModalSensorInfo extends StatelessWidget {
  final Map<String, dynamic> sensor;
  const _ModalSensorInfo({required this.sensor});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF23243A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  sensor['tipo'] == 'Luminaria' ? Icons.lightbulb : sensor['tipo'] == 'Cámara' ? Icons.videocam : Icons.sos,
                  color: sensor['estado'] == 'Activo' ? Colors.greenAccent : Colors.redAccent,
                  size: 36,
                ),
                const SizedBox(width: 12),
                Text('${sensor['tipo']} (${sensor['id']})', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Estado: ${sensor['estado']}', style: TextStyle(color: Colors.white70, fontSize: 15)),
            Text('Última acción: ${sensor['ultimaAccion']}', style: TextStyle(color: Colors.white70, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
                  icon: Icon(Icons.refresh),
                  label: Text('Resetear'),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                if (sensor['tipo'] == 'Luminaria')
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent, foregroundColor: Colors.black),
                    icon: Icon(Icons.power_settings_new),
                    label: Text('Encender/Apagar'),
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para indicadores clave en el dashboard
class _IndicadorDashboard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _IndicadorDashboard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
              Text(label, style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }


}
