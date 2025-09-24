import 'package:flutter/material.dart';

class PantallaSensores extends StatelessWidget {
  final List<Map<String, dynamic>> sensores = [
    {'id': 'LUM-001', 'tipo': 'Luminaria', 'estado': 'Activo', 'bateria': 92, 'luz': 150, 'ubicacion': 'Calle 1', 'ultima': '12:01'},
    {'id': 'CAM-002', 'tipo': 'Cámara', 'estado': 'Fallo', 'bateria': 0, 'luz': null, 'ubicacion': 'Calle 2', 'ultima': '11:58'},
    {'id': 'PAN-003', 'tipo': 'Botón de Pánico', 'estado': 'Activo', 'bateria': 80, 'luz': null, 'ubicacion': 'Calle 3', 'ultima': '11:55'},
    {'id': 'LUM-004', 'tipo': 'Luminaria', 'estado': 'Batería Baja', 'bateria': 18, 'luz': 40, 'ubicacion': 'Calle 4', 'ultima': '11:50'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181C2E),
      appBar: AppBar(
        title: const Text('Gestión de Sensores', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, letterSpacing: 0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle, color: Colors.amberAccent, size: 36),
            tooltip: 'Registrar nuevo sensor',
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1400),
          padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 44),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(44),
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 36, offset: Offset(0, 14))],
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _KpiSensor(icon: Icons.sensors, label: 'Total', value: sensores.length.toString(), color: Colors.blueAccent, size: 32),
                    SizedBox(width: 32),
                    _KpiSensor(icon: Icons.check_circle, label: 'Activos', value: sensores.where((s) => s['estado'] == 'Activo').length.toString(), color: Colors.greenAccent, size: 32),
                    SizedBox(width: 32),
                    _KpiSensor(icon: Icons.warning_amber_rounded, label: 'Fallo', value: sensores.where((s) => s['estado'] == 'Fallo').length.toString(), color: Colors.redAccent, size: 32),
                    SizedBox(width: 32),
                    _KpiSensor(icon: Icons.battery_alert, label: 'Batería Baja', value: sensores.where((s) => s['estado'] == 'Batería Baja').length.toString(), color: Colors.amberAccent, size: 32),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '🔍 Buscar por ID, tipo, estado...',
                    hintStyle: TextStyle(color: Colors.white54, fontSize: 18),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  ),
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 1200),
                    child: DataTable(
                      headingRowHeight: 64,
                      dataRowHeight: 60,
                      headingRowColor: MaterialStateProperty.all(Colors.white10),
                      dataRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.04)),
                      border: TableBorder(horizontalInside: BorderSide(color: Colors.white12)),
                      columns: const [
                        DataColumn(label: SizedBox(width: 120, child: Text('ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                        DataColumn(label: SizedBox(width: 160, child: Text('Tipo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                        DataColumn(label: SizedBox(width: 160, child: Text('Estado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                        DataColumn(label: SizedBox(width: 120, child: Text('Batería', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                        DataColumn(label: SizedBox(width: 120, child: Text('Luz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                        DataColumn(label: SizedBox(width: 160, child: Text('Ubicación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                        DataColumn(label: SizedBox(width: 120, child: Text('Última', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                        DataColumn(label: SizedBox(width: 160, child: Text('Acciones', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                      ],
                      rows: sensores.map((s) => DataRow(cells: [
                        DataCell(Text(s['id'], style: TextStyle(color: Colors.white, fontSize: 20))),
                        DataCell(Text(s['tipo'], style: TextStyle(color: Colors.white70, fontSize: 19))),
                        DataCell(Row(children: [
                          Icon(Icons.circle, color: s['estado'] == 'Activo' ? Colors.greenAccent : s['estado'] == 'Fallo' ? Colors.redAccent : Colors.amberAccent, size: 22),
                          SizedBox(width: 10),
                          Text(s['estado'], style: TextStyle(color: Colors.white, fontSize: 19)),
                        ])),
                        DataCell(Text(s['bateria'] != null ? '${s['bateria']}%' : '-', style: TextStyle(color: Colors.white, fontSize: 19))),
                        DataCell(Text(s['luz'] != null ? '${s['luz']} lux' : '-', style: TextStyle(color: Colors.white, fontSize: 19))),
                        DataCell(Text(s['ubicacion'], style: TextStyle(color: Colors.white70, fontSize: 19))),
                        DataCell(Text(s['ultima'], style: TextStyle(color: Colors.white54, fontSize: 18))),
                        DataCell(Row(children: [
                          IconButton(icon: Icon(Icons.show_chart, color: Colors.blueAccent, size: 30), tooltip: 'Historial', onPressed: () {}),
                          IconButton(icon: Icon(Icons.edit, color: Colors.amberAccent, size: 30), tooltip: 'Editar', onPressed: () {}),
                          IconButton(icon: Icon(Icons.build, color: Colors.greenAccent, size: 30), tooltip: 'Mantenimiento', onPressed: () {}),
                        ])),
                      ])).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiSensor extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double size;
  const _KpiSensor({required this.icon, required this.label, required this.value, required this.color, this.size = 22});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size * 0.8, vertical: size * 0.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(size),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: size),
          SizedBox(width: size * 0.35),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: size * 0.73)),
              Text(label, style: TextStyle(color: Colors.white70, fontSize: size * 0.55)),
            ],
          ),
        ],
      ),
    );
  }
}
