import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pantalla_mapa_interactivo.dart';
import 'pantalla_reportes.dart';
import 'pantalla_perfil_usuario.dart';
import 'configuracion_accesibilidad.dart';
import '../componentes/boton_panico_mejorado.dart';
import '../../servicios/auth_service.dart';

/// Modo simplificado para adultos mayores y usuarios con necesidades especiales
class ModoSimplificado extends StatefulWidget {
  @override
  State<ModoSimplificado> createState() => _ModoSimplificadoState();
}

class _ModoSimplificadoState extends State<ModoSimplificado> {
  String _nombreUsuario = 'Usuario';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  void _cargarDatosUsuario() {
    final userData = AuthService.obtenerSesion();
    if (userData != null) {
      setState(() {
        _nombreUsuario = userData['nombre'] ?? 'Usuario';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Rutas Seguras',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, size: 28),
            onPressed: _mostrarMenu,
            tooltip: 'Configuración',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Saludo personal
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade200,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.waving_hand,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(height: 12),
                  Text(
                    '¡Hola, $_nombreUsuario!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Mantente seguro en tus recorridos',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            // Botones principales grandes
            _BotonGrande(
              icono: Icons.map_rounded,
              texto: 'VER MAPA\nSEGURO',
              descripcion: 'Consulta zonas seguras y sensores',
              color: Colors.blue.shade600,
              onPressed: () => _navegarA(PantallaMapaInteractivo()),
            ),
            
            SizedBox(height: 20),
            
            _BotonGrande(
              icono: Icons.report_problem,
              texto: 'REPORTAR\nPROBLEMA',
              descripcion: 'Informa sobre situaciones peligrosas',
              color: Colors.orange.shade600,
              onPressed: () => _navegarA(PantallaReportes()),
            ),
            
            SizedBox(height: 20),
            
            _BotonGrande(
              icono: Icons.person,
              texto: 'MI PERFIL',
              descripcion: 'Ver información y configuración',
              color: Colors.purple.shade600,
              onPressed: () => _navegarA(PantallaPerfilUsuario()),
            ),
            
            SizedBox(height: 32),
            
            // Botón de emergencia extra grande
            Container(
              width: double.infinity,
              height: 120,
              child: ElevatedButton(
                onPressed: () => _activarEmergencia(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sos, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'EMERGENCIA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Pide ayuda inmediata',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Información de ayuda
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline, color: Colors.blue.shade700),
                      SizedBox(width: 8),
                      Text(
                        '¿Necesitas ayuda?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Toca cualquier botón para usar esa función\n'
                    '• El botón rojo es solo para emergencias\n'
                    '• Puedes cambiar el tamaño de letra en configuración',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade700,
                      height: 1.5,
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

  void _navegarA(Widget pantalla) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => pantalla),
    );
  }

  void _activarEmergencia() {
    HapticFeedback.heavyImpact();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.shade700, width: 2),
        ),
        title: Column(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade700,
              size: 48,
            ),
            SizedBox(height: 8),
            Text(
              'EMERGENCIA',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          '¿Estás en peligro y necesitas ayuda inmediata?\n\n'
          'Se enviará tu ubicación a tus contactos de confianza y autoridades.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'NO, CANCELAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ServicioEmergencia.activarAlertaEmergencia(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'SÍ, PEDIR AYUDA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Configuración',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.accessibility_new, size: 28),
              title: Text('Accesibilidad', style: TextStyle(fontSize: 18)),
              subtitle: Text('Ajustar tamaño y contraste'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfiguracionAccesibilidad(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.view_comfortable, size: 28),
              title: Text('Modo Normal', style: TextStyle(fontSize: 18)),
              subtitle: Text('Cambiar a interfaz completa'),
              onTap: () {
                Navigator.pop(context);
                _cambiarAModoNormal();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _cambiarAModoNormal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cambiar Modo'),
        content: Text(
          '¿Quieres cambiar al modo normal?\n\n'
          'El modo normal tiene más opciones pero puede ser más complejo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar cambio a modo normal
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cambiando a modo normal...'),
                  backgroundColor: Color(0xFF2E7D32),
                ),
              );
            },
            child: Text('CAMBIAR'),
          ),
        ],
      ),
    );
  }
}

class _BotonGrande extends StatelessWidget {
  final IconData icono;
  final String texto;
  final String descripcion;
  final Color color;
  final VoidCallback onPressed;

  const _BotonGrande({
    required this.icono,
    required this.texto,
    required this.descripcion,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          padding: EdgeInsets.all(16),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icono,
                size: 40,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    texto,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}