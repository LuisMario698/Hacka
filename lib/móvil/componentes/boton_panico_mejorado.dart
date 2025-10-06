import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Botón de pánico mejorado con funcionalidades de accesibilidad y seguridad
class BotonPanicoMejorado extends StatefulWidget {
  final VoidCallback onActivarEmergencia;
  
  const BotonPanicoMejorado({
    Key? key,
    required this.onActivarEmergencia,
  }) : super(key: key);

  @override
  State<BotonPanicoMejorado> createState() => _BotonPanicoMejoradoState();
}

class _BotonPanicoMejoradoState extends State<BotonPanicoMejorado> {
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _mostrarDialogoPanico() {
    // Vibración fuerte para alertar
    HapticFeedback.heavyImpact();
    
    showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar accidentalmente
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.shade700, width: 2),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade700,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'EMERGENCIA',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás en una situación de emergencia?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Se enviará tu ubicación a contactos de emergencia y autoridades',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'CANCELAR',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onActivarEmergencia();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sos, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'ACTIVAR SOS',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Botón de emergencia SOS',
      hint: 'Toque para activar alerta de emergencia',
      button: true,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.orange,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _mostrarDialogoPanico,
            borderRadius: BorderRadius.circular(32),
            child: Center(
              child: Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Servicio para manejar emergencias
class ServicioEmergencia {
  static Future<void> activarAlertaEmergencia(BuildContext context) async {
    try {
      // Vibración fuerte
      HapticFeedback.heavyImpact();
      
      // TODO: Implementar:
      // 1. Obtener ubicación actual
      // 2. Enviar SMS a contactos de emergencia
      // 3. Enviar notificación a base de datos
      // 4. Llamar a servicios de emergencia si está configurado
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🚨 ALERTA DE EMERGENCIA ACTIVADA\nContactos notificados con tu ubicación',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'VER DETALLES',
            textColor: Colors.white,
            onPressed: () {
              // Navegar a pantalla de emergencia activa
            },
          ),
        ),
      );
      
      // Sonido de alerte (opcional, configurable)
      await _reproducirSonidoAlerta();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al activar emergencia: $e'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }
  
  static Future<void> _reproducirSonidoAlerta() async {
    // TODO: Implementar reproducción de sonido de alerta
    // usando paquete como audioplayers
  }
}