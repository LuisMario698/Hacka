import 'package:flutter/material.dart';
import 'pantallas/pantalla_inicio.dart';
import 'tema/tema_seguro.dart';

void main() {
  runApp(AppMovilSegura());
}

class AppMovilSegura extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rutas Seguras',
      theme: temaSeguro(),
      home: PantallaInicio(),
      debugShowCheckedModeBanner: false,
    );
  }
}
