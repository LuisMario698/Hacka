import 'package:flutter/material.dart';
import '../servicios/theme_service.dart';

/// Widget switch accesible para cambiar entre tema claro y oscuro
/// Diseñado para ser fácil de usar por todas las edades
class ThemeToggleSwitch extends StatelessWidget {
  final bool showLabel;
  final double size;
  
  const ThemeToggleSwitch({
    Key? key,
    this.showLabel = true,
    this.size = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, child) {
        final themeService = ThemeService();
        final isDarkMode = themeService.isDarkMode;
        
        return InkWell(
          onTap: () => themeService.toggleTheme(),
          borderRadius: BorderRadius.circular(25 * size),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16 * size, 
              vertical: 12 * size
            ),
            decoration: BoxDecoration(
              color: isDarkMode 
                ? Colors.white.withOpacity(0.15)
                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25 * size),
              border: Border.all(
                color: isDarkMode 
                  ? Colors.white.withOpacity(0.4)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: isDarkMode 
                    ? Colors.white.withOpacity(0.9)
                    : Theme.of(context).colorScheme.primary,
                  size: 24 * size,
                ),
                if (showLabel) ...[
                  SizedBox(width: 8 * size),
                  Text(
                    isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
                    style: TextStyle(
                      color: isDarkMode 
                        ? Colors.white.withOpacity(0.9)
                        : Theme.of(context).colorScheme.primary,
                      fontSize: 16 * size,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget card con opciones de tema para pantallas de configuración
class ThemeSettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, child) {
        final themeService = ThemeService();
        final isDarkMode = themeService.isDarkMode;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.palette_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Apariencia',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Elige el tema que más te guste. El modo claro es más accesible para todas las edades.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 20),
                
                // Opción tema claro
                InkWell(
                  onTap: () => themeService.setTheme(false),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: !isDarkMode 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !isDarkMode 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        width: !isDarkMode ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.light_mode_rounded, color: Colors.white),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Modo Claro',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: !isDarkMode ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              Text(
                                'Recomendado para todas las edades',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (!isDarkMode)
                          Icon(
                            Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Opción tema oscuro
                InkWell(
                  onTap: () => themeService.setTheme(true),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        width: isDarkMode ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xFF1B263B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.dark_mode_rounded, color: Colors.white),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Modo Oscuro',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: isDarkMode ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              Text(
                                'Para usuarios avanzados',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (isDarkMode)
                          Icon(
                            Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}