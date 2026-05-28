// lib/features/admin/screens/admin_usuario_form_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';
import '../../../services/firebase_services.dart';

class AdminUsuarioFormScreen extends StatefulWidget {
  final String? usuarioId;
  const AdminUsuarioFormScreen({super.key, this.usuarioId});

  @override
  State<AdminUsuarioFormScreen> createState() => _AdminUsuarioFormScreenState();
}

class _AdminUsuarioFormScreenState extends State<AdminUsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _esStaff = true; // Por defecto creamos admins aquí
  bool _cargando = false;

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _cargando = true);
      try {
        await UserService().crear(
          nombre: _nombreCtrl.text,
          correo: _correoCtrl.text,
          password: _passCtrl.text,
          esStaff: _esStaff,
        );

        // Recargar la lista para que aparezca
        if (mounted) context.read<UserAdminProvider>().cargar();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Usuario Staff creado con éxito'),
              backgroundColor: AppColors.success));
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Error al crear usuario (Revisa que el correo no exista)'),
              backgroundColor: AppColors.danger));
        }
      } finally {
        if (mounted) setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UfAppBar(title: 'Crear Cuenta de Acceso'),
      body: _cargando
          ? const UfLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                        'Usa este formulario para crear cuentas de empleados o administradores que tendrán acceso a este panel.',
                        style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 24),
                    TextFormField(
                        controller: _nombreCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Nombre Completo'),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _correoCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Correo Electrónico'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.contains('@') ? null : 'Inválido'),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _passCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Contraseña temporal'),
                        obscureText: true,
                        validator: (v) =>
                            v!.length < 6 ? 'Mínimo 6 caracteres' : null),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('¿Es Administrador (Staff)?',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle:
                          const Text('Tendrá acceso total al panel de control'),
                      activeColor: Colors.purple,
                      value: _esStaff,
                      onChanged: (v) => setState(() => _esStaff = v),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple),
                            onPressed: _guardar,
                            child: const Text('Crear Cuenta de Staff')))
                  ],
                ),
              ),
            ),
    );
  }
}
