import 'package:flutter/material.dart';
import '../servicios/supabase_service.dart';
import '../servicios/usuario_service.dart';
import '../servicios/reporte_service.dart';
import '../servicios/ruta_historial_service.dart';

/// Pantalla de prueba para verificar la conexión con Supabase
class PantallaPruebaSupabase extends StatefulWidget {
  @override
  _PantallaPruebaSupabaseState createState() => _PantallaPruebaSupabaseState();
}

class _PantallaPruebaSupabaseState extends State<PantallaPruebaSupabase> {
  String _resultado = 'Presiona los botones para probar la conexión';
  bool _cargando = false;

  Future<void> _probarConexion() async {
    setState(() {
      _cargando = true;
      _resultado = 'Probando conexión...';
    });

    try {
      final conexionExitosa = await SupabaseService.instance.testConnection();
      setState(() {
        _resultado = conexionExitosa 
            ? '✅ Conexión exitosa a Supabase!'
            : '❌ Error de conexión a Supabase';
      });
    } catch (e) {
      setState(() {
        _resultado = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _probarRegistro() async {
    setState(() {
      _cargando = true;
      _resultado = 'Probando registro...';
    });

    try {
      final response = await SupabaseService.instance.signUp(
        email: 'prueba${DateTime.now().millisecondsSinceEpoch}@test.com',
        password: 'password123',
        nombre: 'Usuario Prueba',
      );

      setState(() {
        _resultado = '✅ Registro exitoso: ${response.user?.email}';
      });
    } catch (e) {
      setState(() {
        _resultado = '❌ Error en registro: ${SupabaseService.instance.handleSupabaseError(e)}';
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _probarLogin() async {
    setState(() {
      _cargando = true;
      _resultado = 'Probando login...';
    });

    try {
      final response = await SupabaseService.instance.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      setState(() {
        _resultado = '✅ Login exitoso: ${response.user?.email}';
      });
    } catch (e) {
      setState(() {
        _resultado = '❌ Error en login: ${SupabaseService.instance.handleSupabaseError(e)}';
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _probarUsuarios() async {
    setState(() {
      _cargando = true;
      _resultado = 'Obteniendo usuarios...';
    });

    try {
      final usuarios = await UsuarioService.obtenerUsuarios();
      setState(() {
        _resultado = '✅ ${usuarios.length} usuarios encontrados:\n' +
            usuarios.take(3).map((u) => '- ${u.email} (${u.nombre ?? 'Sin nombre'})').join('\n');
      });
    } catch (e) {
      setState(() {
        _resultado = '❌ Error obteniendo usuarios: $e';
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _probarReportes() async {
    setState(() {
      _cargando = true;
      _resultado = 'Obteniendo reportes...';
    });

    try {
      final reportes = await ReporteService.obtenerReportes(limite: 5);
      setState(() {
        _resultado = '✅ ${reportes.length} reportes encontrados:\n' +
            reportes.map((r) => '- ${r.titulo} (${r.estado.displayName})').join('\n');
      });
    } catch (e) {
      setState(() {
        _resultado = '❌ Error obteniendo reportes: $e';
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _probarEstadisticas() async {
    setState(() {
      _cargando = true;
      _resultado = 'Obteniendo estadísticas...';
    });

    try {
      final estadisticasUsuarios = await UsuarioService.obtenerEstadisticasUsuarios();
      final estadisticasReportes = await ReporteService.obtenerEstadisticasReportes();

      setState(() {
        _resultado = '✅ Estadísticas:\n' +
            'Usuarios: ${estadisticasUsuarios['total']} total, ${estadisticasUsuarios['activos']} activos\n' +
            'Reportes: ${estadisticasReportes['total']} total, ${estadisticasReportes['esta_semana']} esta semana';
      });
    } catch (e) {
      setState(() {
        _resultado = '❌ Error obteniendo estadísticas: $e';
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prueba Supabase'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado de la conexión:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Usuario actual: ${SupabaseService.instance.currentUser?.email ?? 'No autenticado'}',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Autenticado: ${SupabaseService.instance.isAuthenticated ? 'Sí' : 'No'}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _cargando ? null : _probarConexion,
                  child: Text('Probar Conexión'),
                ),
                ElevatedButton(
                  onPressed: _cargando ? null : _probarRegistro,
                  child: Text('Probar Registro'),
                ),
                ElevatedButton(
                  onPressed: _cargando ? null : _probarLogin,
                  child: Text('Probar Login'),
                ),
                ElevatedButton(
                  onPressed: _cargando ? null : _probarUsuarios,
                  child: Text('Obtener Usuarios'),
                ),
                ElevatedButton(
                  onPressed: _cargando ? null : _probarReportes,
                  child: Text('Obtener Reportes'),
                ),
                ElevatedButton(
                  onPressed: _cargando ? null : _probarEstadisticas,
                  child: Text('Estadísticas'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Resultado:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_cargando) ...[
                            SizedBox(width: 8),
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _resultado,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (SupabaseService.instance.isAuthenticated)
              ElevatedButton(
                onPressed: () async {
                  try {
                    await SupabaseService.instance.signOut();
                    setState(() {
                      _resultado = '✅ Sesión cerrada exitosamente';
                    });
                  } catch (e) {
                    setState(() {
                      _resultado = '❌ Error cerrando sesión: $e';
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Cerrar Sesión'),
              ),
          ],
        ),
      ),
    );
  }
}