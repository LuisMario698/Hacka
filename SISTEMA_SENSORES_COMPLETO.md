# 📡 Sistema de Gestión de Sensores IoT - COMPLETADO

## ✅ Implementación Completa

### 1. Modelos Creados

#### `lib/modelos/nodo_model.dart`
- Representa un sensor/nodo ESP32
- Propiedades: id, nombre, claveDelDispositivo, latitud, longitud, activo
- Métodos útiles:
  - `obtenerEstado()`: online, offline, alerta, sin_datos
  - `obtenerNivelBateria()`: Calcula batería estimada
  - `fromJson()` y `toJson()`: Serialización

#### `lib/modelos/lectura_model.dart`
- Representa una lectura de sensor (luz y ruido)
- Propiedades: identificacion, nodoId, lux, ruido, fecha
- Métodos de evaluación:
  - `evaluarLuz()`: Baja, Media, Alta, Muy Alta
  - `evaluarRuido()`: Silencioso, Moderado, Alto, Muy Alto
  - `tieneAlerta()`: true si lux < 50 o ruido > 80
  - `obtenerTipoAlerta()`: Describe el tipo de alerta

### 2. Servicio de Nodos

#### `lib/servicios/nodo_service.dart`
Funciones implementadas:

**Consultas:**
- `obtenerTodosLosNodos()`: Lista completa con última lectura
- `obtenerNodoPorId(id)`: Nodo específico
- `obtenerNodosPorEstado(estado)`: Filtrar por estado
- `obtenerEstadisticas()`: Contadores (total, online, offline, alerta)

**CRUD de Nodos:**
- `crearNodo()`: Agregar nuevo sensor
- `actualizarNodo()`: Modificar sensor existente
- `eliminarNodo(id)`: Borrar sensor y sus lecturas
- `cambiarEstadoActivo(id, activo)`: Activar/desactivar

**Lecturas:**
- `obtenerLecturasDeNodo(nodoId, limite)`: Historial de un nodo
- `obtenerUltimaLectura(nodoId)`: Lectura más reciente
- `obtenerLecturasRecientes(horas)`: Últimas N horas
- `obtenerLecturasConAlertas(limite)`: Solo lecturas críticas
- `crearLectura()`: Insertar lectura manual

### 3. Pantalla Web Renovada

#### `lib/web/pantallas/pantalla_sensores_nueva.dart`

**Características:**
- ✅ Carga datos reales desde Supabase
- ✅ Tarjetas de resumen (Total, En Línea, Offline, Alertas)
- ✅ Búsqueda por nombre o clave
- ✅ Filtros por estado (chips interactivos)
- ✅ Tabla completa con 8 columnas
- ✅ Badges de estado coloreados
- ✅ Indicador de batería
- ✅ Botón refrescar datos

**Acciones CRUD:**
- ➕ Agregar sensor (diálogo con formulario)
- ✏️ Editar sensor (incluye switch activo/inactivo)
- 🗑️ Eliminar sensor (confirmación con advertencia)
- 📊 Ver historial (diálogo con últimas 50 lecturas)

**Vista de Historial:**
- Lista de lecturas ordenadas por fecha
- Evaluación de luz y ruido
- Badges de alerta con descripción
- Formato de fecha legible

### 4. Persistencia de Sesión

#### Actualizado `lib/servicios/auth_service.dart`
- ✅ `guardarSesion()`: Guarda en memoria Y SharedPreferences
- ✅ `cargarSesion()`: Restaura sesión al iniciar app
- ✅ `cerrarSesion()`: Limpia memoria y persistencia

#### Actualizados main files
- `lib/web/main_web.dart`: Carga sesión antes de iniciar
- `lib/móvil/main_movil.dart`: Carga sesión antes de iniciar
- Dashboard y perfil usan `await` al cerrar sesión

## 📊 Base de Datos

### Script SQL: `insertar_datos_sensores.sql`

**Contenido:**
1. **10 Sensores ESP32** en diferentes ubicaciones
   - 9 activos, 1 inactivo (Estadio Municipal)
   - Ubicaciones realistas en Ciudad de México

