
import 'package:flutter/material.dart';


class PantallaReportes extends StatefulWidget {
  @override
  State<PantallaReportes> createState() => _PantallaReportesState();
}

class _PantallaReportesState extends State<PantallaReportes> {
  late Future<List<Map<String, dynamic>>> _lecturasFuture;

  @override
  void initState() {
    super.initState();
    _lecturasFuture = Future.value(<Map<String, dynamic>>[]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181C2E),
      appBar: AppBar(
        title: const Text('Lecturas de Sensores', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, letterSpacing: 0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_alert, color: Colors.amberAccent, size: 34),
            tooltip: 'Agregar lectura',
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
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _lecturasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar lecturas', style: TextStyle(color: Colors.redAccent)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay lecturas registradas', style: TextStyle(color: Colors.white70)));
                  }
                  final lecturas = snapshot.data!;
                  final total = lecturas.length;
                  final recientes = lecturas.where((l) {
                    if (l['fecha'] == null) return false;
                    final fecha = DateTime.tryParse(l['fecha'].toString());
                    if (fecha == null) return false;
                    return fecha.isAfter(DateTime.now().subtract(Duration(days: 1)));
                  }).length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _KpiReporte(icon: Icons.bar_chart, label: 'Total', value: total.toString(), color: Colors.blueAccent, size: 32),
                            SizedBox(width: 32),
                            _KpiReporte(icon: Icons.update, label: 'Recientes', value: recientes.toString(), color: Colors.greenAccent, size: 32),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '🔍 Buscar por ID, fecha, nodo...',
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
                                DataColumn(label: SizedBox(width: 160, child: Text('Fecha', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                                DataColumn(label: SizedBox(width: 160, child: Text('Nodo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                                DataColumn(label: SizedBox(width: 160, child: Text('Valor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                                DataColumn(label: SizedBox(width: 160, child: Text('Acciones', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                              ],
                              rows: lecturas.map((l) => DataRow(cells: [
                                DataCell(Text(l['id']?.toString() ?? '', style: TextStyle(color: Colors.white, fontSize: 20))),
                                DataCell(Text(l['fecha']?.toString() ?? '', style: TextStyle(color: Colors.white54, fontSize: 18))),
                                DataCell(Text(l['nodo_id']?.toString() ?? '', style: TextStyle(color: Colors.white70, fontSize: 19))),
                                DataCell(Text(l['valor']?.toString() ?? '', style: TextStyle(color: Colors.white, fontSize: 19))),
                                DataCell(Row(children: [
                                  IconButton(icon: Icon(Icons.show_chart, color: Colors.blueAccent, size: 30), tooltip: 'Ver detalle', onPressed: () {}),
                                ])),
                              ])).toList(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  );
                },
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

  const _KpiReporte({required this.icon, required this.label, required this.value, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: color.withOpacity(0.18), blurRadius: 12, offset: Offset(0, 4))],
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: size),
          SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 22)),
            ],
          ),
        ],
      ),
    );
  }


}
