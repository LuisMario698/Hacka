import 'package:flutter/material.dart';
import 'pantallas/pantalla_panel.dart';
import 'tema/tema_seguro.dart';

void main() {
  runApp(AppWebCentroControl());
}

class AppWebCentroControl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centro de Control',
      theme: temaSeguro(),
      home: PantallaPanel(),
      debugShowCheckedModeBanner: false,
    );
  }
}
