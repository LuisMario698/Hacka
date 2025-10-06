# 🗺️ Integración de Sensores en el Mapa de Reportes

## 📋 Resumen de Cambios

Se ha actualizado la **Pantalla de Reportes** para mostrar todos los sensores IoT del sistema en el mapa, junto con los reportes existentes. Esto proporciona una vista completa de la infraestructura de monitoreo y permite correlacionar reportes con datos de sensores cercanos.

## 🎯 Funcionalidades Implementadas

### 1. **Carga Automática de Sensores**

```dart
@override
void initState() {
  super.initState();
  _cargarSensores();
}

Future<void> _cargarSensores() async {
  final sensores = await NodoService.obtenerTodosLosNodos();
  setState(() {
    _sensores = sensores;
  });
}
```

- Los sensores se cargan automáticamente al abrir la pantalla
- Se usa `NodoService.obtenerTodosLosNodos()` para obtener todos los sensores con sus últimas lecturas
- Manejo de errores con SnackBar informativo

### 2. **Marcadores Diferenciados en el Mapa**

#### **Marcadores de Sensores** (círculos grandes con iconos)
- 🟢 **Verde** con icono de sensores: Sensor en línea (estado 'online')
- 🟠 **Naranja** con icono de alerta: Sensor con alerta (estado 'alerta')
- ⚫ **Gris** con icono de sensor apagado: Sensor fuera de línea (estado 'offline')
- ⚪ **Gris claro** con icono de ayuda: Sensor sin datos (estado 'sin_datos')

#### **Marcadores de Reportes** (círculos más pequeños con icono de reporte)
- 🔴 **Rojo**: Reporte de prioridad crítica
- 🟠 **Naranja oscuro**: Reporte de prioridad alta
- 🟡 **Amarillo**: Reporte de prioridad media
- 🔵 **Azul**: Reporte de prioridad baja (default)

### 3. **Leyenda Interactiva**

Se agregó una leyenda flotante en la esquina superior derecha del mapa que explica:
- Los diferentes tipos de marcadores de sensores
- Los diferentes tipos de marcadores de reportes
- Códigos de color y significados

```dart
Positioned(
  top: 16,
  right: 16,
  child: Container(
    // Leyenda con fondo blanco y sombra
    child: Column(
      children: [
        'Leyenda',
        Sensor En Línea (verde),
        Sensor con Alerta (naranja),
        Sensor Fuera de Línea (gris),
        ---
        Reporte Crítico (rojo),
        Reporte Alta (naranja),
        Reporte Media (amarillo),
      ],
    ),
  ),
)
```

### 4. **Diálogo de Detalles del Sensor**

Al hacer clic en un marcador de sensor, se muestra un diálogo con:

- **Información básica**:
  - Nombre del sensor
  - Clave del dispositivo
  - Ubicación (coordenadas)
  
- **Estado actual**:
  - Badge con gradiente de color según el estado
  - Icono descriptivo (✓ en línea, ⚠ alerta, ☁ offline, ? sin datos)
  
- **Últimas lecturas**:
  - 💡 Nivel de luz (lux)
  - 🔊 Nivel de ruido (dB)
  - Timestamp de última actualización
  
- **Acciones**:
  - Botón "Cerrar"
  - Botón "Ver Historial" → Muestra SnackBar con opción de navegar a la pantalla de sensores

```dart
void _mostrarDetalleSensor(Nodo sensor) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: sensor.nombre,
      content: [
        ID, Ubicación,
        Estado con badge,
        Últimas lecturas (luz, ruido),
        Timestamp,
      ],
      actions: [
        'Cerrar',
        'Ver Historial',
      ],
    ),
  );
}
```

### 5. **Estadísticas Actualizadas**

En el header se agregó un chip adicional mostrando la cantidad total de sensores:

```dart
Row(
  children: [
    _buildStatChip('Reportes', total, Colors.blue),
    _buildStatChip('Nuevos', nuevos, Colors.orange),
    _buildStatChip('En Proceso', enProceso, Colors.amber),
    _buildStatChip('Sensores', _sensores.length, Colors.green), // ← NUEVO
  ],
)
```

### 6. **Botón de Refresco**

Se agregó un botón para recargar los sensores manualmente:
- Icono de "refresh" normal
- Durante la carga, muestra un CircularProgressIndicator
- Deshabilitado mientras está cargando

## 🎨 Detalles Visuales

