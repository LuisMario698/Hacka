import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

/// Pantalla de reporte de incidente, siguiendo el diseño elegante de la app.
class PantallaReporte extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text('Reportar incidente', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona el tipo de incidente:',
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 24),
            const _OpcionReporte(icon: Icons.lightbulb, label: 'Foco Descompuesto'),
            const _OpcionReporte(icon: Icons.nightlight_round, label: 'Calle Muy Oscura'),
            const _OpcionReporte(icon: Icons.groups, label: 'Actividad Sospechosa'),
            const _OpcionReporte(icon: Icons.construction, label: 'Banqueta Rota/Peligro'),
            const _OpcionReporte(icon: Icons.local_police, label: 'Presencia Policial'),
            const Spacer(),
            Center(
              child: Text('Tu reporte es anónimo y ayuda a mejorar la seguridad.',
                style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6), fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Fin de archivo

class _OpcionReporte extends StatelessWidget {
  final IconData icon;
  final String label;
  const _OpcionReporte({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => _ModalComentarioReporte(icon: icon, label: label),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.15),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 28),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
                            Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModalComentarioReporte extends StatefulWidget {
  final IconData icon;
  final String label;
  const _ModalComentarioReporte({required this.icon, required this.label});

  @override
  State<_ModalComentarioReporte> createState() => _ModalComentarioReporteState();
}

class _ModalComentarioReporteState extends State<_ModalComentarioReporte> {
  LatLng? _ubicacionSeleccionada;
  final TextEditingController _controller = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF23243A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              children: [
                Icon(widget.icon, color: Colors.white, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.label,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Botón para seleccionar ubicación en el mapa
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.location_pin, color: Colors.white),
                label: Text(_ubicacionSeleccionada == null
                    ? 'Seleccionar ubicación en el mapa'
                    : 'Ubicación seleccionada: ${_ubicacionSeleccionada!.latitude.toStringAsFixed(5)}, ${_ubicacionSeleccionada!.longitude.toStringAsFixed(5)}'),
                onPressed: () async {
                  final LatLng? result = await showModalBottomSheet<LatLng>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => _SelectorMapaSheet(),
                  );
                  if (result != null) {
                    setState(() => _ubicacionSeleccionada = result);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 4,
              minLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Agrega un comentario (opcional)...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xCCFF3B30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: _enviando
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                label: Text(
                  _enviando ? 'Enviando...' : 'Enviar reporte',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                onPressed: _enviando
                    ? null
                    : () async {
                        setState(() => _enviando = true);
                        await Future.delayed(const Duration(seconds: 1));
                        setState(() => _enviando = false);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Reporte enviado: ${widget.label}' +
                            (_ubicacionSeleccionada != null ? '\nUbicación: ${_ubicacionSeleccionada!.latitude.toStringAsFixed(5)}, ${_ubicacionSeleccionada!.longitude.toStringAsFixed(5)}' : '')
                          )),
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selector de ubicación en el mapa para el reporte
class _SelectorMapaSheet extends StatefulWidget {
  const _SelectorMapaSheet();
  @override
  State<_SelectorMapaSheet> createState() => _SelectorMapaSheetState();
}

class _SelectorMapaSheetState extends State<_SelectorMapaSheet> {
  LatLng _pin = LatLng(19.4326, -99.1332); // CDMX por defecto

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.65;
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFF23243A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Text('Selecciona la ubicación del incidente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: FlutterMap(
                options: MapOptions(
                  center: _pin,
                  zoom: 15.5,
                  onTap: (tapPos, latlng) {
                    setState(() => _pin = latlng);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                    subdomains: ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.example.rutasseguras',
                    backgroundColor: Colors.transparent,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pin,
                        width: 48,
                        height: 48,
                        child: const Icon(Icons.location_pin, color: Color(0xFF00CFFF), size: 48),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00CFFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('Usar esta ubicación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
              onPressed: () {
                Navigator.of(context).pop(_pin);
              },
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
