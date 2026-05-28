// lib/features/auth/screens/perfil_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../../core/theme.dart';
import '../../providers.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.usuario;

    if (user == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: const UfAppBar(title: 'Mi Perfil'),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, size: 60, color: Colors.white)),
          const SizedBox(height: 16),
          Text(user.nombre,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium),
          Text(user.correo,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 32),
          Card(
            child: Column(children: [
              ListTile(
                  leading: const Icon(Icons.local_shipping,
                      color: AppColors.primary),
                  title: const Text('Historial de Pedidos'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.go('/pedidos')),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.danger),
                title: const Text('Cerrar Sesión',
                    style: TextStyle(
                        color: AppColors.danger, fontWeight: FontWeight.bold)),
                onTap: () {
                  auth.cerrarSesion();
                  context.go('/');
                },
              ),
            ]),
          )
        ],
      ),
    );
  }
}
