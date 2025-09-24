import 'package:flutter/material.dart';

class PantallaConfiguracion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181C2E),
      appBar: AppBar(
        title: const Text('Configuración', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, letterSpacing: 0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 32, offset: Offset(0, 12))],
            border: Border.all(color: Colors.white10),
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('Opciones de Sistema', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26, letterSpacing: 0.2)),
              const SizedBox(height: 18),
              SwitchListTile(
                title: Text('Notificaciones', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20)),
                value: true,
                onChanged: (v) {},
                activeColor: Colors.amberAccent,
                tileColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              SwitchListTile(
                title: Text('Modo Oscuro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20)),
                value: true,
                onChanged: (v) {},
                activeColor: Colors.amberAccent,
                tileColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              Divider(color: Colors.white24, height: 40, thickness: 1.2),
              Text('Seguridad', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26, letterSpacing: 0.2)),
              const SizedBox(height: 18),
              ListTile(
                leading: Icon(Icons.lock, color: Colors.amberAccent, size: 32),
                title: Text('Cambiar contraseña', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 19)),
                onTap: () {},
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                tileColor: Colors.white.withOpacity(0.04),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              ListTile(
                leading: Icon(Icons.fingerprint, color: Colors.greenAccent, size: 32),
                title: Text('Autenticación biométrica', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 19)),
                trailing: Switch(value: false, onChanged: (v) {}),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                tileColor: Colors.white.withOpacity(0.04),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              Divider(color: Colors.white24, height: 40, thickness: 1.2),
              Text('Personalización', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26, letterSpacing: 0.2)),
              const SizedBox(height: 18),
              ListTile(
                leading: Icon(Icons.palette, color: Colors.blueAccent, size: 32),
                title: Text('Tema de color', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 19)),
                onTap: () {},
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                tileColor: Colors.white.withOpacity(0.04),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              ListTile(
                leading: Icon(Icons.language, color: Colors.amberAccent, size: 32),
                title: Text('Idioma', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 19)),
                onTap: () {},
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                tileColor: Colors.white.withOpacity(0.04),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
