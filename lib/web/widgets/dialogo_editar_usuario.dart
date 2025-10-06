import 'package:flutter/material.dart';
import '../../servicios/usuario_service.dart';
import '../../modelos/usuario.dart';

class DialogoEditarUsuario extends StatefulWidget {
  final Usuario usuario;

  const DialogoEditarUsuario({Key? key, required this.usuario}) : super(key: key);

  @override
  _DialogoEditarUsuarioState createState() => _DialogoEditarUsuarioState();
}

class _DialogoEditarUsuarioState extends State<DialogoEditarUsuario> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late int _rolSeleccionado;
  late bool _estaActivo;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuario.nombre);
    _emailController = TextEditingController(text: widget.usuario.email);
    _rolSeleccionado = widget.usuario.rolId;
    _estaActivo = widget.usuario.estaActivo;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      await UsuarioService.actualizarUsuario(
        widget.usuario.id,
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        rolId: _rolSeleccionado,
        estaActivo: _estaActivo,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Usuario actualizado exitosamente'),
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
                Expanded(child: Text('Error al actualizar: $e')),
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
                colors: [Colors.orange, Colors.orange.shade700],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.edit, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Text(
            'Editar Usuario',
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
                // ID (no editable)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.fingerprint, size: 20, color: Colors.grey[600]),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID de Usuario',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              widget.usuario.id,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[800],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                
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
                
                // Estado
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _estaActivo ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _estaActivo ? Colors.green.shade200 : Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _estaActivo ? Icons.check_circle : Icons.cancel,
                        color: _estaActivo ? Colors.green : Colors.red,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estado de la cuenta',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _estaActivo
                                  ? 'El usuario puede acceder al sistema'
                                  : 'El usuario no puede acceder al sistema',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _estaActivo,
                        activeColor: Colors.green,
                        onChanged: (valor) {
                          setState(() {
                            _estaActivo = valor;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                
                // Info de creación
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
                          'Creado: ${_formatearFecha(widget.usuario.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
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
          onPressed: _cargando ? null : _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
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
              : Text('Guardar Cambios'),
        ),
      ],
    );
  }

  String _formatearFecha(DateTime fecha) {
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}, ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}
