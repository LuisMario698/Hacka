import 'package:flutter/material.dart';
import '../../servicios/auth_service.dart';
import 'pantalla_mapa_interactivo.dart';
import 'pantalla_reportes.dart';
import 'pantalla_perfil_usuario.dart';
import 'pantalla_rutas_guardadas.dart';

class PantallaHome extends StatefulWidget {
  @override
  _PantallaHomeState createState() => _PantallaHomeState();
}

class _PantallaHomeState extends State<PantallaHome> {
  int _currentIndex = 0;
  String _nombreUsuario = 'Usuario';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF667eea),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_outlined),
            activeIcon: Icon(Icons.report),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
              onPressed: _mostrarBotonPanico,
              backgroundColor: Colors.red,
              child: Icon(Icons.emergency, color: Colors.white),
              heroTag: 'panic_button',
            )
          : null,
    );
  }

  void _mostrarBotonPanico() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Botón de Pánico'),
          ],
        ),
        content: Text(
          '¿Estás en una situación de emergencia?\n\n'
          'Se enviará tu ubicación a tus contactos de confianza.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _activarAlertaEmergencia();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('ACTIVAR SOS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _activarAlertaEmergencia() {
    // TODO: Implementar envío de alerta
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚨 Alerta de emergencia activada'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Rutas Seguras'),
        backgroundColor: Color(0xFF667eea),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navegar a notificaciones
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con gradiente
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ),
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, $nombreUsuario! 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '¿A dónde quieres ir hoy?',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Búsqueda de rutas
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: onNavigateToMap,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFF667eea).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.search,
                                color: Color(0xFF667eea),
                                size: 32,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Buscar ruta segura',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Encuentra el camino más seguro',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Accesos rápidos
                  Text(
                    'Accesos Rápidos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _AccesoRapido(
                        icon: Icons.route,
                        title: 'Mis Rutas',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PantallaRutasGuardadas(),
                            ),
                          );
                        },
                      ),
                      _AccesoRapido(
                        icon: Icons.sensors,
                        title: 'Sensores',
                        color: Colors.green,
                        onTap: onNavigateToMap,
                      ),
                      _AccesoRapido(
                        icon: Icons.history,
                        title: 'Historial',
                        color: Colors.orange,
                        onTap: () {
                          // TODO: Navegar a historial
                        },
                      ),
                      _AccesoRapido(
                        icon: Icons.people,
                        title: 'Contactos',
                        color: Colors.purple,
                        onTap: () {
                          // TODO: Navegar a contactos
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Estadísticas
                  Text(
                    'Tus Estadísticas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _TarjetaEstadistica(
                          icon: Icons.route,
                          value: '23',
                          label: 'Rutas tomadas',
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _TarjetaEstadistica(
                          icon: Icons.schedule,
                          value: '12h',
                          label: 'Tiempo seguro',
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _TarjetaEstadistica(
                          icon: Icons.report,
                          value: '5',
                          label: 'Reportes hechos',
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _TarjetaEstadistica(
                          icon: Icons.emoji_events,
                          value: '3',
                          label: 'Insignias',
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Alertas recientes
                  Text(
                    'Alertas Recientes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  
                  _AlertaCard(
                    icon: Icons.warning_amber_rounded,
                    title: 'Zona de precaución',
                    description: 'Calle Principal - Bajo nivel de iluminación',
                    color: Colors.orange,
                    time: 'Hace 2 horas',
                  ),
                  SizedBox(height: 8),
                  _AlertaCard(
                    icon: Icons.lightbulb_outline,
                    title: 'Sensor reparado',
                    description: 'Av. Universidad - Sensor ya funcional',
                    color: Colors.green,
                    time: 'Hace 5 horas',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== WIDGETS AUXILIARES =====
class _AccesoRapido extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _AccesoRapido({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaEstadistica extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _TarjetaEstadistica({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertaCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String time;

  const _AlertaCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
