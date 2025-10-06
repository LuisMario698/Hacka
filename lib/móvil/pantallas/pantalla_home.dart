import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../servicios/auth_service.dart';
import 'pantalla_mapa_interactivo.dart';
import 'pantalla_reportes.dart';
import 'pantalla_perfil_usuario.dart';
import 'pantalla_rutas_guardadas.dart';
import '../componentes/boton_panico_mejorado.dart';
import '../componentes/componentes_ui_profesionales.dart';
import '../tema/tema_profesional.dart';

class PantallaHome extends StatefulWidget {
  @override
  _PantallaHomeState createState() => _PantallaHomeState();
}

class _PantallaHomeState extends State<PantallaHome> with WidgetsBindingObserver {
  int _currentIndex = 0;
  String _nombreUsuario = 'Usuario';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  void _cargarDatosUsuario() {
    // Obtener datos del usuario de la sesión
    final userData = AuthService.obtenerSesion();
    if (userData != null) {
      setState(() {
        _nombreUsuario = userData['nombre'] ?? 'Usuario';
      });
    }
  }

  List<Widget> _construirPaginas() {
    return [
      _PaginaInicio(
        onNavigateToMap: () => setState(() => _currentIndex = 1),
        nombreUsuario: _nombreUsuario,
      ),
      PantallaMapaInteractivo(),
      PantallaReportes(),
      PantallaPerfilUsuario(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final paginas = _construirPaginas();
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: paginas,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black26
                  : Colors.black12,
              offset: Offset(0, -2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: EspaciadoProfesional.md,
              vertical: EspaciadoProfesional.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavigationItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Inicio',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavigationItem(
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map_rounded,
                  label: 'Mapa',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavigationItem(
                  icon: Icons.assessment_outlined,
                  activeIcon: Icons.assessment_rounded,
                  label: 'Reportes',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavigationItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Perfil',
                  isActive: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0 // Solo en la página de inicio
          ? BotonPanicoMejorado(
              onActivarEmergencia: _activarAlertaEmergencia,
            )
          : null,
    );
  }

  void _activarAlertaEmergencia() {
    ServicioEmergencia.activarAlertaEmergencia(context);
  }
}

// ===== PÁGINA DE INICIO =====
class _PaginaInicio extends StatelessWidget {
  final VoidCallback onNavigateToMap;
  final String nombreUsuario;

  const _PaginaInicio({
    required this.onNavigateToMap,
    required this.nombreUsuario,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Actualizar PaletaProfesional según el tema actual
    PaletaProfesional.setTemaOscuro(isDark);
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBarConsistente(
        titulo: 'Rutas Seguras',
        colorFondo: Colors.transparent,
        acciones: [
          Container(
            margin: EdgeInsets.only(right: EspaciadoProfesional.md),
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(RadiosProfesionales.sm),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              onPressed: () {
                // TODO: Navegar a notificaciones
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header minimalista y elegante
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(EspaciadoProfesional.md),
              padding: EdgeInsets.all(EspaciadoProfesional.lg),
              decoration: BoxDecoration(
                gradient: PaletaProfesional.gradientePrimario,
                borderRadius: BorderRadius.circular(RadiosProfesionales.lg),
                boxShadow: SombrasProfesionales.elevacion2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(RadiosProfesionales.md),
                        ),
                        child: Icon(
                          Icons.waving_hand_rounded,
                          color: PaletaProfesional.textoBlanco,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: EspaciadoProfesional.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, $nombreUsuario',
                              style: TextStyle(
                                color: PaletaProfesional.textoBlanco,
                                fontSize: TipografiaProfesional.h3,
                                fontWeight: TipografiaProfesional.semibold,
                                height: TipografiaProfesional.lineHeightTight,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tu seguridad es nuestra prioridad',
                              style: TextStyle(
                                color: PaletaProfesional.textoBlanco.withOpacity(0.9),
                                fontSize: TipografiaProfesional.body2,
                                fontWeight: TipografiaProfesional.regular,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: EspaciadoProfesional.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Búsqueda de rutas - diseño profesional
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: PaletaProfesional.fondoTarjeta,
                      borderRadius: BorderRadius.circular(RadiosProfesionales.lg),
                      border: Border.all(
                        color: PaletaProfesional.divider,
                        width: 1,
                      ),
                      boxShadow: SombrasProfesionales.elevacion1,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onNavigateToMap,
                        borderRadius: BorderRadius.circular(RadiosProfesionales.lg),
                        child: Padding(
                          padding: EdgeInsets.all(EspaciadoProfesional.lg),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(EspaciadoProfesional.md),
                                decoration: BoxDecoration(
                                  color: PaletaProfesional.primarioSuave,
                                  borderRadius: BorderRadius.circular(RadiosProfesionales.md),
                                ),
                                child: Icon(
                                  Icons.route_rounded,
                                  color: PaletaProfesional.primario,
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: EspaciadoProfesional.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Planificar ruta segura',
                                      style: TextStyle(
                                        color: PaletaProfesional.textoPrimario,
                                        fontSize: TipografiaProfesional.h4,
                                        fontWeight: TipografiaProfesional.semibold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Encuentra el camino más seguro a tu destino',
                                      style: TextStyle(
                                        color: PaletaProfesional.textoSecundario,
                                        fontSize: TipografiaProfesional.body2,
                                        fontWeight: TipografiaProfesional.regular,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: PaletaProfesional.primarioSuave,
                                  borderRadius: BorderRadius.circular(RadiosProfesionales.sm),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: PaletaProfesional.primario,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: EspaciadoProfesional.sectionSpacing),

                  // Accesos rápidos - diseño profesional
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: PaletaProfesional.primario,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: EspaciadoProfesional.sm),
                      Text(
                        'Accesos Rápidos',
                        style: TextStyle(
                          color: PaletaProfesional.textoPrimario,
                          fontSize: TipografiaProfesional.h4,
                          fontWeight: TipografiaProfesional.semibold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: EspaciadoProfesional.md),
                  
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisSpacing: EspaciadoProfesional.md,
                    mainAxisSpacing: EspaciadoProfesional.md,
                    childAspectRatio: 1.4,
                    children: [
                      _AccesoRapidoProfesional(
                        icon: Icons.bookmark_rounded,
                        title: 'Mis Rutas',
                        subtitle: 'Rutas guardadas',
                        color: PaletaProfesional.secundario,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PantallaRutasGuardadas(),
                            ),
                          );
                        },
                      ),
                      _AccesoRapidoProfesional(
                        icon: Icons.sensors_rounded,
                        title: 'Sensores',
                        subtitle: 'Estado en vivo',
                        color: PaletaProfesional.seguro,
                        onTap: onNavigateToMap,
                      ),
                      _AccesoRapidoProfesional(
                        icon: Icons.history_rounded,
                        title: 'Historial',
                        subtitle: 'Rutas anteriores',
                        color: PaletaProfesional.precaucion,
                        onTap: () {
                          // TODO: Navegar a historial
                        },
                      ),
                      _AccesoRapidoProfesional(
                        icon: Icons.contacts_rounded,
                        title: 'Contactos',
                        subtitle: 'Emergencia',
                        color: Colors.deepPurple,
                        onTap: () {
                          // TODO: Navegar a contactos
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: EspaciadoProfesional.sectionSpacing),

                  // Estadísticas - diseño profesional
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(EspaciadoProfesional.lg),
                    decoration: BoxDecoration(
                      color: PaletaProfesional.fondoTarjeta,
                      borderRadius: BorderRadius.circular(RadiosProfesionales.lg),
                      border: Border.all(
                        color: PaletaProfesional.divider,
                        width: 1,
                      ),
                      boxShadow: SombrasProfesionales.elevacion1,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: PaletaProfesional.secundarioSuave,
                                borderRadius: BorderRadius.circular(RadiosProfesionales.sm),
                              ),
                              child: Icon(
                                Icons.analytics_rounded,
                                color: PaletaProfesional.secundario,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: EspaciadoProfesional.sm),
                            Text(
                              'Tus Estadísticas',
                              style: TextStyle(
                                color: PaletaProfesional.textoPrimario,
                                fontSize: TipografiaProfesional.h4,
                                fontWeight: TipografiaProfesional.semibold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: EspaciadoProfesional.lg),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _TarjetaEstadisticaProfesional(
                                icon: Icons.route_rounded,
                                value: '23',
                                label: 'Rutas tomadas',
                                color: PaletaProfesional.secundario,
                              ),
                            ),
                            SizedBox(width: EspaciadoProfesional.md),
                            Expanded(
                              child: _TarjetaEstadisticaProfesional(
                                icon: Icons.timer_rounded,
                                value: '12h',
                                label: 'Tiempo seguro',
                                color: PaletaProfesional.seguro,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: EspaciadoProfesional.md),
                        Row(
                          children: [
                            Expanded(
                              child: _TarjetaEstadisticaProfesional(
                                icon: Icons.report_rounded,
                                value: '5',
                                label: 'Reportes hechos',
                                color: PaletaProfesional.precaucion,
                              ),
                            ),
                            SizedBox(width: EspaciadoProfesional.md),
                            Expanded(
                              child: _TarjetaEstadisticaProfesional(
                                icon: Icons.emoji_events_rounded,
                                value: '3',
                                label: 'Insignias',
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: EspaciadoProfesional.sectionSpacing),

                  // Alertas recientes - diseño profesional
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: PaletaProfesional.precaucion,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: EspaciadoProfesional.sm),
                      Expanded(
                        child: Text(
                          'Alertas Recientes',
                          style: TextStyle(
                            color: PaletaProfesional.textoPrimario,
                            fontSize: TipografiaProfesional.h4,
                            fontWeight: TipografiaProfesional.semibold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Ver todas las alertas
                        },
                        child: Text(
                          'Ver todas',
                          style: TextStyle(
                            color: PaletaProfesional.primario,
                            fontSize: TipografiaProfesional.body2,
                            fontWeight: TipografiaProfesional.medium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: EspaciadoProfesional.md),
                  
                  _AlertaCardProfesional(
                    icon: Icons.warning_amber_rounded,
                    title: 'Zona de precaución',
                    description: 'Calle Principal - Bajo nivel de iluminación detectado',
                    color: PaletaProfesional.precaucion,
                    time: 'Hace 2 horas',
                  ),
                  SizedBox(height: EspaciadoProfesional.sm),
                  _AlertaCardProfesional(
                    icon: Icons.lightbulb_rounded,
                    title: 'Sensor restaurado',
                    description: 'Av. Universidad - Sistema de iluminación funcional',
                    color: PaletaProfesional.seguro,
                    time: 'Hace 5 horas',
                  ),
                  SizedBox(height: EspaciadoProfesional.sectionSpacing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== WIDGETS AUXILIARES PROFESIONALES =====

/// Widget de navegación inferior personalizado con diseño profesional
class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Actualizar PaletaProfesional según el tema actual
    final isDark = Theme.of(context).brightness == Brightness.dark;
    PaletaProfesional.setTemaOscuro(isDark);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: EspaciadoProfesional.sm,
          horizontal: EspaciadoProfesional.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AnimacionesProfesionales.normal,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive
                    ? PaletaProfesional.primarioSuave
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(RadiosProfesionales.sm),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive
                    ? PaletaProfesional.primario
                    : PaletaProfesional.textoTerciario,
                size: 24,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? PaletaProfesional.primario
                    : PaletaProfesional.textoTerciario,
                fontSize: TipografiaProfesional.caption,
                fontWeight: isActive
                    ? TipografiaProfesional.medium
                    : TipografiaProfesional.regular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de acceso rápido con diseño profesional
class _AccesoRapidoProfesional extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AccesoRapidoProfesional({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Actualizar PaletaProfesional según el tema actual
    final isDark = Theme.of(context).brightness == Brightness.dark;
    PaletaProfesional.setTemaOscuro(isDark);
    
    return Container(
      decoration: BoxDecoration(
        color: PaletaProfesional.fondoTarjeta,
        borderRadius: BorderRadius.circular(RadiosProfesionales.md),
        border: Border.all(
          color: PaletaProfesional.divider,
          width: 1,
        ),
        boxShadow: SombrasProfesionales.elevacion1,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RadiosProfesionales.md),
          child: Padding(
            padding: EdgeInsets.all(EspaciadoProfesional.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(EspaciadoProfesional.sm),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(RadiosProfesionales.sm),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    color: PaletaProfesional.textoPrimario,
                    fontSize: TipografiaProfesional.body1,
                    fontWeight: TipografiaProfesional.semibold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: PaletaProfesional.textoSecundario,
                    fontSize: TipografiaProfesional.caption,
                    fontWeight: TipografiaProfesional.regular,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget de estadística con diseño profesional
class _TarjetaEstadisticaProfesional extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _TarjetaEstadisticaProfesional({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Actualizar PaletaProfesional según el tema actual
    final isDark = Theme.of(context).brightness == Brightness.dark;
    PaletaProfesional.setTemaOscuro(isDark);
    
    return Container(
      padding: EdgeInsets.all(EspaciadoProfesional.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(RadiosProfesionales.md),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: EspaciadoProfesional.sm),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: TipografiaProfesional.h3,
              fontWeight: TipografiaProfesional.bold,
              height: TipografiaProfesional.lineHeightTight,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: PaletaProfesional.textoSecundario,
              fontSize: TipografiaProfesional.caption,
              fontWeight: TipografiaProfesional.regular,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de alerta con diseño profesional
class _AlertaCardProfesional extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String time;

  const _AlertaCardProfesional({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    // Actualizar PaletaProfesional según el tema actual
    final isDark = Theme.of(context).brightness == Brightness.dark;
    PaletaProfesional.setTemaOscuro(isDark);
    
    return Container(
      padding: EdgeInsets.all(EspaciadoProfesional.md),
      decoration: BoxDecoration(
        color: PaletaProfesional.fondoTarjeta,
        borderRadius: BorderRadius.circular(RadiosProfesionales.md),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: SombrasProfesionales.elevacion1,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(EspaciadoProfesional.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(RadiosProfesionales.sm),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(width: EspaciadoProfesional.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: PaletaProfesional.textoPrimario,
                    fontSize: TipografiaProfesional.body2,
                    fontWeight: TipografiaProfesional.semibold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: PaletaProfesional.textoSecundario,
                    fontSize: TipografiaProfesional.caption,
                    fontWeight: TipografiaProfesional.regular,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: PaletaProfesional.textoTerciario,
                    fontSize: 11,
                    fontWeight: TipografiaProfesional.regular,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
