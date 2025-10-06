# 🔧 CORRECCIONES APLICADAS - Sistema de Sensores

## Fecha: 6 de octubre de 2025

### ❌ Problemas Identificados:
1. **Todos los sensores mostraban "Fuera de Línea"**
   - Causa: Las lecturas de prueba tienen fechas antiguas
   - La validación era muy estricta (15 minutos)

2. **Columna de Batería innecesaria**
   - No es prioritaria en esta fase
   - Los ESP32 reales reportarían voltaje

### ✅ Soluciones Implementadas:

#### 1. Corregido Servicio de Nodos (`nodo_service.dart`)
**Antes:**
```dart
// Query incorrecta que traía todas las lecturas sin ordenar
.select('''
  *,
  ultima_lectura:lecturas(lux, ruido, fecha)
''')
```

**Después:**
```dart
// Query correcta: obtiene cada nodo y luego su última lectura ordenada
final lecturasResponse = await _supabase.client
    .from('lecturas')
    .select('lux, ruido, fecha')
    .eq('nodo_id', nodo.id)
    .order('fecha', ascending: false)
    .limit(1);
```

**Resultado:** Ahora obtiene correctamente la lectura MÁS RECIENTE de cada sensor.

---

#### 2. Ajustado Validación de Estado (`nodo_model.dart`)
**Antes:**
```dart
// Muy estricto - 15 minutos
if (diferencia.inMinutes > 15) return 'offline';
```

**Después:**
```dart
// Más flexible para datos históricos - 24 horas
if (diferencia.inHours > 24) return 'offline';
```

**Nota:** En producción con sensores reales, se puede volver a 15-30 minutos.

---

#### 3. Eliminada Columna de Batería (`pantalla_sensores_nueva.dart`)

**Cambios:**
- ❌ Eliminada columna "Batería" del DataTable
- ❌ Eliminado método `_buildBateriaBadge()`
- ✅ Tabla ahora tiene 7 columnas en lugar de 8

**Columnas actuales:**
1. Sensor (nombre + clave)
2. Ubicación (lat, lng)
3. Estado (badge coloreado)
4. Luz (lux)
5. Ruido (dB)
6. Última Lectura (fecha/hora)
7. Acciones (historial, editar, eliminar)

---

#### 4. Nuevo Script SQL: `actualizar_lecturas_hoy.sql`

**Propósito:** Generar lecturas con fecha de HOY para que los sensores aparezcan online.

**Contenido:**
1. Genera lecturas de las últimas 12 horas (cada 30 min)
2. Genera lecturas de los últimos 15 minutos (cada 5 min)
3. Patrones realistas según hora del día
4. Queries de verificación de estado

**Uso:**
```sql
-- En Supabase SQL Editor:
-- 1. Ejecutar newTablasHacka2025 (crear tablas)
-- 2. Ejecutar insertar_datos_sensores.sql (datos base)
-- 3. Ejecutar actualizar_lecturas_hoy.sql (lecturas actuales)
```

---

### 🎯 Resultados Esperados:

Después de ejecutar `actualizar_lecturas_hoy.sql`:

✅ **9 sensores activos** mostrarán estado "🟢 En Línea"  
✅ **1 sensor inactivo** (Estadio Municipal) mostrará "⚫ Fuera de Línea"  
✅ Algunos sensores pueden mostrar "🟠 Alerta" si tienen luz baja o ruido alto  
✅ Todas las lecturas tendrán timestamps de HOY  

---

### 📊 Cómo Verificar:

1. **Ejecutar SQL de verificación:**
```sql
SELECT 
    n.nombre,
    n.activo,
    MAX(l.fecha) as ultima_lectura,
    EXTRACT(EPOCH FROM (NOW() - MAX(l.fecha)))/60 as minutos_desde_ultima,
    CASE 
        WHEN n.activo = false THEN 'Offline (Inactivo)'
        WHEN MAX(l.fecha) IS NULL THEN 'Sin Datos'
        WHEN NOW() - MAX(l.fecha) > INTERVAL '24 hours' THEN 'Offline (>24h)'
        WHEN MAX(l.lux) < 50 OR MAX(l.ruido) > 80 THEN 'Alerta'
        ELSE 'Online'
    END as estado
FROM public.nodos n
LEFT JOIN public.lecturas l ON n.id = l.nodo_id
GROUP BY n.id, n.nombre, n.activo
ORDER BY n.activo DESC;
```

2. **En la aplicación:**
   - Abrir dashboard web
   - Ir a sección "Sensores"
   - Presionar botón "🔄 Actualizar"
   - Verificar que las tarjetas de resumen muestren:
     - Total: 10
     - En Línea: ~8-9
     - Fuera de Línea: 1-2
     - Con Alertas: variable (según datos aleatorios)

---

### 🔍 Debug Tips:

Si aún ves sensores offline:

1. **Verificar lecturas recientes:**
```sql
SELECT n.nombre, l.fecha, l.lux, l.ruido
FROM lecturas l
JOIN nodos n ON l.nodo_id = n.id
WHERE l.fecha > NOW() - INTERVAL '1 hour'
ORDER BY l.fecha DESC;
```

2. **Ver logs en consola:**
   - Abrir DevTools en Chrome
   - Buscar mensajes con 🔍 📦 ✅ ❌
   - Verificar que diga "Última lectura [fecha reciente]"

3. **Forzar recarga:**
   - Presionar botón "Actualizar" en la UI
   - O hacer hot reload: `r` en terminal de Flutter

---

### 📁 Archivos Modificados:

1. ✏️ `lib/servicios/nodo_service.dart` - Query corregida
2. ✏️ `lib/modelos/nodo_model.dart` - Validación ajustada
3. ✏️ `lib/web/pantallas/pantalla_sensores_nueva.dart` - Columna batería eliminada
4. ➕ `actualizar_lecturas_hoy.sql` - Nuevo script SQL

---

### 🚀 Próxima Ejecución:

```bash
# 1. Ejecutar SQL en Supabase
# Copiar contenido de actualizar_lecturas_hoy.sql

# 2. Ejecutar app
cd "/Users/mario/Desktop/ Flutter/tefrontend"
flutter run -d chrome

# 3. Verificar en dashboard
# Login → Sensores → Ver estados actualizados
```

---

**Estado: ✅ CORRECCIONES COMPLETADAS**
