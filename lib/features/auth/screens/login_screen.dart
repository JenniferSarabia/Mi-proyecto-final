// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../providers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _verPass = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    final ok =
        await auth.iniciarSesion(_correoCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(children: [
              const Icon(Icons.store, color: AppColors.primary, size: 64),
              const SizedBox(height: 8),
              Text(
                'URBA & FLOW',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge!
                    .copyWith(fontSize: 28),
              ),
              const Text(
                'Estilo callejero con actitud',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    Text(
                      'Iniciar sesión',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 24),
                    if (auth.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDEDED),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.danger.withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.danger, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(auth.error!,
                                  style: const TextStyle(
                                      color: AppColors.danger))),
                        ]),
                      ),
                    TextFormField(
                      controller: _correoCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined)),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: !_verPass,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_verPass
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(() => _verPass = !_verPass),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: auth.cargando
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _login,
                              child: const Text('Iniciar sesión'),
                            ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/registro'),
                      child: const Text('¿No tienes cuenta? Regístrate'),
                    ),
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Volver a la tienda'),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
