
import 'package:flutter/material.dart';


class PantallaUsuarios extends StatefulWidget {
  @override
  State<PantallaUsuarios> createState() => _PantallaUsuariosState();
}

class _PantallaUsuariosState extends State<PantallaUsuarios> {
  late Future<List<Map<String, dynamic>>> _usuariosFuture;

  @override
  void initState() {
    super.initState();
    _usuariosFuture = _obtenerUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181C2E),
      appBar: AppBar(
        title: const Text('Gestión de Usuarios', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, letterSpacing: 0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, color: Colors.amberAccent, size: 34),
            tooltip: 'Agregar usuario',
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 32, offset: Offset(0, 12))],
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Usuarios del sistema', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26, letterSpacing: 0.2)),
              const SizedBox(height: 28),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _usuariosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error al cargar usuarios', style: TextStyle(color: Colors.redAccent)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No hay usuarios registrados', style: TextStyle(color: Colors.white70)));
                    }
                    final usuarios = snapshot.data!;
                    return ListView.separated(
                      itemCount: usuarios.length,
                      separatorBuilder: (_, __) => SizedBox(height: 22),
                      itemBuilder: (context, i) {
                        final u = usuarios[i];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 3))],
                            border: Border.all(color: Colors.white12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 32,
                              backgroundColor: u['estado'] == 'Activo' ? Colors.greenAccent : Colors.redAccent,
                              child: Icon(Icons.person, color: Colors.black, size: 34),
                            ),
                            title: Text(u['nombre'] ?? '', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                            subtitle: Text(u['rol'] ?? '', style: TextStyle(color: Colors.white70, fontSize: 16)),
                            trailing: Text(u['estado'] ?? '', style: TextStyle(color: u['estado'] == 'Activo' ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                        );
                      },
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

  /// Método temporal para obtener usuarios (implementación futura)
  Future<List<Map<String, dynamic>>> _obtenerUsuarios() async {
    // TODO: Implementar usando los servicios reales cuando estén listos
    return [];
  }
}
