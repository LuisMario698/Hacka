import 'package:flutter/material.dart';
import '../../servicios/usuario_service.dart';
import '../../servicios/supabase_service.dart';

class DialogoAgregarUsuario extends StatefulWidget {
  @override
  _DialogoAgregarUsuarioState createState() => _DialogoAgregarUsuarioState();
}

class _DialogoAgregarUsuarioState extends State<DialogoAgregarUsuario> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  int _rolSeleccionado = 1; // 1 = usuario por defecto
  bool _cargando = false;
  bool _mostrarPassword = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      // 1. Crear usuario en Supabase Auth (SIN confirmación de email)
      final authResponse = await SupabaseService.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'nombre': _nombreController.text.trim(),
          'rol_id': _rolSeleccionado,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Error al crear usuario en autenticación');
      }

      // 2. Crear usuario en tabla usuarios
      await UsuarioService.crearUsuario(
        id: authResponse.user!.id,
        email: _emailController.text.trim(),
        nombre: _nombreController.text.trim(),
        rolId: _rolSeleccionado,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Usuario creado exitosamente'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Error al crear usuario: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blue.shade700],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.person_add, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Text(
            'Nuevo Usuario',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Container(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El email es requerido';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_mostrarPassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _mostrarPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _mostrarPassword = !_mostrarPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    helperText: 'Mínimo 6 caracteres',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La contraseña es requerida';
                    }
                    if (value.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Rol
                DropdownButtonFormField<int>(
                  value: _rolSeleccionado,
                  decoration: InputDecoration(
                    labelText: 'Rol',
                    prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 20, color: Colors.blue),
                          SizedBox(width: 12),
                          Text('Usuario'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Row(
                        children: [
                          Icon(Icons.shield, size: 20, color: Colors.orange),
                          SizedBox(width: 12),
                          Text('Moderador'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings, size: 20, color: Colors.purple),
                          SizedBox(width: 12),
                          Text('Administrador'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (valor) {
                    setState(() {
                      _rolSeleccionado = valor!;
                    });
                  },
                ),
                SizedBox(height: 16),
                
                // Info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'El usuario recibirá un email de confirmación.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cargando ? null : () => Navigator.pop(context, false),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _cargando ? null : _crearUsuario,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _cargando
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Crear Usuario'),
        ),
      ],
    );
  }
}
