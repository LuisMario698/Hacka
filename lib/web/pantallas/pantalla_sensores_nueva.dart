import 'package:flutter/material.dart';

class PantallaSensoresNueva extends StatefulWidget {
  @override
  _PantallaSensoresNuevaState createState() => _PantallaSensoresNuevaState();
}

class _PantallaSensoresNuevaState extends State<PantallaSensoresNueva> {
  String _filtroEstado = 'todos'; // todos, online, offline, alerta
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
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
                  SizedBox(height: 4),
                  Text(
                    'Monitoreo y control de red de sensores',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _mostrarDialogoAgregarSensor(),
                icon: Icon(Icons.add),
                label: Text('Agregar Sensor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Resumen de sensores
          _buildResumenSensores(),
          SizedBox(height: 24),

          // Filtros y búsqueda
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o clave...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    setState(() => _busqueda = value);
                  },
                ),
              ),
              SizedBox(width: 16),
              _buildFiltroChip('Todos', 'todos'),
              SizedBox(width: 8),
              _buildFiltroChip('Online', 'online', Colors.green),
              SizedBox(width: 8),
              _buildFiltroChip('Offline', 'offline', Colors.grey),
              SizedBox(width: 8),
              _buildFiltroChip('Alerta', 'alerta', Colors.red),
              SizedBox(width: 16),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.file_download),
                tooltip: 'Exportar a CSV',
              ),
            ],
          ),
          SizedBox(height: 24),

          // Tabla de sensores
          _buildTablaSensores(),
        ],
      ),
    );
  }

  Widget _buildResumenSensores() {
    return Row(
      children: [
        Expanded(
          child: _buildResumenCard(
            'Total Sensores',
            '180',
            Icons.sensors,
            Colors.blue,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildResumenCard(
            'Online',
            '156',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildResumenCard(
            'Offline',
            '24',
            Icons.cancel,
            Colors.grey,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildResumenCard(
            'Con Alerta',
            '12',
            Icons.warning,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildResumenCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltroChip(String label, String valor, [Color? color]) {
    final isSelected = _filtroEstado == valor;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filtroEstado = valor);
      },
      backgroundColor: Colors.grey[100],
      selectedColor: (color ?? Color(0xFF667eea)).withOpacity(0.2),
      checkmarkColor: color ?? Color(0xFF667eea),
    );
  }

  Widget _buildTablaSensores() {
    final sensoresEjemplo = [
      {
        'id': 'SENSOR_001',
        'nombre': 'Av. Principal Norte',
        'lat': '31.3167',
        'lon': '-113.5361',
        'estado': 'online',
        'luz': '450 lux',
        'ruido': '45 dB',
        'ultima_lectura': '2 min',
        'bateria': '95%',
      },
      {
        'id': 'SENSOR_002',
        'nombre': 'Calle Universidad',
        'lat': '31.3180',
        'lon': '-113.5350',
        'estado': 'online',
        'luz': '380 lux',
        'ruido': '38 dB',
        'ultima_lectura': '1 min',
        'bateria': '87%',
      },
      {
        'id': 'SENSOR_045',
        'nombre': 'Zona Industrial',
        'lat': '31.3150',
        'lon': '-113.5400',
        'estado': 'offline',
        'luz': '-- lux',
        'ruido': '-- dB',
        'ultima_lectura': '2 horas',
        'bateria': 'N/A',
      },
      {
        'id': 'SENSOR_078',
        'nombre': 'Parque Central',
        'lat': '31.3200',
        'lon': '-113.5380',
        'estado': 'alerta',
        'luz': '50 lux',
        'ruido': '85 dB',
        'ultima_lectura': '30 seg',
        'bateria': '42%',
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header de tabla
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Sensor', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Ubicación', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Luz', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Ruido', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Última Lectura', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Batería', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          // Filas de datos
          ...sensoresEjemplo.map((sensor) => _buildFilaSensor(sensor)).toList(),
        ],
      ),
    );
  }

  Widget _buildFilaSensor(Map<String, String> sensor) {
    Color estadoColor;
    IconData estadoIcon;
    
    switch (sensor['estado']) {
      case 'online':
        estadoColor = Colors.green;
        estadoIcon = Icons.check_circle;
        break;
      case 'offline':
        estadoColor = Colors.grey;
        estadoIcon = Icons.cancel;
        break;
      case 'alerta':
        estadoColor = Colors.red;
        estadoIcon = Icons.warning;
        break;
      default:
        estadoColor = Colors.grey;
        estadoIcon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sensor['nombre']!,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  sensor['id']!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${sensor['lat']}, ${sensor['lon']}',
              style: TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(estadoIcon, color: estadoColor, size: 16),
                SizedBox(width: 4),
                Text(
                  sensor['estado']!.toUpperCase(),
                  style: TextStyle(
                    color: estadoColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Text(sensor['luz']!, style: TextStyle(fontSize: 13))),
          Expanded(child: Text(sensor['ruido']!, style: TextStyle(fontSize: 13))),
          Expanded(child: Text(sensor['ultima_lectura']!, style: TextStyle(fontSize: 13))),
          Expanded(child: Text(sensor['bateria']!, style: TextStyle(fontSize: 13))),
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.timeline, size: 20),
                  onPressed: () => _mostrarHistorial(sensor),
                  tooltip: 'Ver historial',
                ),
                IconButton(
                  icon: Icon(Icons.edit, size: 20),
                  onPressed: () => _editarSensor(sensor),
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () => _eliminarSensor(sensor),
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAgregarSensor() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Agregar Nuevo Sensor'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nombre del sensor',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Clave del dispositivo',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Latitud',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Longitud',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
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
            onPressed: () {
              // TODO: Agregar sensor
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF667eea),
            ),
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _mostrarHistorial(Map<String, String> sensor) {
    // TODO: Mostrar historial de lecturas
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mostrando historial de ${sensor['nombre']}')),
    );
  }

  void _editarSensor(Map<String, String> sensor) {
    // TODO: Editar sensor
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editando ${sensor['nombre']}')),
    );
  }

  void _eliminarSensor(Map<String, String> sensor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar Sensor'),
        content: Text('¿Estás seguro de eliminar ${sensor['nombre']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Eliminar sensor
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
