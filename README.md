# 🛡️ Rutas Seguras - Sistema Integral de Seguridad Ciudadana

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Supabase](https://img.shields.io/badge/Supabase-Database-3ECF8E?logo=supabase)
![License](https://img.shields.io/badge/License-MIT-green.svg)

> **Proyecto Hacka 2025** - Sistema de navegación inteligente que utiliza red de sensores IoT (luz y sonido) para calcular rutas más seguras en tiempo real.

## 📋 Tabla de Contenidos

- [Características Principales](#-características-principales)
- [Arquitectura del Sistema](#-arquitectura-del-sistema)
- [Usuario Final (App Móvil)](#-usuario-final-app-móvil)
- [Administrador (Dashboard Web)](#-administrador-dashboard-web)
- [Ideas Premium](#-ideas-premium-futuras)
- [Instalación](#-instalación)
- [Configuración](#-configuración)

---

## 🌟 Características Principales

### Para Usuarios
- 🗺️ **Navegación Inteligente**: Rutas optimizadas por seguridad en tiempo real
- 🚨 **Botón de Pánico**: SOS con notificación instantánea a contactos
- 📊 **Datos en Vivo**: Visualización de sensores IoT (luz/sonido)
- 👥 **Comunidad Activa**: Sistema de reportes colaborativo
- 🔔 **Alertas Personalizadas**: Notificaciones de zonas peligrosas

### Para Administradores
- 📡 **Gestión de Sensores**: Monitoreo 24/7 de red IoT
- 🚨 **Centro de Reportes**: Gestión y resolución de incidentes
- 📈 **Analítica Avanzada**: Dashboards con métricas en tiempo real
- 👥 **Control de Usuarios**: Sistema de roles y permisos
- 🤖 **IA Predictiva**: Detección de patrones y zonas de riesgo

---

## 🏗️ Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                         USUARIOS                             │
│  📱 App Móvil (Flutter)    💻 Dashboard Web (Flutter Web)   │
└────────────────┬────────────────────────┬───────────────────┘
                 │                        │
                 ▼                        ▼
┌─────────────────────────────────────────────────────────────┐
│                    🔐 SUPABASE BACKEND                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ PostgreSQL   │  │ Auth & RLS   │  │ Real-time    │     │
│  │ Database     │  │ Security     │  │ Subscriptions│     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└────────────────┬───────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                    📡 RED DE SENSORES IoT                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ ESP32 #1 │  │ ESP32 #2 │  │ ESP32 #3 │  │ ESP32 #N │   │
│  │ 💡 Luz    │  │ 💡 Luz    │  │ 💡 Luz    │  │ 💡 Luz    │   │
│  │ 🔊 Sonido │  │ 🔊 Sonido │  │ 🔊 Sonido │  │ 🔊 Sonido │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 📱 USUARIO FINAL (App Móvil)

### 🗺️ Navegación y Rutas

1. **Ver mapa interactivo** con zonas seguras/inseguras coloreadas
2. **Calcular ruta más segura** entre dos puntos (evita zonas oscuras/ruidosas)
3. **Navegar en tiempo real** con indicaciones GPS
4. **Ver nodos/sensores cercanos** y su estado actual (luz verde/amarilla/roja)
5. **Guardar rutas favoritas** (casa-trabajo, casa-universidad)
6. **Compartir ubicación en tiempo real** con contactos de confianza
7. **Modo nocturno especial** que prioriza zonas iluminadas

### 🚨 Seguridad y Reportes

8. **Botón de pánico/SOS** que notifica a contactos de emergencia
9. **Crear reportes de incidentes:**
   - 🚶 Acoso callejero
   - 🔦 Falta de iluminación
   - 👥 Actividad sospechosa
   - 🚧 Infraestructura dañada
   - 📸 Con foto/video como evidencia
10. **Ver reportes cercanos** de otros usuarios (últimas 24hrs)
11. **Recibir alertas** de zonas peligrosas en tu ruta
12. **Calificar zonas** después de pasar por ellas (¿te sentiste seguro?)

### 📊 Historial y Estadísticas

13. **Ver historial de rutas** tomadas
14. **Estadísticas personales:**
    - Distancia recorrida por rutas seguras
    - Tiempo ahorrado
    - Incidentes evitados
15. **Insignias/logros** (gamificación): "100km seguros", "Reportero activo"

### 👤 Perfil y Comunidad

16. **Agregar contactos de confianza** para compartir ubicación
17. **Modo grupo** para caminar con amigos (ver ubicación mutua)
18. **Configurar horarios de uso** (la app aprende tus rutinas)
19. **Personalizar tipos de alertas** que quieres recibir
20. **Ver ranking de usuarios** más colaborativos (reportes útiles)

### 🔔 Notificaciones Inteligentes

21. **Alertas de zona peligrosa** al acercarte
22. **Recordatorios** si sales de casa en horario habitual
23. **Sugerencias de rutas** basadas en tus rutinas
24. **Avisos de sensores caídos** en tu ruta habitual

---

## 💻 ADMINISTRADOR (Dashboard Web)

### 🎛️ Panel Principal

1. **Dashboard en tiempo real** con métricas clave:
   - 📊 Total de usuarios activos ahora
   - 🚨 Reportes sin resolver
   - 📡 Sensores online/offline
   - 🗺️ Mapa de calor de actividad

2. **Gráficos de tendencias:**
   - Reportes por hora/día/semana
   - Zonas más transitadas
   - Horarios de mayor actividad

### 📡 Gestión de Sensores/Nodos

3. **Ver todos los nodos** en mapa con estado:
   - 🟢 Verde: Funcionando bien (luz alta, ruido bajo)
   - 🟡 Amarillo: Precaución (luz media o ruido medio)
   - 🔴 Rojo: Peligroso (sin luz o ruido alto)
   - ⚫ Gris: Offline/sin datos

4. **Agregar nuevos nodos** (coordenadas, device_key)
5. **Editar/eliminar nodos** existentes
6. **Ver historial de lecturas** por nodo (gráficos de sonido/luz)
7. **Configurar umbrales** de alerta (ej: luz < 30% = zona oscura)
8. **Diagnosticar problemas** de sensores (última conexión, batería)
9. **Exportar datos** de sensores a CSV/Excel

### 🚨 Gestión de Reportes

10. **Ver todos los reportes** con filtros:
    - Por estado: nuevo, en proceso, resuelto
    - Por tipo: acoso, iluminación, infraestructura
    - Por fecha y ubicación

11. **Cambiar estado** de reportes (marcar como resuelto)
12. **Asignar reportes** a responsables/departamentos
13. **Ver evidencias** (fotos/videos subidas)
14. **Responder a usuarios** que reportaron
15. **Generar reportes automáticos** para autoridades
16. **Identificar zonas críticas** con más reportes
17. **Programar inspecciones** basadas en reportes

### 👥 Gestión de Usuarios

18. **Ver todos los usuarios** registrados
19. **Activar/desactivar usuarios** (control de acceso)
20. **Asignar roles:**
    - 👤 Usuario normal
    - 👮 Moderador (puede gestionar reportes)
    - 👑 Admin (acceso completo)

21. **Ver actividad de usuarios:**
    - Rutas tomadas
    - Reportes creados
    - Nivel de colaboración

22. **Banear usuarios** que crean reportes falsos
23. **Enviar notificaciones masivas** a usuarios

### 📈 Analítica Avanzada

24. **Mapa de calor de seguridad** (zonas rojas/verdes)
25. **Análisis predictivo:**
    - Horarios más peligrosos
    - Zonas que necesitan más sensores
    - Patrones de incidentes

26. **Comparar períodos** (este mes vs mes anterior)
27. **Reportes automáticos PDF** para autoridades
28. **Exportar datos** para investigaciones
29. **Dashboard de impacto social:**
    - Personas que usan rutas seguras
    - Incidentes reducidos
    - Cobertura de sensores

### ⚙️ Configuración del Sistema

30. **Configurar parámetros generales:**
    - Radio de búsqueda de sensores
    - Tiempo de actualización de datos
    - Umbrales de peligro (sonido/luz)

31. **Gestionar API keys** de servicios externos
32. **Configurar integraciones:**
    - Enviar alertas a policía
    - Integrar con 911/emergencias
    - Conectar con alumbrado público municipal

33. **Backup y restauración** de base de datos
34. **Ver logs del sistema** (errores, accesos)
35. **Gestionar permisos** por módulo

### 🔔 Alertas y Monitoreo

36. **Recibir alertas en tiempo real:**
    - Sensor caído
    - Zona muy peligrosa detectada
    - Múltiples reportes en misma zona

37. **Configurar reglas de alerta** automáticas
38. **Panel de monitoreo 24/7** para operadores

### 🤝 Colaboración con Autoridades

39. **Crear cuentas para policía/municipio** (acceso limitado)
40. **Compartir datos** con entidades oficiales
41. **Generar informes oficiales** con estadísticas
42. **Solicitar intervención** en zonas críticas

---

## 🎯 IDEAS PREMIUM (Futuras)

### Para Usuarios:
- 💳 **Suscripción Premium:**
  - Rutas sin anuncios
  - Historial ilimitado
  - Alertas prioritarias
  - Análisis personal detallado

### Para Admins:
- 🤖 **IA/Machine Learning:**
  - Predecir zonas peligrosas
  - Detectar anomalías automáticamente
  - Optimizar ubicación de nuevos sensores
- 📞 **Integración con servicios de emergencia**
- 🌍 **Multi-ciudad** (expandir a otras ciudades)

---

## 🚀 Instalación

### Prerequisitos

```bash
Flutter SDK: >=3.0.0
Dart SDK: >=3.0.0
Supabase Account
ESP32 con MicroPython (para sensores IoT)
```

### Pasos de Instalación

```bash
# 1. Clonar el repositorio
git clone https://github.com/LuisMario698/Hacka.git
cd tefrontend

# 2. Instalar dependencias
flutter pub get

# 3. Configurar Supabase
# Crea un archivo .env con tus credenciales:
SUPABASE_URL=tu_url_de_supabase
SUPABASE_ANON_KEY=tu_anon_key

# 4. Ejecutar migraciones de base de datos
# Ve a Supabase SQL Editor y ejecuta los archivos:
# - backup_tablas_supabase.sql
# - migracion_completa_desde_cero.sql

# 5. Ejecutar la app
flutter run                    # Para móvil
flutter run -d chrome         # Para web
```

---

## ⚙️ Configuración

### Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_anon_key_aqui
GOOGLE_MAPS_API_KEY=tu_api_key_de_google_maps
```

### Configuración de ESP32

```python
# Ejemplo de código MicroPython para ESP32
import urequests
import time
from machine import Pin, ADC

# Configuración
SUPABASE_URL = "https://tu-proyecto.supabase.co"
SUPABASE_KEY = "tu_service_role_key"
DEVICE_KEY = "esp32_001"

# Sensores
sensor_luz = ADC(Pin(34))
sensor_sonido = ADC(Pin(35))

while True:
    lux = sensor_luz.read()
    ruido = sensor_sonido.read()
    
    # Enviar a Supabase
    data = {
        "device_key": DEVICE_KEY,
        "lux": lux,
        "ruido": ruido
    }
    
    urequests.post(
        f"{SUPABASE_URL}/rest/v1/lecturas",
        json=data,
        headers={"apikey": SUPABASE_KEY}
    )
    
    time.sleep(300)  # Cada 5 minutos
```

---

## 📂 Estructura del Proyecto

```
tefrontend/
├── lib/
│   ├── main.dart                 # Punto de entrada
│   ├── móvil/                    # App móvil
│   │   ├── main_movil.dart
│   │   ├── pantallas/
│   │   ├── componentes/
│   │   ├── servicios/
│   │   └── modelos/
│   ├── web/                      # Dashboard web
│   │   ├── main_web.dart
│   │   ├── pantallas/
│   │   ├── componentes/
│   │   ├── servicios/
│   │   └── modelos/
│   ├── servicios/                # Servicios compartidos
│   │   ├── supabase_service.dart
│   │   ├── usuario_service.dart
│   │   ├── reporte_service.dart
│   │   └── theme_service.dart
│   └── modelos/                  # Modelos compartidos
│       ├── usuario.dart
│       ├── nodo.dart
│       ├── lectura_sensor.dart
│       └── reporte.dart
├── assets/
│   └── images/
├── scripts/                      # Scripts SQL y utilidades
│   ├── backup_tablas_supabase.sql
│   └── migracion_completa_desde_cero.sql
└── pubspec.yaml
```

---

## 🛠️ Tecnologías Utilizadas

| Tecnología | Propósito |
|------------|-----------|
| **Flutter** | Framework multiplataforma |
| **Supabase** | Backend as a Service (PostgreSQL + Auth) |
| **ESP32 + MicroPython** | Sensores IoT |
| **Google Maps API** | Mapas y navegación |
| **GetX** | State management y routing |
| **Dio** | Cliente HTTP |

---

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

---

## 👥 Equipo

- **Mario** - Developer - [@Yisus-uwu2](https://github.com/Yisus-uwu2)
- **Luis Mario** - Developer - [@LuisMario698](https://github.com/LuisMario698)

---

## 📞 Contacto

¿Preguntas o sugerencias? Contáctanos:

- 📧 Email: proyecto@rutasseguras.com
- 🐦 Twitter: [@RutasSeguras](https://twitter.com/rutasseguras)
- 💬 Discord: [Únete a nuestro servidor](https://discord.gg/rutasseguras)

---

## ⭐ Agradecimientos

- Hacka 2025 por la oportunidad
- Comunidad de Flutter y Supabase
- Todos los colaboradores y testers

---

**¡Gracias por usar Rutas Seguras! Juntos hacemos ciudades más seguras. 🛡️**
