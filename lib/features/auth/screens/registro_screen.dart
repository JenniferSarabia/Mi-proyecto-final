// lib/features/auth/screens/registro_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../providers.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _cargando = false;

  void _registrar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _cargando = true);
      final auth = context.read<AuthProvider>();

      try {
        await auth.registrar(
            _nombreCtrl.text, _correoCtrl.text, _passCtrl.text);

        // Al registrarse en Firebase, la sesión se inicia sola.
        // Cerramos sesión para obligarlo a ir al Login como pediste.
        await auth.cerrarSesion();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('¡Cuenta creada! Por favor inicia sesión',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: AppColors.success));
          context.go('/login'); // <-- Redirige al Login
        }
      } catch (e) {
        // SI HAY ERROR, LO ATRAPAMOS AQUÍ Y NO TE SACA DE LA PANTALLA
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: No se pudo registrar. Verifica tus datos.',
                  style: const TextStyle(color: Colors.white)),
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
      appBar: AppBar(
          title:
              const Text('Crear Cuenta', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person_add,
                    size: 80, color: AppColors.primary),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nombre Completo',
                      prefixIcon: Icon(Icons.person)),
                  validator: (v) => v!.isEmpty ? 'Ingresa tu nombre' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _correoCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: Icon(Icons.email)),
                  validator: (v) => v!.contains('@') ? null : 'Correo inválido',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                  validator: (v) =>
                      v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 32),
                _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _registrar,
                        child: const Text('Registrarme',
                            style: TextStyle(fontSize: 16)),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('¿Ya tienes cuenta? Inicia Sesión'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
