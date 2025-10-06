import 'package:flutter/material.dart';
import 'dart:ui';

/// Pantalla de historial de rutas con diseño elegante y consistente.
class PantallaHistorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text('Historial de rutas', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estadísticas generales
            _EstadisticasCard(),
            const SizedBox(height: 24),
            
            // Título de historial
            Text(
              'Rutas recientes',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground, 
                fontWeight: FontWeight.bold, 
                fontSize: 20
              ),
            ),
            const SizedBox(height: 16),
            
            // Lista de rutas
            Expanded(
              child: ListView(
                children: [
                  _RutaHistorialCard(
                    fecha: 'Hoy, 14:30',
                    origen: 'Metro Insurgentes',
                    destino: 'Colonia Roma Norte',
                    duracion: '18 min',
                    distancia: '2.1 km',
                    tipoRuta: 'Ruta Guardián',
                    seguridad: 95,
                    completada: true,
                  ),
                  _RutaHistorialCard(
                    fecha: 'Ayer, 09:15',
                    origen: 'Casa',
                    destino: 'Oficina Centro',
                    duracion: '25 min',
                    distancia: '3.2 km',
                    tipoRuta: 'Ruta Equilibrada',
                    seguridad: 88,
                    completada: true,
                  ),
                  _RutaHistorialCard(
                    fecha: 'Ayer, 18:45',
                    origen: 'Oficina Centro',
                    destino: 'Casa',
                    duracion: '22 min',
                    distancia: '3.0 km',
                    tipoRuta: 'Ruta Rápida',
                    seguridad: 75,
                    completada: false,
                    motivo: 'Cancelada por usuario',
                  ),
                  _RutaHistorialCard(
                    fecha: '2 días, 16:20',
                    origen: 'Plaza Universidad',
                    destino: 'Coyoacán Centro',
                    duracion: '30 min',
                    distancia: '4.1 km',
                    tipoRuta: 'Ruta Guardián',
                    seguridad: 92,
                    completada: true,
                  ),
                  _RutaHistorialCard(
                    fecha: '3 días, 20:10',
                    origen: 'Restaurante Polanco',
                    destino: 'Casa',
                    duracion: '35 min',
                    distancia: '5.2 km',
                    tipoRuta: 'Ruta Guardián',
                    seguridad: 89,
                    completada: true,
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

class _EstadisticasCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Theme.of(context).colorScheme.secondary, size: 24),
              SizedBox(width: 12),
              Text(
                'Estadísticas del mes',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _EstadisticaItem(
                  icono: Icons.route,
                  valor: '24',
                  etiqueta: 'Rutas',
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.lightBlue.shade300
                    : Theme.of(context).colorScheme.primary,
                ),
              ),
              Expanded(
                child: _EstadisticaItem(
                  icono: Icons.timer,
                  valor: '8.2h',
                  etiqueta: 'Tiempo',
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.green.shade300
                    : Theme.of(context).colorScheme.secondary,
                ),
              ),
              Expanded(
                child: _EstadisticaItem(
                  icono: Icons.straighten,
                  valor: '67km',
                  etiqueta: 'Distancia',
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.orange.shade300
                    : Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EstadisticaItem extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String etiqueta;
  final Color color;

  const _EstadisticaItem({
    required this.icono,
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icono, color: color, size: 32),
        SizedBox(height: 8),
        Text(
          valor,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          etiqueta,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _RutaHistorialCard extends StatelessWidget {
  final String fecha;
  final String origen;
  final String destino;
  final String duracion;
  final String distancia;
  final String tipoRuta;
  final int seguridad;
  final bool completada;
  final String? motivo;

  const _RutaHistorialCard({
    required this.fecha,
    required this.origen,
    required this.destino,
    required this.duracion,
    required this.distancia,
    required this.tipoRuta,
    required this.seguridad,
    required this.completada,
    this.motivo,
  });

  Color _getColorTipoRuta(BuildContext context) {
    switch (tipoRuta) {
      case 'Ruta Guardián':
        return Color(0xFFFFD600);
      case 'Ruta Equilibrada':
        return Color(0xFF00CFFF);
      case 'Ruta Rápida':
        return Color(0xFF1DE9B6);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getIconoTipoRuta() {
    switch (tipoRuta) {
      case 'Ruta Guardián':
        return Icons.shield;
      case 'Ruta Equilibrada':
        return Icons.balance;
      case 'Ruta Rápida':
        return Icons.speed;
      default:
        return Icons.route;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorRuta = _getColorTipoRuta(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completada 
            ? colorRuta.withOpacity(0.3)
            : Theme.of(context).colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fecha y estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fecha,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: completada 
                    ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
                    : Theme.of(context).colorScheme.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  completada ? 'Completada' : 'Cancelada',
                  style: TextStyle(
                    color: completada 
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Origen y destino
          Row(
            children: [
              Icon(Icons.my_location, color: Theme.of(context).colorScheme.primary, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  origen,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.flag, color: Theme.of(context).colorScheme.error, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  destino,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Información de la ruta
          Row(
            children: [
              // Tipo de ruta
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorRuta.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getIconoTipoRuta(), color: colorRuta, size: 14),
                    SizedBox(width: 4),
                    Text(
                      tipoRuta,
                      style: TextStyle(
                        color: colorRuta,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              
              // Duración y distancia
              Text(
                '$duracion • $distancia',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 12),
              
              // Seguridad
              if (completada) Row(
                children: [
                  Icon(Icons.security, color: Theme.of(context).colorScheme.secondary, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '$seguridad%',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Motivo de cancelación si aplica
          if (!completada && motivo != null) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).colorScheme.error, size: 16),
                SizedBox(width: 8),
                Text(
                  motivo!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}