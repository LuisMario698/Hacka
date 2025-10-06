import 'package:flutter/material.dart';
import '../tema/tema_profesional.dart';
import '../componentes/componentes_ui_profesionales.dart';

class PantallaReportes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Actualizar PaletaProfesional según el tema actual
    final isDark = Theme.of(context).brightness == Brightness.dark;
    PaletaProfesional.setTemaOscuro(isDark);
    
    return Scaffold(
      backgroundColor: PaletaProfesional.fondoApp,
      appBar: AppBarConsistente(
        titulo: 'Reportes',
        acciones: [
          Container(
            margin: EdgeInsets.only(right: EspaciadoProfesional.md),
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PaletaProfesional.primarioSuave,
                  borderRadius: BorderRadius.circular(RadiosProfesionales.sm),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: PaletaProfesional.primario,
                  size: 20,
                ),
              ),
              onPressed: () {
                // TODO: Crear nuevo reporte
              },
              tooltip: 'Nuevo reporte',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(EspaciadoProfesional.md),
        child: Column(
          children: [
            // Estado de desarrollo elegante
            Expanded(
              child: Center(
                child: TarjetaProfesional(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(EspaciadoProfesional.lg),
                        decoration: BoxDecoration(
                          color: PaletaProfesional.secundarioSuave,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.construction_rounded,
                          color: PaletaProfesional.secundario,
                          size: 48,
                        ),
                      ),
                      SizedBox(height: EspaciadoProfesional.lg),
                      Text(
                        'Reportes en Desarrollo',
                        style: TextStyle(
                          color: PaletaProfesional.textoPrimario,
                          fontSize: TipografiaProfesional.h3,
                          fontWeight: TipografiaProfesional.semibold,
                        ),
                      ),
                      SizedBox(height: EspaciadoProfesional.sm),
                      Text(
                        'Esta funcionalidad estará disponible pronto.\nPodrás crear y gestionar reportes de seguridad.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: PaletaProfesional.textoSecundario,
                          fontSize: TipografiaProfesional.body1,
                          fontWeight: TipografiaProfesional.regular,
                          height: TipografiaProfesional.lineHeightRelaxed,
                        ),
                      ),
                      SizedBox(height: EspaciadoProfesional.lg),
                      BotonSecundarioProfesional(
                        texto: 'Notificarme cuando esté listo',
                        icono: Icons.notifications_outlined,
                        esCompleto: false,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Te notificaremos cuando esté disponible'),
                              backgroundColor: PaletaProfesional.primario,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
