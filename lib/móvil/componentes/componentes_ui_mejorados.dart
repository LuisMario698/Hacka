import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Componente mejorado para accesos rápidos en la pantalla principal
class AccesoRapidoMejorado extends StatelessWidget {
  final IconData icon;
  final String title;
  final String descripcion;
  final Color color;
  final VoidCallback onTap;

  const AccesoRapidoMejorado({
    Key? key,
    required this.icon,
    required this.title,
    required this.descripcion,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title - $descripcion',
      hint: 'Toque para acceder',
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  descripcion,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header mejorado para secciones
class HeaderSeccionMejorado extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final IconData? icono;
  final Widget? accion;

  const HeaderSeccionMejorado({
    Key? key,
    required this.titulo,
    this.subtitulo,
    this.icono,
    this.accion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4, 24, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icono != null) ...[
                Icon(
                  icono!,
                  color: Color(0xFF2E7D32),
                  size: 24,
                ),
                SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              if (accion != null) accion!,
            ],
          ),
          if (subtitulo != null) ...[
            SizedBox(height: 4),
            Text(
              subtitulo!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
          SizedBox(height: 8),
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de estadística mejorada
class TarjetaEstadisticaMejorada extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final String? descripcion;

  const TarjetaEstadisticaMejorada({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.descripcion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (descripcion != null) ...[
              SizedBox(height: 4),
              Text(
                descripcion!,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Alerta de zona mejorada con mejor accesibilidad
class AlertaZonaMejorada extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const AlertaZonaMejorada({
    Key? key,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: '$title - $description',
      hint: 'Alerta de zona - $time',
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap != null ? () {
            HapticFeedback.lightImpact();
            onTap!();
          } : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
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
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade400,
                    size: 14,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}