import 'package:flutter/material.dart';
import '../../servicios/auth_service.dart';
import 'pantalla_login.dart';
import 'configuracion_accesibilidad.dart';
import '../tema/tema_profesional.dart';
import '../tema/servicio_tema.dart';
import '../componentes/componentes_ui_profesionales.dart';

class PantallaPerfilUsuario extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Actualizar PaletaProfesional según el tema actual
    final isDark = Theme.of(context).brightness == Brightness.dark;
    PaletaProfesional.setTemaOscuro(isDark);
    
    // Obtener datos del usuario actual
    final userData = AuthService.obtenerSesion();
    final nombre = userData?['nombre'] ?? 'Usuario';
    final email = userData?['email'] ?? '';
    final rolNombre = userData?['rol_nombre'] ?? 'usuario';

    return Scaffold(
      backgroundColor: PaletaProfesional.fondoApp,
      appBar: AppBarConsistente(
        titulo: 'Mi Perfil',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(EspaciadoProfesional.md),
        child: Column(
          children: [
            // Header del perfil profesional
            TarjetaProfesional(
              child: Column(
                children: [
                  // Avatar elegante
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: PaletaProfesional.gradientePrimario,
                      boxShadow: SombrasProfesionales.elevacion3,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: PaletaProfesional.textoBlanco,
                    ),
                  ),
                  SizedBox(height: EspaciadoProfesional.lg),
                  
                  // Información del usuario
                  Text(
                    nombre,
                    style: TextStyle(
                      color: PaletaProfesional.textoPrimario,
                      fontSize: TipografiaProfesional.h2,
                      fontWeight: TipografiaProfesional.semibold,
                    ),
                  ),
                  SizedBox(height: EspaciadoProfesional.sm),
                  Text(
                    email,
                    style: TextStyle(
                      color: PaletaProfesional.textoSecundario,
                      fontSize: TipografiaProfesional.body1,
                      fontWeight: TipografiaProfesional.regular,
                    ),
                  ),
                  SizedBox(height: EspaciadoProfesional.md),
                  
                  // Rol del usuario
                  ChipProfesional(
                    texto: rolNombre.toUpperCase(),
                    icono: Icons.verified_user_rounded,
                    color: PaletaProfesional.secundario,
                    seleccionado: true,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: EspaciadoProfesional.sectionSpacing),
            
            // Opciones del perfil
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuración',
                  style: TextStyle(
                    color: PaletaProfesional.textoPrimario,
                    fontSize: TipografiaProfesional.h4,
                    fontWeight: TipografiaProfesional.semibold,
                  ),
                ),
                SizedBox(height: EspaciadoProfesional.md),
                
                // Toggle de tema oscuro/claro
                TarjetaProfesional(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(EspaciadoProfesional.md),
                        decoration: BoxDecoration(
                          color: PaletaProfesional.secundarioSuave,
                          borderRadius: BorderRadius.circular(RadiosProfesionales.md),
                        ),
                        child: Icon(
                          ServicioTema().esTemaOscuro ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: PaletaProfesional.secundario,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: EspaciadoProfesional.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tema de la aplicación',
                              style: TextStyle(
                                color: PaletaProfesional.textoPrimario,
                                fontSize: TipografiaProfesional.body1,
                                fontWeight: TipografiaProfesional.semibold,
                              ),
                            ),
                            Text(
                              ServicioTema().esTemaOscuro ? 'Modo oscuro activo' : 'Modo claro activo',
                              style: TextStyle(
                                color: PaletaProfesional.textoSecundario,
                                fontSize: TipografiaProfesional.body2,
                                fontWeight: TipografiaProfesional.regular,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: ServicioTema().esTemaOscuro,
                        onChanged: (valor) {
                          ServicioTema().cambiarTema(valor);
                        },
                        activeColor: PaletaProfesional.secundario,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: EspaciadoProfesional.md),
                
                // Botón de accesibilidad
                TarjetaProfesional(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfiguracionAccesibilidad(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(EspaciadoProfesional.md),
                        decoration: BoxDecoration(
                          color: PaletaProfesional.seguro.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(RadiosProfesionales.md),
                        ),
                        child: Icon(
                          Icons.accessibility_new_rounded,
                          color: PaletaProfesional.seguro,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: EspaciadoProfesional.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Accesibilidad',
                              style: TextStyle(
                                color: PaletaProfesional.textoPrimario,
                                fontSize: TipografiaProfesional.body1,
                                fontWeight: TipografiaProfesional.semibold,
                              ),
                            ),
                            Text(
                              'Configurar opciones de accesibilidad',
                              style: TextStyle(
                                color: PaletaProfesional.textoSecundario,
                                fontSize: TipografiaProfesional.body2,
                                fontWeight: TipografiaProfesional.regular,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: PaletaProfesional.textoTerciario,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: EspaciadoProfesional.md),
                
                // Botón de cerrar sesión
                TarjetaProfesional(
                  colorBorde: PaletaProfesional.peligro.withOpacity(0.3),
                  onTap: () => _mostrarDialogoCerrarSesion(context),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(EspaciadoProfesional.md),
                        decoration: BoxDecoration(
                          color: PaletaProfesional.peligro.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(RadiosProfesionales.md),
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          color: PaletaProfesional.peligro,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: EspaciadoProfesional.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cerrar Sesión',
                              style: TextStyle(
                                color: PaletaProfesional.peligro,
                                fontSize: TipografiaProfesional.body1,
                                fontWeight: TipografiaProfesional.semibold,
                              ),
                            ),
                            Text(
                              'Salir de tu cuenta actual',
                              style: TextStyle(
                                color: PaletaProfesional.textoSecundario,
                                fontSize: TipografiaProfesional.body2,
                                fontWeight: TipografiaProfesional.regular,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: PaletaProfesional.peligro.withOpacity(0.7),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PaletaProfesional.superficie,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiosProfesionales.lg),
        ),
        title: Text(
          'Cerrar Sesión',
          style: TextStyle(
            color: PaletaProfesional.textoPrimario,
            fontSize: TipografiaProfesional.h4,
            fontWeight: TipografiaProfesional.semibold,
          ),
        ),
        content: Text(
          '¿Estás seguro que deseas salir de tu cuenta?',
          style: TextStyle(
            color: PaletaProfesional.textoSecundario,
            fontSize: TipografiaProfesional.body1,
            fontWeight: TipografiaProfesional.regular,
          ),
        ),
        actions: [
          BotonSecundarioProfesional(
            texto: 'Cancelar',
            esCompleto: false,
            onPressed: () => Navigator.pop(ctx),
          ),
          SizedBox(width: EspaciadoProfesional.sm),
          BotonPrimarioProfesional(
            texto: 'Cerrar Sesión',
            esCompleto: false,
            onPressed: () async {
              // Cerrar sesión
              await AuthService.cerrarSesion();
              
              // Volver al login
              Navigator.of(ctx).pop(); // Cerrar diálogo
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