2. **~900 Lecturas Generadas**
   - 7 días completos (12 lecturas/día por sensor)
   - Última hora (1 lectura cada 5 minutos)
   - Patrones realistas según hora del día:
     - Día (6am-6pm): Luz alta, ruido moderado
     - Tarde-noche (7pm-11pm): Luz media, ruido variable
     - Madrugada (12am-5am): Luz baja, ruido bajo

3. **Alertas Automáticas**
   - 10-15% de lecturas generan alertas
   - Luz < 50 lux = Iluminación deficiente
   - Ruido > 80 dB = Ruido excesivo

4. **Queries de Verificación**
   - Contadores de nodos y lecturas
   - Estadísticas por sensor
   - Alertas de últimas 24 horas
   - Sensores sin lecturas recientes

## 🚀 Cómo Usar

### 1. Ejecutar SQL en Supabase
```sql
-- En SQL Editor de Supabase, ejecutar:
-- Primero: newTablasHacka2025 (crear tablas)
-- Luego: insertar_datos_sensores.sql (datos de prueba)
```

### 2. Probar la Aplicación Web
```bash
flutter run -d chrome
```

### 3. Flujo de Prueba
1. Login como admin: `admin@hacka.com` / `Admin2025!`
2. Ir a sección "Sensores"
3. Ver tarjetas de resumen actualizadas
4. Filtrar sensores por estado
5. Hacer clic en "Ver historial" de cualquier sensor
6. Probar agregar, editar y eliminar sensores
7. Cerrar sesión y volver a abrir: sesión se mantiene

### 4. Queries Útiles

**Ver sensores con alertas activas:**
```sql
SELECT n.nombre, l.lux, l.ruido, l.fecha
FROM public.lecturas l
JOIN public.nodos n ON l.nodo_id = n.id
WHERE (l.lux < 50 OR l.ruido > 80)
    AND l.fecha > NOW() - INTERVAL '1 hour'
ORDER BY l.fecha DESC;
```

**Ver estadísticas en tiempo real:**
```sql
SELECT 
    n.nombre,
    COUNT(l.identificacion) as lecturas_24h,
    ROUND(AVG(l.lux)::numeric, 2) as lux_promedio,
    ROUND(AVG(l.ruido)::numeric, 2) as ruido_promedio,
    MAX(l.fecha) as ultima_lectura
FROM public.nodos n
LEFT JOIN public.lecturas l ON n.id = l.nodo_id 
    AND l.fecha > NOW() - INTERVAL '24 hours'
WHERE n.activo = true
GROUP BY n.id, n.nombre;
```

## 📝 Notas Técnicas

### Umbral de Alertas
- **Luz Baja**: < 50 lux (inseguridad por mala iluminación)
- **Ruido Alto**: > 80 dB (contaminación acústica, posible disturbio)

### Estado del Sensor
- **Online**: Lectura en últimos 15 minutos, valores normales
- **Offline**: Sin lectura en últimos 15 minutos o sensor inactivo
- **Alerta**: Lectura reciente con valores críticos
- **Sin Datos**: Sensor sin ninguna lectura

### Batería (Simulada)
- Disminuye ~1% por hora de operación
- Se reinicia cada 100 horas
- Real: ESP32 reportaría voltaje de batería

## 🔄 Próximos Pasos

1. **Integrar ESP32 Real**: Endpoint API para recibir lecturas
2. **Notificaciones Push**: Alertar admins cuando haya alertas críticas
3. **Gráficas**: Mostrar tendencias de luz/ruido en el tiempo
4. **Mapa de Calor**: Visualizar sensores en flutter_map
5. **Exportar Reportes**: PDF/Excel con estadísticas

## 🎯 Funcionalidades Actuales

✅ CRUD completo de sensores  
✅ Visualización de datos reales  
✅ Filtrado y búsqueda  
✅ Historial de lecturas  
✅ Sistema de alertas  
✅ Estadísticas en tiempo real  
✅ Persistencia de sesión  
✅ Interfaz responsive  
✅ Manejo de errores  
✅ Feedback visual (SnackBars)  

---

**Todo funciona con datos reales desde Supabase. No hay datos de ejemplo hardcodeados.**
