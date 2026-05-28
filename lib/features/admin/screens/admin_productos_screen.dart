// lib/features/admin/screens/admin_productos_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class AdminProductosScreen extends StatelessWidget {
  final String tipo;
  const AdminProductosScreen({super.key, required this.tipo});

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductProvider>();

    return Scaffold(
      appBar: const UfAppBar(title: 'Gestión de Inventario'),
      body: productos.cargando
          ? const UfLoading()
          : ListView.builder(
              itemCount: productos.productos.length,
              itemBuilder: (context, i) {
                final p = productos.productos[i];
                return AdminListTile(
                  titulo: p.nombre,
                  subtitulo: 'Stock: ${p.stock} | Precio: \$${p.precio}',
                  leading:
                      const Icon(Icons.checkroom, color: AppColors.primary),
                  onEdit: () => context.push(
                      '/admin/productos/${p.tipo.name}/${p.id}/editar'), // <-- CAMBIADO A PUSH
                  onDelete: () async {
                    final confirmar =
                        await confirmarEliminacion(context, p.nombre);
                    if (confirmar == true) {
                      await productos.eliminarProducto(p.id!);
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Nueva Prenda', style: TextStyle(color: Colors.white)),
        onPressed: () =>
            context.push('/admin/productos/nuevo/nuevo'), // <-- CAMBIADO A PUSH
      ),
    );
  }
}
