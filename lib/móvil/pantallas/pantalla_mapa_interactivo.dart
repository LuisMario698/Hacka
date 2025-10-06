import 'package:flutter/material.dart';

class PantallaMapaInteractivo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa Interactivo'),
        backgroundColor: Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Mapa con sensores - En desarrollo'),
      ),
    );
  }
}
