import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../servicios/nodo_service.dart';
import '../../modelos/nodo_model.dart';
import '../../modelos/lectura_model.dart';
import '../widgets/dialogo_agregar_sensor.dart';

class PantallaSensoresNueva extends StatefulWidget {
  @override
  _PantallaSensoresNuevaState createState() => _PantallaSensoresNuevaState();
}

class _PantallaSensoresNuevaState extends State<PantallaSensoresNueva> {
  String _filtroEstado = 'todos';
  String _busqueda = '';
  bool _cargando = true;
  List<Nodo> _nodos = [];
  Map<String, int> _estadisticas = {
    'total': 0,
    'online': 0,
    'offline': 0,
    'alerta': 0,
  };
  
  // Ordenamiento
  String _sortColumn = 'nombre';
  bool _sortAscending = true;
  
  // Paginación
  int _rowsPerPage = 10;
  int _currentPage = 0;

  // Controladores de scroll
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

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
        // Timeout para evitar esperas infinitas
        final nodos = await NodoService.obtenerTodosLosNodos(forceRefresh: forceRefresh)
            .timeout(
              Duration(seconds: 10),
              onTimeout: () {
                print('⏱️ Timeout en obtención de nodos (intento ${intento + 1}/$reintentos)');
                throw TimeoutException('Timeout al obtener sensores');
              },
            );
        
        final stats = await NodoService.obtenerEstadisticas(forceRefresh: forceRefresh)
            .timeout(
              Duration(seconds: 5),
              onTimeout: () {
                print('⏱️ Timeout en estadísticas (intento ${intento + 1}/$reintentos)');
                // Si falla stats, calculamos manualmente
                return _calcularEstadisticasLocales(nodos);
              },
            );
        
        // Éxito - actualizar estado
        if (mounted) {
          setState(() {
            _nodos = nodos;
            _estadisticas = stats;
            _cargando = false;
          });
        }
        
