import 'package:flutter/material.dart';

class PantallaReportes extends StatelessWidget {
  final List<Map<String, dynamic>> reportes = [
    {'tipo': 'Foco Descompuesto', 'estado': 'Pendiente', 'ubicacion': 'Calle 1', 'hora': '12:01', 'usuario': 'Anónimo'},
    {'tipo': 'Actividad Sospechosa', 'estado': 'Resuelto', 'ubicacion': 'Calle 2', 'hora': '11:58', 'usuario': 'Carlos'},
    {'tipo': 'Banqueta Rota', 'estado': 'Pendiente', 'ubicacion': 'Calle 3', 'hora': '11:55', 'usuario': 'María'},
    {'tipo': 'Presencia Policial', 'estado': 'Archivado', 'ubicacion': 'Calle 4', 'hora': '11:50', 'usuario': 'Ana'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181C2E),
      appBar: AppBar(
        title: const Text('Reportes de Comunidad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, letterSpacing: 0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_alert, color: Colors.amberAccent, size: 34),
            tooltip: 'Agregar reporte',
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _KpiReporte(icon: Icons.report, label: 'Total Hoy', value: reportes.length.toString(), color: Colors.amberAccent, size: 32),
                    SizedBox(width: 32),
                    _KpiReporte(icon: Icons.pending_actions, label: 'Pendientes', value: reportes.where((r) => r['estado'] == 'Pendiente').length.toString(), color: Colors.redAccent, size: 32),
                    SizedBox(width: 32),
                    _KpiReporte(icon: Icons.check_circle, label: 'Resueltos', value: reportes.where((r) => r['estado'] == 'Resuelto').length.toString(), color: Colors.greenAccent, size: 32),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              TextField(
                decoration: InputDecoration(
                  hintText: '🔍 Buscar por tipo, estado, ubicación...',
                  hintStyle: TextStyle(color: Colors.white54, fontSize: 18),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                ),
                style: TextStyle(color: Colors.white, fontSize: 18),
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
                        DataColumn(label: SizedBox(width: 180, child: Text('Tipo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                        DataColumn(label: SizedBox(width: 160, child: Text('Estado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                        DataColumn(label: SizedBox(width: 180, child: Text('Ubicación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                        DataColumn(label: SizedBox(width: 120, child: Text('Hora', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                        DataColumn(label: SizedBox(width: 140, child: Text('Usuario', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                        DataColumn(label: SizedBox(width: 180, child: Text('Acciones', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                      ],
                      rows: reportes.map((r) => DataRow(cells: [
                        DataCell(Text(r['tipo'], style: TextStyle(color: Colors.white, fontSize: 20))),
                        DataCell(Row(children: [
                          Icon(Icons.circle, color: r['estado'] == 'Pendiente' ? Colors.redAccent : r['estado'] == 'Resuelto' ? Colors.greenAccent : Colors.amberAccent, size: 22),
                          SizedBox(width: 10),
                          Text(r['estado'], style: TextStyle(color: Colors.white, fontSize: 19)),
                        ])),
                        DataCell(Text(r['ubicacion'], style: TextStyle(color: Colors.white70, fontSize: 19))),
                        DataCell(Text(r['hora'], style: TextStyle(color: Colors.white54, fontSize: 18))),
                        DataCell(Text(r['usuario'], style: TextStyle(color: Colors.white70, fontSize: 19))),
                        DataCell(Row(children: [
                          IconButton(icon: Icon(Icons.visibility, color: Colors.blueAccent, size: 30), tooltip: 'Ver', onPressed: () {}),
                          IconButton(icon: Icon(Icons.check, color: Colors.greenAccent, size: 30), tooltip: 'Resolver', onPressed: () {}),
                          IconButton(icon: Icon(Icons.archive, color: Colors.amberAccent, size: 30), tooltip: 'Archivar', onPressed: () {}),
                        ])),
                      ])).toList(),
                    ),
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

class _KpiReporte extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double size;
  const _KpiReporte({required this.icon, required this.label, required this.value, required this.color, this.size = 22});
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
