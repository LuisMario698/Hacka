import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../tema/tema_profesional.dart';

/// Pantalla de configuración de accesibilidad para todos los usuarios
class ConfiguracionAccesibilidad extends StatefulWidget {
  @override
  State<ConfiguracionAccesibilidad> createState() => _ConfiguracionAccesibilidadState();
}

class _ConfiguracionAccesibilidadState extends State<ConfiguracionAccesibilidad> {
  double _tamanoFuente = 16.0;
  bool _contrasteAlto = false;
  bool _botonesGrandes = false;
  bool _vibracionHabilitada = true;
  bool _audioAlertasHabilitado = true;
  bool _modoSimplificado = false;
  bool _lecturaVozHabilitada = false;
  
  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tamanoFuente = prefs.getDouble('tamano_fuente') ?? 16.0;
      _contrasteAlto = prefs.getBool('contraste_alto') ?? false;
      _botonesGrandes = prefs.getBool('botones_grandes') ?? false;
      _vibracionHabilitada = prefs.getBool('vibracion_habilitada') ?? true;
      _audioAlertasHabilitado = prefs.getBool('audio_alertas') ?? true;
      _modoSimplificado = prefs.getBool('modo_simplificado') ?? false;
      _lecturaVozHabilitada = prefs.getBool('lectura_voz') ?? false;
    });
  }

  Future<void> _guardarConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tamano_fuente', _tamanoFuente);
    await prefs.setBool('contraste_alto', _contrasteAlto);
    await prefs.setBool('botones_grandes', _botonesGrandes);
    await prefs.setBool('vibracion_habilitada', _vibracionHabilitada);
    await prefs.setBool('audio_alertas', _audioAlertasHabilitado);
    await prefs.setBool('modo_simplificado', _modoSimplificado);
    await prefs.setBool('lectura_voz', _lecturaVozHabilitada);
    
    // Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Configuración guardada exitosamente'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Actualizar PaletaProfesional según el tema actual
    final isDark = Theme.of(context).brightness == Brightness.dark;
    PaletaProfesional.setTemaOscuro(isDark);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Accesibilidad'),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _guardarConfiguracion,
            tooltip: 'Guardar configuración',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header informativo
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.accessibility_new, color: Colors.blue.shade700, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuración de Accesibilidad',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Personaliza la app para tus necesidades',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Sección: Visualización
            _construirSeccion(
              titulo: 'Visualización',
              icono: Icons.visibility,
              children: [
                _construirSliderTamanoFuente(),
                SizedBox(height: 16),
                _construirSwitchContrasteAlto(),
                SizedBox(height: 16),
                _construirSwitchBotonesGrandes(),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Sección: Interacción
            _construirSeccion(
              titulo: 'Interacción',
              icono: Icons.touch_app,
              children: [
                _construirSwitchVibracion(),
                SizedBox(height: 16),
                _construirSwitchAudioAlertas(),
                SizedBox(height: 16),
                _construirSwitchLecturaVoz(),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Sección: Modo Simplificado
            _construirSeccion(
              titulo: 'Experiencia de Usuario',
              icono: Icons.view_comfortable,
              children: [
                _construirSwitchModoSimplificado(),
              ],
            ),
            
            SizedBox(height: 32),
            
            // Botón de prueba de accesibilidad
            _construirBotonPrueba(),
            
            SizedBox(height: 16),
            
            // Información adicional
            _construirInfoAdicional(),
          ],
        ),
      ),
    );
  }

  Widget _construirSeccion({
    required String titulo,
    required IconData icono,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, color: Color(0xFF2E7D32), size: 24),
            SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirSliderTamanoFuente() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.text_fields, color: Colors.grey.shade600),
            SizedBox(width: 8),
            Text(
              'Tamaño de fuente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Text('A', style: TextStyle(fontSize: 12)),
            Expanded(
              child: Slider(
                value: _tamanoFuente,
                min: 12.0,
                max: 24.0,
                divisions: 6,
                activeColor: Color(0xFF2E7D32),
                onChanged: (value) {
                  setState(() {
                    _tamanoFuente = value;
                  });
                  HapticFeedback.selectionClick();
                },
              ),
            ),
            Text('A', style: TextStyle(fontSize: 20)),
          ],
        ),
        Text(
          'Texto de ejemplo con tamaño ${_tamanoFuente.round()}pt',
          style: TextStyle(fontSize: _tamanoFuente),
        ),
      ],
    );
  }

  Widget _construirSwitchContrasteAlto() {
    return _construirSwitchGenerico(
      icono: Icons.contrast,
      titulo: 'Contraste alto',
      subtitulo: 'Mejora la visibilidad del texto y elementos',
      valor: _contrasteAlto,
      onChanged: (value) {
        setState(() {
          _contrasteAlto = value;
        });
      },
    );
  }

  Widget _construirSwitchBotonesGrandes() {
    return _construirSwitchGenerico(
      icono: Icons.crop_free,
      titulo: 'Botones grandes',
      subtitulo: 'Botones más grandes para facilitar el toque',
      valor: _botonesGrandes,
      onChanged: (value) {
        setState(() {
          _botonesGrandes = value;
        });
      },
    );
  }

  Widget _construirSwitchVibracion() {
    return _construirSwitchGenerico(
      icono: Icons.vibration,
      titulo: 'Vibración',
      subtitulo: 'Vibración para alertas y confirmaciones',
      valor: _vibracionHabilitada,
      onChanged: (value) {
        setState(() {
          _vibracionHabilitada = value;
        });
        if (value) {
          HapticFeedback.mediumImpact();
        }
      },
    );
  }

  Widget _construirSwitchAudioAlertas() {
    return _construirSwitchGenerico(
      icono: Icons.volume_up,
      titulo: 'Audio para alertas',
      subtitulo: 'Sonidos para notificaciones de seguridad',
      valor: _audioAlertasHabilitado,
      onChanged: (value) {
        setState(() {
          _audioAlertasHabilitado = value;
        });
      },
    );
  }

  Widget _construirSwitchLecturaVoz() {
    return _construirSwitchGenerico(
      icono: Icons.record_voice_over,
      titulo: 'Lectura por voz',
      subtitulo: 'Compatibilidad con lectores de pantalla',
      valor: _lecturaVozHabilitada,
      onChanged: (value) {
        setState(() {
          _lecturaVozHabilitada = value;
        });
      },
    );
  }

  Widget _construirSwitchModoSimplificado() {
    return _construirSwitchGenerico(
      icono: Icons.view_comfortable,
      titulo: 'Modo simplificado',
      subtitulo: 'Interfaz simplificada con botones grandes',
      valor: _modoSimplificado,
      onChanged: (value) {
        setState(() {
          _modoSimplificado = value;
        });
        if (value) {
          _mostrarDialogoModoSimplificado();
        }
      },
    );
  }

  Widget _construirSwitchGenerico({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icono, color: Colors.grey.shade600),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                subtitulo,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Switch(
          value: valor,
          onChanged: onChanged,
          activeColor: Color(0xFF2E7D32),
        ),
      ],
    );
  }

  Widget _construirBotonPrueba() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _probarConfiguracion,
        icon: Icon(Icons.play_arrow),
        label: Text('PROBAR CONFIGURACIÓN'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _construirInfoAdicional() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade600),
              SizedBox(width: 8),
              Text(
                'Información adicional',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• La configuración se aplica inmediatamente\n'
            '• Algunas opciones requieren reiniciar la app\n'
            '• Compatible con lectores de pantalla estándar\n'
            '• Para más ayuda, contacta soporte técnico',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _probarConfiguracion() {
    if (_vibracionHabilitada) {
      HapticFeedback.mediumImpact();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Configuración aplicada correctamente ✓',
          style: TextStyle(fontSize: _tamanoFuente),
        ),
        backgroundColor: Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _mostrarDialogoModoSimplificado() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.view_comfortable, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('Modo Simplificado'),
          ],
        ),
        content: Text(
          'El modo simplificado facilita el uso de la app con:\n\n'
          '• Botones más grandes\n'
          '• Menos opciones en pantalla\n'
          '• Navegación más simple\n'
          '• Ideal para adultos mayores',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ENTENDIDO'),
          ),
        ],
      ),
    );
  }
}

/// Servicio para gestionar configuración de accesibilidad
class ServicioAccesibilidad {
  static Future<Map<String, dynamic>> obtenerConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'tamano_fuente': prefs.getDouble('tamano_fuente') ?? 16.0,
      'contraste_alto': prefs.getBool('contraste_alto') ?? false,
      'botones_grandes': prefs.getBool('botones_grandes') ?? false,
      'vibracion_habilitada': prefs.getBool('vibracion_habilitada') ?? true,
      'audio_alertas': prefs.getBool('audio_alertas') ?? true,
      'modo_simplificado': prefs.getBool('modo_simplificado') ?? false,
      'lectura_voz': prefs.getBool('lectura_voz') ?? false,
    };
  }
  
  static Future<bool> esModoSimplificado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('modo_simplificado') ?? false;
  }
  
  static Future<double> obtenerTamanoFuente() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('tamano_fuente') ?? 16.0;
  }
}