// lib/features/admin/screens/admin_colecciones_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class AdminColeccionesScreen extends StatelessWidget {
  const AdminColeccionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colProv = context.watch<ColeccionProvider>();

    return Scaffold(
      appBar: const UfAppBar(title: 'Gestión de Colecciones'),
      body: colProv.cargando
          ? const UfLoading()
          : colProv.colecciones.isEmpty
              ? const UfEmptyState(
                  mensaje: 'No se han creado colecciones de temporada',
                  icono: Icons.style_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: colProv.colecciones.length,
                  itemBuilder: (context, i) {
                    final c = colProv.colecciones[i];
                    return AdminListTile(
                      titulo: c.nombre,
                      subtitulo:
                          'Temporada: ${c.temporada} | Precio base: \$${c.precio}',
                      leading: const Icon(Icons.auto_awesome,
                          color: AppColors.accent),
                      onEdit: () =>
                          context.push('/admin/colecciones/${c.id}/editar'),
                      onDelete: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Operación de borrado restringida por seguridad')));
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nueva Colección',
            style: TextStyle(color: Colors.white)),
        onPressed: () => context.push('/admin/colecciones/nueva'),
      ),
    );
  }
}
