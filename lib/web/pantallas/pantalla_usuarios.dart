import 'package:flutter/material.dart';

class PantallaUsuarios extends StatelessWidget {
  final List<Map<String, dynamic>> usuarios = [
    {'nombre': 'Ana López', 'rol': 'Administrador', 'estado': 'Activo'},
    {'nombre': 'Carlos Ruiz', 'rol': 'Operador', 'estado': 'Activo'},
    {'nombre': 'María Pérez', 'rol': 'Supervisor', 'estado': 'Bloqueado'},
    {'nombre': 'Juan Torres', 'rol': 'Operador', 'estado': 'Activo'},
  ];

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
                child: ListView.separated(
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
                        title: Text(u['nombre'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20)),
                        subtitle: Text(u['rol'], style: TextStyle(color: Colors.white70, fontSize: 16)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.amberAccent, size: 28),
                              tooltip: 'Editar',
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.block, color: Colors.redAccent, size: 28),
                              tooltip: u['estado'] == 'Activo' ? 'Bloquear' : 'Desbloquear',
                              onPressed: () {},
                            ),
                          ],
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      ),
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
