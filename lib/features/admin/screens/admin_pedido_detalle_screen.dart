// lib/features/admin/screens/admin_pedido_detalle_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class AdminPedidoDetalleScreen extends StatelessWidget {
  final String pedidoId;
  const AdminPedidoDetalleScreen({super.key, required this.pedidoId});

  // Función directa para actualizar el estado en Firebase
  void _cambiarEstado(BuildContext context, String nuevoEstado) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(pedidoId)
          .update({'estado': nuevoEstado});
      context.read<OrderProvider>().cargarTodos(); // Recarga la lista
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Estado actualizado a: $nuevoEstado'),
          backgroundColor: AppColors.success));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error al actualizar'),
          backgroundColor: AppColors.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final pedido = orderProv.pedidos.firstWhere((p) => p.id == pedidoId);

    return Scaffold(
      appBar: const UfAppBar(title: 'Detalle del Pedido'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Folio: ${pedido.numeroSeguimiento}',
                        style: Theme.of(context).textTheme.titleLarge),
                    const Divider(),
                    Text('Cliente: ${pedido.usuarioNombre}'),
                    Text('Dirección: ${pedido.direccionEnvio}'),
                    Text('Método de pago: ${pedido.formaPago}'),
                    Text('Estado actual: ${pedido.estado.toUpperCase()}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ]),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Acciones Rápidas (Cambiar Estatus):',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                  label: const Text('Pendiente'),
                  backgroundColor: Colors.grey.shade300,
                  onPressed: () => _cambiarEstado(context, 'pendiente')),
              ActionChip(
                  label: const Text('Enviado',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.blue,
                  onPressed: () => _cambiarEstado(context, 'enviado')),
              ActionChip(
                  label: const Text('Entregado',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: AppColors.success,
                  onPressed: () => _cambiarEstado(context, 'entregado')),
              ActionChip(
                  label: const Text('Cancelado',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: AppColors.danger,
                  onPressed: () => _cambiarEstado(context, 'cancelado')),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Artículos comprados:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...pedido.items.map((item) => ListTile(
                leading: const Icon(Icons.checkroom),
                title: Text(item.nombreProducto),
                subtitle: Text(
                    'Cantidad: ${item.cantidad} | Subtotal: \$${item.subtotal}'),
              )),
        ],
      ),
    );
  }
}
