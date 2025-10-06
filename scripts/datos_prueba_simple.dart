import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script simple para llenar datos de prueba directamente en Supabase
/// Ejecutar con: dart scripts/datos_prueba_simple.dart
void main() async {
  print('🚀 Llenando base de datos con datos de prueba...');

  try {
    // Cargar variables de entorno
    await dotenv.load(fileName: '.env');
    
    // Inicializar Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    
    final supabase = Supabase.instance.client;
    print('✅ Conectado a Supabase');

    // 1. Crear usuarios de prueba
    print('👥 Creando usuarios...');
    await crearUsuarios(supabase);
    
    // 2. Crear reportes de prueba
    print('📍 Creando reportes...');
    await crearReportes(supabase);
    
    // 3. Crear rutas de historial
    print('🛣️  Creando rutas...');
    await crearRutas(supabase);
    
    print('');
    print('🎉 ¡Base de datos llena exitosamente!');
    print('');
    print('📊 Datos creados:');
    print('✅ 5 usuarios de prueba');
    print('✅ 15 reportes en Puerto Peñasco');
    print('✅ 8 rutas de historial');
    print('');
    print('🔐 Puedes usar estas credenciales:');
    print('📧 admin@test.com | 🔑 password123');
    print('📧 user1@test.com | 🔑 password123');
    
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}

Future<void> crearUsuarios(SupabaseClient supabase) async {
  final usuarios = [
    {
      'email': 'admin@test.com',
      'nombre': 'Administrador Sistema',
      'telefono': '+52 638 123 4567',
      'rol': 'administrador'
    },
    {
      'email': 'user1@test.com', 
      'nombre': 'María González',
      'telefono': '+52 638 234 5678',
      'rol': 'usuario'
    },
    {
      'email': 'user2@test.com',
      'nombre': 'Juan Pérez', 
      'telefono': '+52 638 345 6789',
      'rol': 'usuario'
    },
    {
      'email': 'user3@test.com',
      'nombre': 'Ana Rodríguez',
      'telefono': '+52 638 456 7890', 
      'rol': 'usuario'
    },
    {
      'email': 'user4@test.com',
      'nombre': 'Carlos López',
      'telefono': '+52 638 567 8901',
      'rol': 'usuario'
    }
  ];

  for (final user in usuarios) {
    try {
      // Registrar en Auth
      final authResponse = await supabase.auth.signUp(
        email: user['email']!,
        password: 'password123',
      );
      
      if (authResponse.user != null) {
        // Insertar en tabla usuarios
        await supabase.from('usuarios').insert({
          'id': authResponse.user!.id,
          'email': user['email'],
          'nombre': user['nombre'],
          'telefono': user['telefono'],
          'rol': user['rol'],
        });
        print('✅ ${user['email']}');
      }
    } catch (e) {
      if (e.toString().contains('already')) {
        print('⚠️  ${user['email']} (ya existe)');
      } else {
        print('❌ ${user['email']}: $e');
      }
    }
  }
}

Future<void> crearReportes(SupabaseClient supabase) async {
  // Autenticarse con admin para crear reportes
  try {
    await supabase.auth.signInWithPassword(
      email: 'admin@test.com',
      password: 'password123',
    );
  } catch (e) {
    print('⚠️  No se pudo autenticar, intentando crear reportes sin auth...');
  }

  final reportes = [
    {
      'titulo': 'Foco fundido en Av. Constitución',
      'descripcion': 'El alumbrado público no funciona desde hace 3 días',
      'lat': 31.3180,
      'lon': -113.5340
    },
    {
      'titulo': 'Actividad sospechosa cerca del mercado', 
      'descripcion': 'Personas merodeando vehículos durante la madrugada',
      'lat': 31.3150,
      'lon': -113.5380
    },
    {
      'titulo': 'Asalto en Calle Benito Juárez',
      'descripcion': 'Asalto a peatón cerca de tienda OXXO a las 9:30 PM',
      'lat': 31.3200,
      'lon': -113.5320
    },
    {
      'titulo': 'Banqueta dañada en Boulevard Costero',
      'descripcion': 'Banqueta con hoyos, peligroso para peatones',
      'lat': 31.3140,
      'lon': -113.5400
    },
    {
      'titulo': 'Robo de vehículo en zona hotelera',
      'descripcion': 'Vehículo sustraído del estacionamiento hotel',
      'lat': 31.3220,
      'lon': -113.5300
    },
    {
      'titulo': 'Alumbrado deficiente en Av. Libertad',
      'descripcion': 'Varios focos sin funcionar, área muy oscura',
      'lat': 31.3160,
      'lon': -113.5360
    },
    {
      'titulo': 'Personas sospechosas en área residencial',
      'descripcion': 'Individuos revisando casas y vehículos',
      'lat': 31.3190,
      'lon': -113.5330
    },
    {
      'titulo': 'Intento de asalto en zona comercial',
      'descripcion': 'Intento de robo a comerciante, logró escapar',
      'lat': 31.3170,
      'lon': -113.5350
    },
    {
      'titulo': 'Calle sin iluminación completa',
      'descripcion': 'Toda una cuadra sin alumbrado público',
      'lat': 31.3130,
      'lon': -113.5390
    },
    {
      'titulo': 'Vehículo sospechoso rondando escuela',
      'descripcion': 'Auto desconocido en zona escolar',
      'lat': 31.3210,
      'lon': -113.5310
    },
    {
      'titulo': 'Robo a casa habitación',
      'descripcion': 'Sustracción durante ausencia de propietarios',
      'lat': 31.3120,
      'lon': -113.5370
    },
    {
      'titulo': 'Semáforo descompuesto en crucero',
      'descripcion': 'Semáforo intermitente genera caos vial',
      'lat': 31.3185,
      'lon': -113.5345
    },
    {
      'titulo': 'Grupo sospechoso en parque público',
      'descripcion': 'Personas intimidando a familias',
      'lat': 31.3175,
      'lon': -113.5355
    },
    {
      'titulo': 'Asalto a turista en malecón',
      'descripcion': 'Turista despojado de pertenencias',
      'lat': 31.3195,
      'lon': -113.5325
    },
    {
      'titulo': 'Poste de luz caído por viento',
      'descripcion': 'Poste derribado bloquea vía',
      'lat': 31.3155,
      'lon': -113.5365
    }
  ];

  for (final reporte in reportes) {
    try {
      await supabase.from('reportes').insert({
        'usuario_id': supabase.auth.currentUser?.id,
        'titulo': reporte['titulo'],
        'descripcion': reporte['descripcion'],
        'lat': reporte['lat'],
        'lon': reporte['lon'],
        'estado': 'nuevo',
      });
      print('✅ ${reporte['titulo']}');
    } catch (e) {
      print('❌ ${reporte['titulo']}: $e');
    }
  }
}

Future<void> crearRutas(SupabaseClient supabase) async {
  final rutas = [
    {
      'origen': 'Centro Puerto Peñasco',
      'destino': 'Zona Hotelera',
      'origen_lat': 31.3167,
      'origen_lon': -113.5361,
      'destino_lat': 31.3200,
      'destino_lon': -113.5300,
      'distancia_km': 4.2,
      'tiempo_minutos': 12
    },
    {
      'origen': 'Mercado Municipal', 
      'destino': 'Playa Bonita',
      'origen_lat': 31.3150,
      'origen_lon': -113.5380,
      'destino_lat': 31.3220,
      'destino_lon': -113.5280,
      'distancia_km': 6.8,
      'tiempo_minutos': 18
    },
    {
      'origen': 'OXXO Constitución',
      'destino': 'Hospital General', 
      'origen_lat': 31.3180,
      'origen_lon': -113.5340,
      'destino_lat': 31.3160,
      'destino_lon': -113.5360,
      'distancia_km': 2.1,
      'tiempo_minutos': 7
    },
    {
      'origen': 'Escuela Primaria',
      'destino': 'Plaza Comercial',
      'origen_lat': 31.3210,
      'origen_lon': -113.5310,
      'destino_lat': 31.3190,
      'destino_lon': -113.5330,
      'distancia_km': 3.5,
      'tiempo_minutos': 10
    },
    {
      'origen': 'Gasolinera PEMEX',
      'destino': 'Restaurante El Capitán',
      'origen_lat': 31.3140,
      'origen_lon': -113.5400,
      'destino_lat': 31.3170,
      'destino_lon': -113.5350,
      'distancia_km': 1.8,
      'tiempo_minutos': 5
    },
    {
      'origen': 'Banco Santander',
      'destino': 'Farmacia Guadalajara',
      'origen_lat': 31.3175,
      'origen_lon': -113.5355,
      'destino_lat': 31.3185,
      'destino_lon': -113.5345,
      'distancia_km': 2.9,
      'tiempo_minutos': 8
    },
    {
      'origen': 'Casa Usuario',
      'destino': 'Trabajo Centro',
      'origen_lat': 31.3130,
      'origen_lon': -113.5390,
      'destino_lat': 31.3167,
      'destino_lon': -113.5361,
      'distancia_km': 5.1,
      'tiempo_minutos': 15
    },
    {
      'origen': 'Supermercado Ley',
      'destino': 'Casa Familiar',
      'origen_lat': 31.3195,
      'origen_lon': -113.5325,
      'destino_lat': 31.3155,
      'destino_lon': -113.5365,
      'distancia_km': 3.2,
      'tiempo_minutos': 9
    }
  ];

  for (final ruta in rutas) {
    try {
      await supabase.from('rutas_historial').insert({
        'usuario_id': supabase.auth.currentUser?.id,
        'origen': ruta['origen'],
        'destino': ruta['destino'],
        'origen_lat': ruta['origen_lat'],
        'origen_lon': ruta['origen_lon'],
        'destino_lat': ruta['destino_lat'],
        'destino_lon': ruta['destino_lon'],
        'distancia_km': ruta['distancia_km'],
        'tiempo_minutos': ruta['tiempo_minutos'],
      });
      print('✅ ${ruta['origen']} → ${ruta['destino']}');
    } catch (e) {
      print('❌ ${ruta['origen']}: $e');
    }
  }
}