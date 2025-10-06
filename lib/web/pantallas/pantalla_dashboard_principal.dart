import 'package:flutter/material.dart';
import '../../servicios/auth_service.dart';
import 'pantalla_dashboard_home.dart';
import 'pantalla_sensores_nueva.dart';
import 'pantalla_reportes_nueva.dart';
import 'pantalla_usuarios_nueva.dart';
import 'pantalla_analitica.dart';
import 'pantalla_configuracion.dart';
import 'pantalla_login_web.dart';

class PantallaDashboardPrincipal extends StatefulWidget {
  @override
  _PantallaDashboardPrincipalState createState() =>
      _PantallaDashboardPrincipalState();
}

class _PantallaDashboardPrincipalState
    extends State<PantallaDashboardPrincipal> {
  int _selectedIndex = 0;
  String _nombreUsuario = 'Admin';
  String _rolUsuario = 'Administrador';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  void _cargarDatosUsuario() {
    final userData = AuthService.obtenerSesion();
    if (userData != null) {
      setState(() {
        _nombreUsuario = userData['nombre'] ?? 'Admin';
        _rolUsuario = userData['rol_nombre'] ?? 'administrador';
      });
    }
  }

  final List<_MenuItem> _menuItems = [
    _MenuItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      requiereRolMinimo: 2, // moderador o superior
    ),
    _MenuItem(
      icon: Icons.sensors,
      label: 'Sensores',
      requiereRolMinimo: 2,
    ),
    _MenuItem(
      icon: Icons.report,
      label: 'Reportes',
      requiereRolMinimo: 2,
    ),
    _MenuItem(
      icon: Icons.people,
      label: 'Usuarios',
      requiereRolMinimo: 3, // solo admins
    ),
    _MenuItem(
      icon: Icons.analytics,
      label: 'Analítica',
      requiereRolMinimo: 3,
    ),
    _MenuItem(
      icon: Icons.settings,
      label: 'Configuración',
      requiereRolMinimo: 3,
    ),
  ];

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return PantallaDashboardHome();
      case 1:
        return PantallaSensoresNueva();
      case 2:
        return PantallaReportesNueva();
      case 3:
        return PantallaUsuariosNueva();
      case 4:
        return PantallaAnalitica();
      case 5:
        return PantallaConfiguracion();
      default:
        return PantallaDashboardHome();
    }
  }

  bool _tieneAcceso(int rolRequerido) {
    final rolId = AuthService.obtenerRolId() ?? 1;
    return rolId >= rolRequerido;
  }

  void _cerrarSesion() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cerrar Sesión'),
        content: Text('¿Estás seguro que deseas salir del dashboard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService.cerrarSesion();
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => PantallaLoginWeb()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Salir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.shield, size: 28),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rutas Seguras',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Centro de Control',
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Color(0xFF667eea),
        foregroundColor: Colors.white,
        actions: [
          // Notificaciones
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '3',
                      style: TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // TODO: Mostrar notificaciones
            },
          ),
          SizedBox(width: 16),

          // Usuario
          PopupMenuButton(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF667eea),
                    ),
                  ),
                  if (!isMobile) ...[
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _nombreUsuario,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _rolUsuario,
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Mi Perfil'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  // TODO: Navegar a perfil
                },
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Cerrar Sesión',
                      style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: _cerrarSesion,
              ),
            ],
          ),
        ],
      ),
      drawer: isMobile
          ? Drawer(
              child: _buildSidebar(),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(),
          Expanded(
            child: _getSelectedPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.grey[50],
      child: Column(
        children: [
          // Header del menú
          Container(
            padding: EdgeInsets.all(20),
            color: Color(0xFF667eea).withOpacity(0.1),
            child: Column(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 48,
                  color: Color(0xFF667eea),
                ),
                SizedBox(height: 8),
                Text(
                  'Panel Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667eea),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),

          // Menú items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final tieneAcceso = _tieneAcceso(item.requiereRolMinimo);
                final isSelected = _selectedIndex == index;

                if (!tieneAcceso) {
                  return SizedBox.shrink(); // No mostrar si no tiene acceso
                }

                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: isSelected ? Color(0xFF667eea) : Colors.grey[600],
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected ? Color(0xFF667eea) : Colors.grey[800],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: Color(0xFF667eea).withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    // Cerrar drawer en móvil
                    if (MediaQuery.of(context).size.width < 900) {
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),

          // Footer
          Divider(height: 1),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Rol actual: $_rolUsuario',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final int requiereRolMinimo; // 1=usuario, 2=moderador, 3=admin, 4=super_admin

  _MenuItem({
    required this.icon,
    required this.label,
    required this.requiereRolMinimo,
  });
}
