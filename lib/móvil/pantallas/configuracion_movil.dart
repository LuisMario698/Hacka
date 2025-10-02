import 'package:flutter/material.dart';
import '../../servicios/theme_widgets.dart';

/// Pantalla de configuración para la app móvil
/// Incluye control de temas y otras configuraciones accesibles
class ConfiguracionMovil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card de configuración de tema
              _buildThemeCard(context),
              
              SizedBox(height: 20),
              
              // Otras configuraciones
              _buildOtherSettings(context),
              
              SizedBox(height: 20),
              
              // Configuraciones de seguridad
              _buildSecuritySettings(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_rounded,
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.lightBlue.shade300
                    : Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Apariencia',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Elige el tema que más te guste. El modo claro es recomendado para todas las edades y es más accesible.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
            SizedBox(height: 20),
            
            // Control de tema simple para móvil
            Center(
              child: ThemeToggleSwitch(
                showLabel: true,
                size: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherSettings(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_rounded,
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.green.shade300
                    : Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Preferencias',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            SwitchListTile(
              title: Text(
                'Notificaciones',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                'Recibir alertas y notificaciones de seguridad',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              value: true,
              onChanged: (value) {
                // TODO: Implementar cambio de notificaciones
              },
              activeColor: Theme.of(context).colorScheme.primary,
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            ),
            
            Divider(),
            
            ListTile(
              leading: Icon(
                Icons.language_rounded,
                color: Theme.of(context).colorScheme.secondary,
                size: 28,
              ),
              title: Text(
                'Idioma',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                'Español (México)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              onTap: () {
                // TODO: Mostrar selector de idioma
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Próximamente: Selector de idioma'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySettings(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security_rounded,
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.orange.shade300
                    : Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Seguridad',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            ListTile(
              leading: Icon(
                Icons.lock_rounded,
                color: Theme.of(context).colorScheme.secondary,
                size: 28,
              ),
              title: Text(
                'Cambiar contraseña',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                'Actualizar tu contraseña de acceso',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              onTap: () {
                // TODO: Mostrar diálogo de cambio de contraseña
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Próximamente: Cambio de contraseña'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            ),
            
            Divider(),
            
            SwitchListTile(
              secondary: Icon(
                Icons.fingerprint_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              title: Text(
                'Huella dactilar',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                'Usar biometría para acceso rápido',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              value: false,
              onChanged: (value) {
                // TODO: Implementar configuración biométrica
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Próximamente: Autenticación biométrica'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              activeColor: Theme.of(context).colorScheme.primary,
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            ),
          ],
        ),
      ),
    );
  }
}