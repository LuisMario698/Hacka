import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../servicios/usuario_service.dart';
import '../../servicios/cache_service.dart';
import '../../modelos/usuario.dart';
import '../widgets/dialogo_agregar_usuario.dart';
import '../widgets/dialogo_editar_usuario.dart';

class PantallaUsuariosNueva extends StatefulWidget {
  @override
  _PantallaUsuariosNuevaState createState() => _PantallaUsuariosNuevaState();
}

class _PantallaUsuariosNuevaState extends State<PantallaUsuariosNueva> {
  // Estado
  String _filtroEstado = 'todos'; // todos, activos, inactivos
  String _filtroRol = 'todos'; // todos, usuario, administrador
  String _busqueda = '';
  bool _cargando = true;
  List<Usuario> _usuarios = [];
  Map<String, int> _estadisticas = {
    'total': 0,
    'activos': 0,
    'registrados_hoy': 0,
  };

  // Ordenamiento
  String _sortColumn = 'createdAt';
  bool _sortAscending = false; // Más recientes primero

  // Paginación
  int _rowsPerPage = 10;
  int _currentPage = 0;

  // Controladores de scroll
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  // Cache
  final CacheService _cache = CacheService();

  @override
  void initState() {
    super.initState();
    // Pequeño delay para evitar colisiones al cambiar de pantalla
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        _cargarDatos();
      }
    });
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos({bool forceRefresh = false, int reintentos = 3}) async {
    if (!mounted) return;

    setState(() => _cargando = true);

    // Intentar cargar con reintentos automáticos
    for (int intento = 0; intento < reintentos; intento++) {
      try {
        // Intentar cargar desde caché primero
        List<Usuario> usuarios;
        Map<String, int> stats;

        if (!forceRefresh) {
          final cached = _cache.get<List<Usuario>>('usuarios:todos');
          final cachedStats = _cache.get<Map<String, int>>('usuarios:estadisticas');
          
          if (cached != null && cachedStats != null) {
            usuarios = cached;
            stats = cachedStats;
            print('✅ Usuarios cargados desde caché (${usuarios.length} usuarios)');
            
            if (mounted) {
              setState(() {
                _usuarios = usuarios;
                _estadisticas = stats;
                _cargando = false;
              });
            }
            return;
          }
        }

        // Cargar desde base de datos con timeout
        usuarios = await UsuarioService.obtenerUsuarios()
            .timeout(
              Duration(seconds: 10),
              onTimeout: () {
                print('⏱️ Timeout en obtención de usuarios (intento ${intento + 1}/$reintentos)');
                throw TimeoutException('Timeout al obtener usuarios');
              },
            );

        stats = await UsuarioService.obtenerEstadisticasUsuarios()
            .timeout(
              Duration(seconds: 5),
              onTimeout: () {
                print('⏱️ Timeout en estadísticas de usuarios');
                return _calcularEstadisticasLocales(usuarios);
              },
            );

        // Guardar en caché
        _cache.set('usuarios:todos', usuarios, category: 'usuarios');
        _cache.set('usuarios:estadisticas', stats, category: 'usuarios');

        // Éxito - actualizar estado
        if (mounted) {
          setState(() {
            _usuarios = usuarios;
            _estadisticas = stats;
            _cargando = false;
          });
        }

        print('✅ Usuarios cargados exitosamente (${usuarios.length} usuarios)');
        return;

      } catch (e) {
        print('❌ Error en intento ${intento + 1}/$reintentos: $e');

        if (intento < reintentos - 1) {
          final espera = Duration(milliseconds: 500 * (intento + 1));
          print('⏳ Reintentando en ${espera.inMilliseconds}ms...');
          await Future.delayed(espera);
          continue;
        }

        // Último intento falló
        print('⚠️ Todos los reintentos fallaron. Cargando datos vacíos.');
        if (mounted) {
          setState(() {
            if (_usuarios.isEmpty) {
              _usuarios = [];
              _estadisticas = {'total': 0, 'activos': 0, 'registrados_hoy': 0};
            }
            _cargando = false;
          });

          if (_usuarios.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.cloud_off, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('No se pudieron cargar los usuarios'),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange.shade700,
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Reintentar',
                  textColor: Colors.white,
                  onPressed: () => _cargarDatos(forceRefresh: true),
                ),
              ),
            );
          }
        }
      }
    }
  }

  Map<String, int> _calcularEstadisticasLocales(List<Usuario> usuarios) {
    final activos = usuarios.where((u) => u.estaActivo).length;
    final hoy = DateTime.now();
    final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final registradosHoy = usuarios.where((u) => u.createdAt.isAfter(inicioHoy)).length;

    return {
      'total': usuarios.length,
      'activos': activos,
      'registrados_hoy': registradosHoy,
    };
  }

  List<Usuario> get _usuariosFiltrados {
    return _usuarios.where((usuario) {
      // Filtro por estado
      if (_filtroEstado == 'activos' && !usuario.estaActivo) return false;
      if (_filtroEstado == 'inactivos' && usuario.estaActivo) return false;

      // Filtro por rol
      if (_filtroRol != 'todos' && usuario.rol != _filtroRol) return false;

      // Filtrar por búsqueda (nombre o email)
      if (_busqueda.isNotEmpty) {
        final busquedaLower = _busqueda.toLowerCase();
        final nombreMatch = usuario.nombre.toLowerCase().contains(busquedaLower);
        final emailMatch = usuario.email.toLowerCase().contains(busquedaLower);
        if (!nombreMatch && !emailMatch) return false;
      }

      return true;
    }).toList();
  }

  List<Usuario> get _usuariosOrdenados {
    final usuarios = List<Usuario>.from(_usuariosFiltrados);
    
    usuarios.sort((a, b) {
      int compare = 0;
      
      switch (_sortColumn) {
        case 'nombre':
          compare = a.nombre.compareTo(b.nombre);
          break;
        case 'email':
          compare = a.email.compareTo(b.email);
          break;
        case 'rol':
          compare = a.rol.compareTo(b.rol);
          break;
        case 'estaActivo':
          compare = a.estaActivo == b.estaActivo ? 0 : (a.estaActivo ? -1 : 1);
          break;
        case 'createdAt':
          compare = a.createdAt.compareTo(b.createdAt);
          break;
      }
      
      return _sortAscending ? compare : -compare;
    });
    
    return usuarios;
  }

  List<Usuario> get _usuariosPaginados {
    final start = _currentPage * _rowsPerPage;
    final end = (start + _rowsPerPage).clamp(0, _usuariosOrdenados.length);
    
    if (start >= _usuariosOrdenados.length) return [];
    return _usuariosOrdenados.sublist(start, end);
  }

  int get _totalPages {
    return (_usuariosOrdenados.length / _rowsPerPage).ceil();
  }

  void _ordenar(String columna) {
    setState(() {
      if (_sortColumn == columna) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = columna;
        _sortAscending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          _buildEstadisticas(),
          _buildFiltrosYBusqueda(),
          Expanded(
            child: _cargando
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Cargando usuarios...',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : _usuariosPaginados.isEmpty
                    ? _buildEstadoVacio()
                    : _buildTabla(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogoAgregar(),
        icon: Icon(Icons.person_add),
        label: Text('Nuevo Usuario'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blue.shade700],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.people, color: Colors.white, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestión de Usuarios',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Administra usuarios, roles y permisos del sistema',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey[700]),
            onPressed: _cargando ? null : () => _cargarDatos(forceRefresh: true),
            tooltip: 'Recargar',
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticas() {
    return Container(
      margin: EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Usuarios',
              _estadisticas['total'].toString(),
              Icons.people_outline,
              Colors.blue,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Activos',
              _estadisticas['activos'].toString(),
              Icons.check_circle_outline,
              Colors.green,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Inactivos',
              (_estadisticas['total']! - _estadisticas['activos']!).toString(),
              Icons.block,
              Colors.red,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Registrados Hoy',
              _estadisticas['registrados_hoy'].toString(),
              Icons.today,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltrosYBusqueda() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Búsqueda
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o email...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (valor) {
                setState(() {
                  _busqueda = valor;
                  _currentPage = 0;
                });
              },
            ),
          ),
          SizedBox(width: 16),
          // Filtro Estado
          DropdownButton<String>(
            value: _filtroEstado,
            items: [
              DropdownMenuItem(value: 'todos', child: Text('Todos los estados')),
              DropdownMenuItem(value: 'activos', child: Text('✓ Activos')),
              DropdownMenuItem(value: 'inactivos', child: Text('✕ Inactivos')),
            ],
            onChanged: (valor) {
              setState(() {
                _filtroEstado = valor!;
                _currentPage = 0;
              });
            },
          ),
          SizedBox(width: 16),
          // Filtro Rol
          DropdownButton<String>(
            value: _filtroRol,
            items: [
              DropdownMenuItem(value: 'todos', child: Text('Todos los roles')),
              DropdownMenuItem(value: 'usuario', child: Text('👤 Usuario')),
              DropdownMenuItem(value: 'administrador', child: Text('⭐ Administrador')),
            ],
            onChanged: (valor) {
              setState(() {
                _filtroRol = valor!;
                _currentPage = 0;
              });
            },
          ),
          SizedBox(width: 16),
          // Resultados
          Text(
            '${_usuariosOrdenados.length} resultados',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _busqueda.isNotEmpty || _filtroEstado != 'todos' || _filtroRol != 'todos'
                ? Icons.search_off
                : Icons.people_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            _busqueda.isNotEmpty || _filtroEstado != 'todos' || _filtroRol != 'todos'
                ? 'No se encontraron usuarios'
                : 'No hay usuarios registrados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _busqueda.isNotEmpty || _filtroEstado != 'todos' || _filtroRol != 'todos'
                ? 'Intenta cambiar los filtros'
                : 'Agrega tu primer usuario para comenzar',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTabla() {
    return Column(
      children: [
        // Tabla con scroll
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Scrollbar(
                controller: _verticalScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _verticalScrollController,
                  scrollDirection: Axis.vertical,
                  child: Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 100,
                        child: DataTable(
                          headingRowHeight: 56,
                          dataRowHeight: 72,
                          horizontalMargin: 20,
                          columnSpacing: 24,
                          headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                          columns: [
                            _buildDataColumn('Usuario', 'nombre', flex: 2),
                            _buildDataColumn('Email', 'email', flex: 2),
                            _buildDataColumn('Rol', 'rol'),
                            _buildDataColumn('Estado', 'estaActivo'),
                            _buildDataColumn('Registro', 'createdAt'),
                            DataColumn(
                              label: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'ACCIONES',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          rows: _usuariosPaginados.asMap().entries.map((entry) {
                            final index = entry.key;
                            final usuario = entry.value;

                            return DataRow(
                              color: MaterialStateProperty.resolveWith<Color?>(
                                (states) {
                                  if (states.contains(MaterialState.hovered)) {
                                    return Colors.blue.withOpacity(0.05);
                                  }
                                  return index.isEven ? Colors.white : Colors.grey.shade50;
                                },
                              ),
                              cells: [
                                _buildUsuarioCell(usuario),
                                _buildEmailCell(usuario),
                                _buildRolCell(usuario),
                                _buildEstadoCell(usuario),
                                _buildFechaCell(usuario),
                                _buildAccionesCell(usuario),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Paginación
        if (_totalPages > 1) _buildPaginacion(),
      ],
    );
  }

  DataColumn _buildDataColumn(String label, String sortKey, {int flex = 1}) {
    return DataColumn(
      label: Expanded(
        flex: flex,
        child: InkWell(
          onTap: () => _ordenar(sortKey),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                  color: Colors.grey[700],
                ),
              ),
              if (_sortColumn == sortKey) ...[
                SizedBox(width: 4),
                Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: Colors.blue,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  DataCell _buildUsuarioCell(Usuario usuario) {
    return DataCell(
      Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              usuario.nombre.isNotEmpty
                  ? usuario.nombre[0].toUpperCase()
                  : usuario.email[0].toUpperCase(),
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  usuario.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  'ID: ${usuario.id.substring(0, 8)}...',
                  style: TextStyle(
                    fontSize: 11,
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

  DataCell _buildEmailCell(Usuario usuario) {
    return DataCell(
      Row(
        children: [
          Icon(Icons.email_outlined, size: 16, color: Colors.grey[400]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              usuario.email,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  DataCell _buildRolCell(Usuario usuario) {
    // Determinar color y label según rol_id
    Color color1, color2;
    IconData icono;
    String label;
    
    switch (usuario.rolId) {
      case 1: // usuario
        color1 = Colors.blue.shade400;
        color2 = Colors.blue.shade600;
        icono = Icons.person;
        label = 'Usuario';
        break;
      case 2: // moderador
        color1 = Colors.orange.shade400;
        color2 = Colors.orange.shade600;
        icono = Icons.shield;
        label = 'Moderador';
        break;
      case 3: // administrador
        color1 = Colors.purple.shade400;
        color2 = Colors.purple.shade600;
        icono = Icons.admin_panel_settings;
        label = 'Admin';
        break;
      case 4: // super_admin
        color1 = Colors.red.shade400;
        color2 = Colors.red.shade600;
        icono = Icons.stars;
        label = 'Super Admin';
        break;
      default:
        color1 = Colors.grey.shade400;
        color2 = Colors.grey.shade600;
        icono = Icons.help;
        label = 'Desconocido';
    }
    
    return DataCell(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 14, color: Colors.white),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataCell _buildEstadoCell(Usuario usuario) {
    return DataCell(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: usuario.estaActivo
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: usuario.estaActivo ? Colors.green : Colors.red,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              usuario.estaActivo ? Icons.check_circle : Icons.cancel,
              size: 14,
              color: usuario.estaActivo ? Colors.green : Colors.red,
            ),
            SizedBox(width: 6),
            Text(
              usuario.estaActivo ? 'Activo' : 'Inactivo',
              style: TextStyle(
                color: usuario.estaActivo ? Colors.green.shade700 : Colors.red.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataCell _buildFechaCell(Usuario usuario) {
    final fecha = DateFormat('dd/MM/yyyy HH:mm').format(usuario.createdAt);
    final hace = _tiempoTranscurrido(usuario.createdAt);
    
    return DataCell(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            fecha,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2),
          Text(
            hace,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  DataCell _buildAccionesCell(Usuario usuario) {
    return DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Editar
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 18),
            color: Colors.blue,
            tooltip: 'Editar',
            onPressed: () => _mostrarDialogoEditar(usuario),
          ),
          // Cambiar estado
          IconButton(
            icon: Icon(
              usuario.estaActivo ? Icons.block : Icons.check_circle,
              size: 18,
            ),
            color: usuario.estaActivo ? Colors.orange : Colors.green,
            tooltip: usuario.estaActivo ? 'Desactivar' : 'Activar',
            onPressed: () => _cambiarEstadoUsuario(usuario),
          ),
          // Eliminar
          IconButton(
            icon: Icon(Icons.delete_outline, size: 18),
            color: Colors.red,
            tooltip: 'Eliminar',
            onPressed: () => _confirmarEliminar(usuario),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginacion() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Filas por página:',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(width: 12),
          DropdownButton<int>(
            value: _rowsPerPage,
            items: [5, 10, 20, 50].map((rows) {
              return DropdownMenuItem(
                value: rows,
                child: Text('$rows'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _rowsPerPage = value!;
                _currentPage = 0;
              });
            },
          ),
          Spacer(),
          Text(
            'Página ${_currentPage + 1} de $_totalPages',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(width: 24),
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: _currentPage < _totalPages - 1
                ? () => setState(() => _currentPage++)
                : null,
          ),
        ],
      ),
    );
  }

  String _tiempoTranscurrido(DateTime fecha) {
    final diferencia = DateTime.now().difference(fecha);
    
    if (diferencia.inDays > 365) {
      final anios = (diferencia.inDays / 365).floor();
      return 'Hace $anios ${anios == 1 ? 'anio' : 'anios'}';
    } else if (diferencia.inDays > 30) {
      final meses = (diferencia.inDays / 30).floor();
      return 'Hace ${meses} ${meses == 1 ? 'mes' : 'meses'}';
    } else if (diferencia.inDays > 0) {
      return 'Hace ${diferencia.inDays} ${diferencia.inDays == 1 ? 'día' : 'días'}';
    } else if (diferencia.inHours > 0) {
      return 'Hace ${diferencia.inHours} ${diferencia.inHours == 1 ? 'hora' : 'horas'}';
    } else if (diferencia.inMinutes > 0) {
      return 'Hace ${diferencia.inMinutes} ${diferencia.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'Hace un momento';
    }
  }

  // Acciones
  Future<void> _mostrarDialogoAgregar() async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => DialogoAgregarUsuario(),
    );

    if (resultado == true) {
      _cargarDatos(forceRefresh: true);
    }
  }

  Future<void> _mostrarDialogoEditar(Usuario usuario) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => DialogoEditarUsuario(usuario: usuario),
    );

    if (resultado == true) {
      _cargarDatos(forceRefresh: true);
    }
  }

  Future<void> _cambiarEstadoUsuario(Usuario usuario) async {
    try {
      if (usuario.estaActivo) {
        await UsuarioService.deshabilitarUsuario(usuario.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuario desactivado correctamente'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        await UsuarioService.habilitarUsuario(usuario.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuario activado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      _cache.invalidateCategory('usuarios');
      _cargarDatos(forceRefresh: true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar estado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmarEliminar(Usuario usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Usuario'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${usuario.nombre}?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await UsuarioService.eliminarUsuario(usuario.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuario eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        _cache.invalidateCategory('usuarios');
        _cargarDatos(forceRefresh: true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar usuario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}