### **Marcadores de Sensores**
- Tamaño: 40x40 px
- Forma: Círculo
- Borde blanco de 3px
- Sombra negra con blur de 6px
- Icono blanco centrado de 22px

### **Marcadores de Reportes**
- Tamaño: 36x36 px (ligeramente más pequeños)
- Forma: Círculo
- Borde blanco de 2px
- Sombra negra con blur de 4px
- Icono blanco centrado de 18px

### **Leyenda**
- Fondo blanco con sombra sutil
- Bordes redondeados (8px)
- Padding de 12px
- Cada ítem tiene un mini marcador circular de 24px
- Separador entre sensores y reportes

### **Diálogo de Detalles del Sensor**
- Badge de estado con gradiente de color
- Iconos descriptivos para cada métrica
- Formato de fecha: dd/MM/yyyy HH:mm
- Valores numéricos con 1 decimal
- Texto en cursiva para timestamps

## 📊 Integración con el Sistema

### **Servicios Utilizados**
```dart
import '../../servicios/nodo_service.dart';
import '../../modelos/nodo_model.dart';
```

- `NodoService.obtenerTodosLosNodos()` - Obtiene todos los sensores con últimas lecturas
- `Nodo.obtenerEstado()` - Calcula el estado del sensor (online/offline/alerta/sin_datos)

### **Dependencias**
```dart
import 'package:intl/intl.dart'; // Para formatear fechas
```

## 🔄 Flujo de Datos

1. **initState()** → Llama a `_cargarSensores()`
2. **_cargarSensores()** → Consulta `NodoService.obtenerTodosLosNodos()`
3. **setState()** → Actualiza `_sensores` y `_cargandoSensores`
4. **build()** → Renderiza el mapa con dos MarkerLayers:
   - Primera capa: Marcadores de sensores
   - Segunda capa: Marcadores de reportes
5. **onTap** → Muestra diálogo de detalles (sensor o reporte)

## 🚀 Beneficios

### **Para Administradores**
- ✅ Vista completa de la infraestructura de monitoreo
- ✅ Correlación visual entre reportes y sensores cercanos
- ✅ Identificación rápida de zonas con/sin cobertura de sensores
- ✅ Detección de patrones geográficos
- ✅ Toma de decisiones informada sobre dónde agregar nuevos sensores

### **Para el Sistema**
- ✅ Reutilización de servicios existentes (NodoService)
- ✅ Código limpio y bien estructurado
- ✅ Manejo robusto de errores
- ✅ Indicadores visuales claros y diferenciados
- ✅ Experiencia de usuario mejorada

## 📝 Notas Técnicas

### **Rendimiento**
- Los sensores se cargan una sola vez al iniciar la pantalla
- Botón de refresco manual para actualizar datos
- No hay polling automático (evita carga innecesaria del servidor)
- MarkerLayers separados para mejor organización del código

### **Mantenibilidad**
- Métodos auxiliares claramente nombrados
- Separación de lógica de sensores y reportes
- Comentarios descriptivos en el código
- Estructura modular fácil de extender

### **Extensibilidad**
- Fácil agregar filtros por tipo de sensor
- Posibilidad de agregar clustering para muchos marcadores
- Base para implementar rutas entre reportes y sensores
- Preparado para agregar heat maps de lecturas

## 🎯 Próximos Pasos Sugeridos

1. **Filtros avanzados**: Permitir filtrar sensores por estado en el mapa
2. **Clustering**: Agrupar marcadores cuando hay muchos sensores cercanos
3. **Heat maps**: Mostrar mapas de calor de luz/ruido
4. **Rutas**: Calcular distancias entre reportes y sensores
5. **Alertas geográficas**: Notificar si un reporte ocurre cerca de un sensor con alerta
6. **Historial en línea**: Ver gráficas de lecturas sin salir del mapa
7. **Exportar datos**: Generar reportes PDF con mapa incluido

## ✅ Estado Actual

- ✅ Todos los sensores se muestran en el mapa
- ✅ Marcadores diferenciados por tipo y estado
- ✅ Leyenda explicativa visible
- ✅ Diálogos de detalles funcionales
- ✅ Estadísticas actualizadas
- ✅ Botón de refresco implementado
- ✅ Sin errores de compilación
- ✅ Listo para pruebas

---

**Última actualización**: Enero 2025  
**Versión**: 1.0  
**Autor**: GitHub Copilot

