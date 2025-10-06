import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../servicios/nodo_service.dart';
import '../../modelos/nodo_model.dart';
import '../../modelos/lectura_model.dart';

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

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    
    try {
      final nodos = await NodoService.obtenerTodosLosNodos();
      final stats = await NodoService.obtenerEstadisticas();
      
      setState(() {
        _nodos = nodos;
        _estadisticas = stats;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar sensores: $e')),
      );
    }
  }

  List<Nodo> get _nodosFiltrados {
    return _nodos.where((nodo) {
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
  }

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
                    onPressed: _cargarDatos,
                    tooltip: 'Actualizar',
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

          // Tabla de sensores
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Lista de Sensores (${_nodosFiltrados.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Divider(height: 1),
                _nodosFiltrados.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No hay sensores que mostrar',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Sensor')),
                            DataColumn(label: Text('Ubicación')),
                            DataColumn(label: Text('Estado')),
                            DataColumn(label: Text('Luz (lux)')),
                            DataColumn(label: Text('Ruido (dB)')),
                            DataColumn(label: Text('Última Lectura')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: _nodosFiltrados.map((nodo) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        nodo.nombre,
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        nodo.claveDelDispositivo,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(Text(
                                  '${nodo.latitud.toStringAsFixed(4)}, ${nodo.longitud.toStringAsFixed(4)}',
                                  style: TextStyle(fontSize: 12),
                                )),
                                DataCell(_buildEstadoBadge(nodo.obtenerEstado())),
                                DataCell(Text(
                                  nodo.ultimoLux != null 
                                      ? nodo.ultimoLux!.toStringAsFixed(1)
                                      : '--',
                                )),
                                DataCell(Text(
                                  nodo.ultimoRuido != null 
                                      ? nodo.ultimoRuido!.toStringAsFixed(1)
                                      : '--',
                                )),
                                DataCell(Text(
                                  nodo.fechaUltimaLectura != null
                                      ? DateFormat('dd/MM HH:mm').format(nodo.fechaUltimaLectura!)
                                      : 'Sin datos',
                                  style: TextStyle(fontSize: 12),
                                )),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.history, size: 20),
                                        onPressed: () => _mostrarHistorial(nodo),
                                        tooltip: 'Ver historial',
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit, size: 20),
                                        onPressed: () => _editarSensor(nodo),
                                        tooltip: 'Editar',
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, size: 20, color: Colors.red),
                                        onPressed: () => _eliminarSensor(nodo),
                                        tooltip: 'Eliminar',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
              ],
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

  Widget _buildEstadoBadge(String estado) {
    Color color;
    String text;
    
    switch (estado) {
      case 'online':
        color = Colors.green;
        text = 'En Línea';
        break;
      case 'offline':
        color = Colors.grey;
        text = 'Fuera de Línea';
        break;
      case 'alerta':
        color = Colors.orange;
        text = 'Alerta';
        break;
      case 'sin_datos':
        color = Colors.grey;
        text = 'Sin Datos';
        break;
      default:
        color = Colors.grey;
        text = 'Desconocido';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  void _mostrarDialogoAgregarSensor() {
    final nombreController = TextEditingController();
    final claveController = TextEditingController();
    final latitudController = TextEditingController();
    final longitudController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Agregar Nuevo Sensor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Sensor',
                  hintText: 'Ej: Sensor Parque Central',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: claveController,
                decoration: InputDecoration(
                  labelText: 'Clave del Dispositivo',
                  hintText: 'Ej: SENSOR_001',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: latitudController,
                decoration: InputDecoration(
                  labelText: 'Latitud',
                  hintText: 'Ej: 19.4326',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 12),
              TextField(
                controller: longitudController,
                decoration: InputDecoration(
                  labelText: 'Longitud',
                  hintText: 'Ej: -99.1332',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                await NodoService.crearNodo(
                  nombre: nombreController.text,
                  claveDelDispositivo: claveController.text,
                  latitud: double.parse(latitudController.text),
                  longitud: double.parse(longitudController.text),
                );
                
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sensor creado exitosamente')),
                );
                _cargarDatos();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: Text('Crear'),
          ),
        ],
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
