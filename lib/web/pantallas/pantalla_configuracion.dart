import 'package:flutter/material.dart';
import '../../servicios/theme_widgets.dart';

class PantallaConfiguracion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Configuración', 
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ListView(
            children: [
              // Card de configuración de tema
              ThemeSettingsCard(),
              
              SizedBox(height: 24),
              
              // Otras configuraciones
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.settings_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Opciones de Sistema',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      
                      SwitchListTile(
                        title: Text(
                          'Notificaciones',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          'Recibir alertas y notificaciones del sistema',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        value: true,
                        onChanged: (v) {},
                        activeColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Card de seguridad
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.security_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Seguridad',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      
                      ListTile(
                        leading: Icon(
                          Icons.lock_rounded, 
                          color: Theme.of(context).colorScheme.secondary,
                          size: 32,
                        ),
                        title: Text(
                          'Cambiar contraseña',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          'Actualizar tu contraseña de acceso',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        onTap: () {},
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      ),
                      
                      SwitchListTile(
                        secondary: Icon(
                          Icons.fingerprint_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        title: Text(
                          'Autenticación biométrica',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          'Usar huella dactilar para acceder',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        value: false,
                        onChanged: (v) {},
                        activeColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Card de personalización
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Personalización',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      
                      ListTile(
                        leading: Icon(
                          Icons.language_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 32,
                        ),
                        title: Text(
                          'Idioma',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          'Español (México)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        onTap: () {},
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
