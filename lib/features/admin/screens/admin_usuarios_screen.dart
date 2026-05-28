// lib/features/admin/screens/admin_usuarios_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserAdminProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserAdminProvider>();

    return Scaffold(
      appBar: const UfAppBar(title: 'Gestión de Clientes y Staff'),
      body: userProv.cargando
          ? const UfLoading()
          : userProv.usuarios.isEmpty
              ? const UfEmptyState(
                  mensaje: 'No hay usuarios registrados', icono: Icons.people)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: userProv.usuarios.length,
                  itemBuilder: (context, i) {
                    final u = userProv.usuarios[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: u.esStaff
                              ? Colors.purple
                              : AppColors.primaryLight,
                          child: Icon(
                              u.esStaff
                                  ? Icons.admin_panel_settings
                                  : Icons.person,
                              color: Colors.white),
                        ),
                        title: Text(u.nombre,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(u.correo),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_red_eye,
                              color: AppColors.primary),
                          onPressed: () =>
                              context.push('/admin/usuarios/${u.uid}/detalle'),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Nuevo Staff', style: TextStyle(color: Colors.white)),
        onPressed: () => context.push('/admin/usuarios/nuevo'),
      ),
    );
  }
}
