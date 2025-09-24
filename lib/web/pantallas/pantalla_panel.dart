

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';
import 'pantalla_configuracion.dart';
import 'pantalla_usuarios.dart';
import 'pantalla_sensores.dart';
import 'pantalla_reportes.dart';

/// Pantalla principal del centro de control web donde se visualizan sensores y reportes.
class PantallaPanel extends StatefulWidget {
  @override
  State<PantallaPanel> createState() => _PantallaPanelState();
}

class _PantallaPanelState extends State<PantallaPanel> {
  final List<Map<String, dynamic>> feedActividad = [
    {'hora': '12:01', 'tipo': 'Alerta', 'msg': 'Sensor #S-087 lleva 1h sin reportar.'},
    {'hora': '11:58', 'tipo': 'Reporte', 'msg': 'Usuario anónimo informa "Foco Roto" en Calle X.'},
    {'hora': '11:55', 'tipo': 'Info', 'msg': 'Sensor #S-112 vuelve a estar en línea.'},
    {'hora': '11:50', 'tipo': 'Alerta', 'msg': 'Sensor #S-004 batería baja.'},
    {'hora': '11:45', 'tipo': 'Reporte', 'msg': 'Actividad sospechosa en Calle Y.'},
  ];
  // Datos simulados de zonas, reportes y sensores
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

  final List<Map<String, dynamic>> sensores = [
    {
      'tipo': 'Luminaria',
      'estado': 'Activo',
      'ubicacion': LatLng(31.3175, -113.5335),
      'id': 'LUM-001',
      'ultimaAccion': 'Encendida hace 5 min'
    },
    {
      'tipo': 'Cámara',
      'estado': 'Fallo',
      'ubicacion': LatLng(31.3190, -113.5370),
      'id': 'CAM-002',
      'ultimaAccion': 'Sin señal desde hace 2h'
    },
    {
      'tipo': 'Botón de Pánico',
      'estado': 'Activo',
      'ubicacion': LatLng(31.3140, -113.5390),
      'id': 'PAN-003',
      'ultimaAccion': 'Activado hace 1h'
    },
    {
      'tipo': 'Luminaria',
      'estado': 'Fallo',
      'ubicacion': LatLng(31.3160, -113.5415),
      'id': 'LUM-004',
      'ultimaAccion': 'Apagada hace 20 min'
    },
  ];

  final List<Map<String, dynamic>> reportes = [
    {
      'tipo': 'Actividad Sospechosa',
      'hora': 'Hace 10 min',
      'ubicacion': 'Calle Simón Morua',
      'zona': 'Peligrosa'
    },
    {
      'tipo': 'Foco Descompuesto',
      'hora': 'Hace 25 min',
      'ubicacion': 'Calle Vicente Guerrero',
      'zona': 'Segura'
    },
    {
      'tipo': 'Asalto',
      'hora': 'Hace 1h',
      'ubicacion': 'Calle Benito Juárez',
      'zona': 'Peligrosa'
    },
  ];

  int _selectedMenu = 0; // 0: Dashboard, 1: Configuración, 2: Usuarios, 3: Sensores, 4: Reportes

  @override
  Widget build(BuildContext context) {
    // Indicadores clave
    final int sensoresActivos = sensores.where((s) => s['estado'] == 'Activo').length;
    final int sensoresFallo = sensores.where((s) => s['estado'] == 'Fallo').length;
    final int zonasPeligrosasCount = zonasPeligrosas.length;
    final int reportesCount = reportes.length;

    return Scaffold(
      backgroundColor: const Color(0xFF181C2E),
      body: Row(
        children: [
          // Menú lateral fijo
          Container(
            width: 80,
            color: const Color(0xFF20212B),
            child: Column(
              children: [
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => setState(() => _selectedMenu = 0),
                  child: Icon(Icons.dashboard, color: _selectedMenu == 0 ? Colors.amberAccent : Colors.white38, size: 34),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => setState(() => _selectedMenu = 3),
                  child: _MenuIcon(icon: Icons.sensors, label: 'Sensores', selected: _selectedMenu == 3),
                ),
                GestureDetector(
                  onTap: () => setState(() => _selectedMenu = 4),
                  child: _MenuIcon(icon: Icons.report, label: 'Reportes', selected: _selectedMenu == 4),
                ),
                _MenuIcon(icon: Icons.analytics, label: 'Analítica', selected: false),
                GestureDetector(
                  onTap: () => setState(() => _selectedMenu = 1),
                  child: _MenuIcon(icon: Icons.settings, label: 'Config.', selected: _selectedMenu == 1),
                ),
                GestureDetector(
                  onTap: () => setState(() => _selectedMenu = 2),
                  child: _MenuIcon(icon: Icons.people, label: 'Usuarios', selected: _selectedMenu == 2),
                ),
                const Spacer(),
                Icon(Icons.logout, color: Colors.white24, size: 28),
                const SizedBox(height: 18),
              ],
            ),
          ),
          // Pantalla central según menú
          Expanded(
            flex: 2,
            child: () {
              if (_selectedMenu == 0) {
                return _DashboardCentral(
                  sensores: sensores,
                  reportes: reportes,
                  feedActividad: feedActividad,
                  sensoresActivos: sensores.where((s) => s['estado'] == 'Activo').length,
                  sensoresFallo: sensores.where((s) => s['estado'] == 'Fallo').length,
                  reportesCount: reportes.length,
                );
              } else if (_selectedMenu == 1) {
                return PantallaConfiguracion();
              } else if (_selectedMenu == 2) {
                return PantallaUsuarios();
              } else if (_selectedMenu == 3) {
                return PantallaSensores();
              } else if (_selectedMenu == 4) {
                return PantallaReportes();
              } else {
                return SizedBox();
              }
            }(),
          ),
          // Feed de actividad solo en dashboard
          if (_selectedMenu == 0)
            Container(
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
                          title: Text(item['msg'], style: TextStyle(color: Colors.white)),
                          subtitle: Text(item['hora'], style: TextStyle(color: Colors.white54, fontSize: 13)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
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
                      center: LatLng(31.3167, -113.5361),
                      zoom: 15.0,
                      maxZoom: 18,
                      minZoom: 3,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                        subdomains: ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.example.rutasseguras',
                        backgroundColor: Colors.transparent,
                      ),
                      // Heatmap simulado de reportes
                      MarkerLayer(
                        markers: reportes.map((rep) {
                          final color = rep['zona'] == 'Peligrosa' ? Colors.redAccent.withOpacity(0.18) : Colors.amberAccent.withOpacity(0.13);
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

/// Menú lateral fijo: íconos y labels
class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  const _MenuIcon({required this.icon, required this.label, this.selected = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Icon(icon, color: selected ? Colors.amberAccent : Colors.white38, size: 28),
          Text(label, style: TextStyle(color: selected ? Colors.amberAccent : Colors.white38, fontSize: 11)),
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
