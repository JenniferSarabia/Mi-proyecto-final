// lib/features/admin/screens/admin_pedidos_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class AdminPedidosScreen extends StatefulWidget {
  const AdminPedidosScreen({super.key});

  @override
  State<AdminPedidosScreen> createState() => _AdminPedidosScreenState();
}

class _AdminPedidosScreenState extends State<AdminPedidosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().cargarTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();

    return Scaffold(
      appBar: const UfAppBar(title: 'Historial de Ventas'),
      body: orderProv.cargando
          ? const UfLoading()
          : orderProv.pedidos.isEmpty
              ? const UfEmptyState(
                  mensaje: 'No hay transacciones registradas',
                  icono: Icons.receipt_long)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orderProv.pedidos.length,
                  itemBuilder: (context, i) {
                    final p = orderProv.pedidos[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text('Folio: ${p.numeroSeguimiento}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Cliente: ${p.usuarioNombre}\nMétodo: ${p.formaPago.toUpperCase()}\nTotal: \$${p.total}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            p.estado.toUpperCase(),
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
