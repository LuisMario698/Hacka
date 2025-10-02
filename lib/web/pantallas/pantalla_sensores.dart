import 'package:flutter/material.dart';


class PantallaSensores extends StatefulWidget {
  @override
  State<PantallaSensores> createState() => _PantallaSensoresState();
}

class _PantallaSensoresState extends State<PantallaSensores> {
  late Future<List<Map<String, dynamic>>> _nodosFuture;

  @override
  void initState() {
    super.initState();
    _nodosFuture = Future.value(<Map<String, dynamic>>[]);
  }

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
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _nodosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error al cargar nodos', style: TextStyle(color: Colors.redAccent)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No hay nodos registrados', style: TextStyle(color: Colors.white70)));
                    }
                    final nodos = snapshot.data!;
                    final total = nodos.length;
                    final activos = nodos.where((n) => n['activo'] == true).length;
                    final inactivos = nodos.where((n) => n['activo'] == false).length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _KpiSensor(icon: Icons.sensors, label: 'Total', value: total.toString(), color: Colors.blueAccent, size: 32),
                              SizedBox(width: 32),
                              _KpiSensor(icon: Icons.check_circle, label: 'Activos', value: activos.toString(), color: Colors.greenAccent, size: 32),
                              SizedBox(width: 32),
                              _KpiSensor(icon: Icons.warning_amber_rounded, label: 'Inactivos', value: inactivos.toString(), color: Colors.redAccent, size: 32),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: '🔍 Buscar por ID, nombre, activo...',
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
                                  DataColumn(label: SizedBox(width: 160, child: Text('Nombre', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                                  DataColumn(label: SizedBox(width: 160, child: Text('Activo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))),
                                ],
                                rows: nodos.map((n) => DataRow(cells: [
                                  DataCell(Text(n['id']?.toString() ?? '', style: TextStyle(color: Colors.white, fontSize: 20))),
                                  DataCell(Text(n['nombre']?.toString() ?? '', style: TextStyle(color: Colors.white70, fontSize: 19))),
                                  DataCell(Row(children: [
                                    Icon(Icons.circle, color: n['activo'] == true ? Colors.greenAccent : Colors.redAccent, size: 22),
                                    SizedBox(width: 10),
                                    Text(n['activo'] == true ? 'Sí' : 'No', style: TextStyle(color: Colors.white, fontSize: 19)),
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
              ),
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