        print('✅ Sensores cargados exitosamente (${nodos.length} sensores)');
        return; // Salir del loop de reintentos
        
      } catch (e) {
        print('❌ Error en intento ${intento + 1}/$reintentos: $e');
        
        // Si no es el último intento, esperar antes de reintentar
        if (intento < reintentos - 1) {
          final espera = Duration(milliseconds: 500 * (intento + 1)); // Backoff exponencial
          print('⏳ Reintentando en ${espera.inMilliseconds}ms...');
          await Future.delayed(espera);
          continue;
        }
        
        // Último intento falló - cargar datos vacíos silenciosamente
        print('⚠️ Todos los reintentos fallaron. Cargando datos vacíos.');
        if (mounted) {
          setState(() {
            // Mantener datos previos si existen, o inicializar vacío
            if (_nodos.isEmpty) {
              _nodos = [];
              _estadisticas = {
                'total': 0,
                'online': 0,
                'offline': 0,
                'alerta': 0,
              };
            }
            _cargando = false;
          });
          
          // Mostrar mensaje discreto solo si no hay datos
          if (_nodos.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.cloud_off, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('No se pudieron cargar los sensores. Verifica tu conexión.'),
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
  
  // Método auxiliar para calcular estadísticas localmente si falla el servicio
  Map<String, int> _calcularEstadisticasLocales(List<Nodo> nodos) {
    int total = nodos.length;
    int online = 0;
    int offline = 0;
    int alerta = 0;
    
    for (var nodo in nodos) {
      final estado = nodo.obtenerEstado();
      if (estado == 'online') online++;
      if (estado == 'offline' || estado == 'sin_datos') offline++;
      if (estado == 'alerta') alerta++;
    }
    
    return {
      'total': total,
      'online': online,
      'offline': offline,
      'alerta': alerta,
    };
  }

  List<Nodo> get _nodosFiltrados {
    var filtrados = _nodos.where((nodo) {
      // Filtro por estado
      if (_filtroEstado != 'todos') {
        if (nodo.obtenerEstado() != _filtroEstado) return false;
      }
      
      // Filtro por búsqueda
      if (_busqueda.isNotEmpty) {
        final busquedaLower = _busqueda.toLowerCase();
        return nodo.nombre.toLowerCase().contains(busquedaLower) ||
            nodo.claveDelDispositivo.toLowerCase().contains(busquedaLower);
      }
      
      return true;
    }).toList();
    
    // Ordenamiento
    filtrados.sort((a, b) {
      int comparison = 0;
      switch (_sortColumn) {
        case 'nombre':
          comparison = a.nombre.compareTo(b.nombre);
          break;
        case 'estado':
          comparison = a.obtenerEstado().compareTo(b.obtenerEstado());
          break;
        case 'luz':
          final luxA = a.ultimoLux ?? -1;
          final luxB = b.ultimoLux ?? -1;
          comparison = luxA.compareTo(luxB);
          break;
        case 'ruido':
          final ruidoA = a.ultimoRuido ?? -1;
          final ruidoB = b.ultimoRuido ?? -1;
          comparison = ruidoA.compareTo(ruidoB);
          break;
        case 'fecha':
          final fechaA = a.fechaUltimaLectura ?? DateTime(1970);
          final fechaB = b.fechaUltimaLectura ?? DateTime(1970);
          comparison = fechaA.compareTo(fechaB);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
    
    return filtrados;
  }
  
  List<Nodo> get _nodosPaginados {
    final start = _currentPage * _rowsPerPage;
    final end = (start + _rowsPerPage).clamp(0, _nodosFiltrados.length);
    return _nodosFiltrados.sublist(start, end);
  }
  
  int get _totalPages => (_nodosFiltrados.length / _rowsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando sensores...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📡 Gestión de Sensores IoT',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Monitoreo en tiempo real de sensores ESP32',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () => _cargarDatos(forceRefresh: true),
                    tooltip: 'Actualizar desde servidor',
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _mostrarDialogoAgregarSensor,
                    icon: Icon(Icons.add),
                    label: Text('Agregar Sensor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),

          // Tarjetas de resumen
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total de Sensores',
                  _estadisticas['total'].toString(),
                  Icons.sensors,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'En Línea',
                  _estadisticas['online'].toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Fuera de Línea',
                  _estadisticas['offline'].toString(),
                  Icons.cancel,
                  Colors.grey,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Con Alertas',
                  _estadisticas['alerta'].toString(),
                  Icons.warning,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Filtros
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() => _busqueda = value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar por nombre o clave...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip('Todos', 'todos'),
                      _buildFilterChip('En Línea', 'online'),
                      _buildFilterChip('Fuera de Línea', 'offline'),
                      _buildFilterChip('Con Alertas', 'alerta'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Tabla de sensores mejorada
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header de la tabla
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.purple.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.table_chart, color: Colors.blue.shade700),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lista de Sensores',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              Text(
                                '${_nodosFiltrados.length} sensor${_nodosFiltrados.length != 1 ? 'es' : ''}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Selector de filas por página
                      Row(
                        children: [
                          Text('Mostrar:', style: TextStyle(fontSize: 13)),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _rowsPerPage,
                                items: [5, 10, 20, 50].map((value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text('$value', style: TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _rowsPerPage = value!;
                                    _currentPage = 0;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Tabla
                _nodosFiltrados.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.sensors_off, size: 64, color: Colors.grey[300]),
                              SizedBox(height: 16),
                              Text(
                                'No hay sensores que mostrar',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                _filtroEstado != 'todos' || _busqueda.isNotEmpty
                                    ? 'Intenta cambiar los filtros'
                                    : 'Agrega tu primer sensor para comenzar',
                                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          // Contenedor con scroll vertical y horizontal
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height - 450, // Altura máxima adaptativa
                            ),
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
                                  _buildDataColumn('Sensor', 'nombre', flex: 2),
                                  _buildDataColumn('Ubicación', 'ubicacion'),
                                  _buildDataColumn('Estado', 'estado'),
                                  _buildDataColumn('Luz (lux)', 'luz'),
                                  _buildDataColumn('Ruido (dB)', 'ruido'),
                                  _buildDataColumn('Última Lectura', 'fecha', flex: 2),
                                  DataColumn(label: Container(
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
                                  )),
                                ],
                                rows: _nodosPaginados.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final nodo = entry.value;
                                  
                                  return DataRow(
                                    color: MaterialStateProperty.resolveWith<Color?>(
                                      (states) {
                                        if (states.contains(MaterialState.hovered)) {
                                          return Colors.blue.shade50.withOpacity(0.5);
                                        }
                                        if (index.isEven) {
                                          return Colors.grey.shade50.withOpacity(0.3);
                                        }
                                        return null;
                                      },
                                    ),
                                    cells: [
                                      _buildSensorCell(nodo),
                                      _buildUbicacionCell(nodo),
                                      _buildEstadoCell(nodo),
                                      _buildLecturaCell(nodo.ultimoLux, 'lux', Icons.light_mode),
                                      _buildLecturaCell(nodo.ultimoRuido, 'dB', Icons.volume_up),
                                      _buildFechaCell(nodo),
                                      _buildAccionesCell(nodo),
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
                          
                          // Paginación
                          if (_totalPages > 1)
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Mostrando ${_currentPage * _rowsPerPage + 1}-${((_currentPage + 1) * _rowsPerPage).clamp(0, _nodosFiltrados.length)} de ${_nodosFiltrados.length}',
                                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.first_page),
                                        onPressed: _currentPage > 0
                                            ? () => setState(() => _currentPage = 0)
                                            : null,
                                        tooltip: 'Primera página',
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.chevron_left),
                                        onPressed: _currentPage > 0
                                            ? () => setState(() => _currentPage--)
                                            : null,
                                        tooltip: 'Página anterior',
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Página ${_currentPage + 1} de $_totalPages',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.chevron_right),
                                        onPressed: _currentPage < _totalPages - 1
                                            ? () => setState(() => _currentPage++)
                                            : null,
                                        tooltip: 'Página siguiente',
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.last_page),
                                        onPressed: _currentPage < _totalPages - 1
                                            ? () => setState(() => _currentPage = _totalPages - 1)
                                            : null,
                                        tooltip: 'Última página',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Métodos helper para construcción de celdas mejoradas
  
  DataColumn _buildDataColumn(String label, String sortKey, {int flex = 1}) {
    final isActive = _sortColumn == sortKey;
    return DataColumn(
      label: InkWell(
        onTap: () {
          setState(() {
            if (_sortColumn == sortKey) {
              _sortAscending = !_sortAscending;
            } else {
              _sortColumn = sortKey;
              _sortAscending = true;
            }
          });
        },
        child: Row(
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
                color: isActive ? Colors.blue.shade700 : Colors.grey[700],
              ),
            ),
            if (isActive) ...[
              SizedBox(width: 4),
              Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: Colors.blue.shade700,
              ),
            ],
          ],
        ),
      ),
    );
  }

  DataCell _buildSensorCell(Nodo nodo) {
    return DataCell(
      Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              nodo.nombre,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                nodo.claveDelDispositivo,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataCell _buildUbicacionCell(Nodo nodo) {
    return DataCell(
      Tooltip(
        message: 'Lat: ${nodo.latitud}, Lng: ${nodo.longitud}',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.red.shade400),
            SizedBox(width: 4),
            Text(
              '${nodo.latitud.toStringAsFixed(4)}, ${nodo.longitud.toStringAsFixed(4)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  DataCell _buildEstadoCell(Nodo nodo) {
    final estado = nodo.obtenerEstado();
    List<Color> gradientColors;
    IconData icon;
    String text;
    
    switch (estado) {
      case 'online':
        gradientColors = [Colors.green.shade400, Colors.green.shade600];
        icon = Icons.check_circle;
        text = 'En Línea';
        break;
      case 'offline':
        gradientColors = [Colors.grey.shade400, Colors.grey.shade600];
        icon = Icons.cloud_off;
        text = 'Fuera de Línea';
        break;
      case 'alerta':
        gradientColors = [Colors.orange.shade400, Colors.orange.shade600];
        icon = Icons.warning;
        text = 'Alerta';
        break;
      case 'sin_datos':
        gradientColors = [Colors.grey.shade300, Colors.grey.shade500];
        icon = Icons.help_outline;
        text = 'Sin Datos';
        break;
      default:
        gradientColors = [Colors.grey.shade300, Colors.grey.shade500];
        icon = Icons.help_outline;
        text = 'Desconocido';
    }
    
    return DataCell(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataCell _buildLecturaCell(double? valor, String unidad, IconData icon) {
    if (valor == null) {
      return DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.remove, size: 16, color: Colors.grey[400]),
            SizedBox(width: 4),
            Text('--', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ],
        ),
      );
    }
    
    // Determinar color según el valor
    MaterialColor colorBase;
    if (unidad == 'lux') {
      colorBase = valor < 50 ? Colors.orange : Colors.green;
    } else if (unidad == 'dB') {
      colorBase = valor > 80 ? Colors.red : Colors.green;
    } else {
      colorBase = Colors.blue;
    }
    
    return DataCell(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colorBase.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorBase.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colorBase),
            SizedBox(width: 6),
            Text(
              '${valor.toStringAsFixed(1)} $unidad',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: colorBase.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataCell _buildFechaCell(Nodo nodo) {
    if (nodo.fechaUltimaLectura == null) {
      return DataCell(
        Text(
          'Sin datos',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    
    final formatter = DateFormat('dd/MM/yyyy\nHH:mm:ss');
    final fechaStr = formatter.format(nodo.fechaUltimaLectura!);
    final diferencia = DateTime.now().difference(nodo.fechaUltimaLectura!);
    
    String tiempoTranscurrido;
    if (diferencia.inMinutes < 60) {
      tiempoTranscurrido = 'Hace ${diferencia.inMinutes} min';
    } else if (diferencia.inHours < 24) {
      tiempoTranscurrido = 'Hace ${diferencia.inHours}h';
    } else {
      tiempoTranscurrido = 'Hace ${diferencia.inDays}d';
    }
    
    return DataCell(
      Tooltip(
        message: tiempoTranscurrido,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              fechaStr.split('\n')[0],
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              fechaStr.split('\n')[1],
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  DataCell _buildAccionesCell(Nodo nodo) {
    return DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'Ver historial',
            child: InkWell(
              onTap: () => _mostrarHistorial(nodo),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.history, size: 18, color: Colors.blue.shade700),
              ),
            ),
          ),
          SizedBox(width: 6),
          Tooltip(
            message: 'Editar',
            child: InkWell(
              onTap: () => _editarSensor(nodo),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.edit, size: 18, color: Colors.green.shade700),
              ),
            ),
          ),
          SizedBox(width: 6),
          Tooltip(
            message: 'Eliminar',
            child: InkWell(
              onTap: () => _eliminarSensor(nodo),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.delete, size: 18, color: Colors.red.shade700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filtroEstado == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filtroEstado = value;
        });
      },
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
    );
  }

  void _mostrarDialogoAgregarSensor() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DialogoAgregarSensor(
        onCrear: () {
          _cargarDatos();
        },
      ),
    );
  }

  void _editarSensor(Nodo nodo) {
    final nombreController = TextEditingController(text: nodo.nombre);
    final claveController = TextEditingController(text: nodo.claveDelDispositivo);
    final latitudController = TextEditingController(text: nodo.latitud.toString());
    final longitudController = TextEditingController(text: nodo.longitud.toString());
    bool activo = nodo.activo;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Editar Sensor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Sensor',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: claveController,
                  decoration: InputDecoration(
                    labelText: 'Clave del Dispositivo',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: latitudController,
                  decoration: InputDecoration(
                    labelText: 'Latitud',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: longitudController,
                  decoration: InputDecoration(
                    labelText: 'Longitud',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 12),
                SwitchListTile(
                  title: Text('Sensor Activo'),
                  value: activo,
                  onChanged: (value) {
                    setDialogState(() {
                      activo = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await NodoService.actualizarNodo(
                    id: nodo.id,
                    nombre: nombreController.text,
                    claveDelDispositivo: claveController.text,
                    latitud: double.parse(latitudController.text),
                    longitud: double.parse(longitudController.text),
                    activo: activo,
                  );
                  
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sensor actualizado exitosamente')),
                  );
                  _cargarDatos();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _eliminarSensor(Nodo nodo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar Sensor'),
        content: Text(
          '¿Estás seguro que deseas eliminar el sensor "${nodo.nombre}"?\n\n'
          'Esta acción también eliminará todas sus lecturas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await NodoService.eliminarNodo(nodo.id);
                
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sensor eliminado exitosamente')),
                );
                _cargarDatos();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarHistorial(Nodo nodo) async {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Container(
          width: 800,
          height: 600,
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.history, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historial de Lecturas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          nodo.nombre,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Divider(),
              Expanded(
                child: FutureBuilder<List<Lectura>>(
                  future: NodoService.obtenerLecturasDeNodo(nodoId: nodo.id, limite: 50),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    
                    final lecturas = snapshot.data ?? [];
                    
                    if (lecturas.isEmpty) {
                      return Center(
                        child: Text('No hay lecturas registradas'),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: lecturas.length,
                      itemBuilder: (context, index) {
                        final lectura = lecturas[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: lectura.tieneAlerta() 
                                  ? Colors.orange 
                                  : Colors.green,
                              child: Icon(
                                lectura.tieneAlerta() 
                                    ? Icons.warning 
                                    : Icons.check,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              DateFormat('dd/MM/yyyy HH:mm:ss').format(lectura.fecha),
                            ),
                            subtitle: Text(
                              'Luz: ${lectura.lux.toStringAsFixed(1)} lux (${lectura.evaluarLuz()}) • '
                              'Ruido: ${lectura.ruido.toStringAsFixed(1)} dB (${lectura.evaluarRuido()})',
                            ),
                            trailing: lectura.tieneAlerta()
                                ? Chip(
                                    label: Text(
                                      lectura.obtenerTipoAlerta() ?? 'Alerta',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    backgroundColor: Colors.orange.withOpacity(0.2),
                                  )
                                : null,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
