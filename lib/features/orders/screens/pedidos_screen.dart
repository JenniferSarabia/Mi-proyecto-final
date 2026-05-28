// lib/features/orders/screens/pedidos_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../../core/theme.dart';
import '../../providers.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});
  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.usuario != null) {
        // Obligamos a recargar la lista de pedidos al abrir la pantalla
        context.read<OrderProvider>().cargarMios(auth.usuario!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop()),
      ),
      body: orders.cargando
          ? const Center(child: CircularProgressIndicator())
          : orders.pedidos.isEmpty
              ? const UfEmptyState(
                  mensaje: 'Aún no tienes pedidos', icono: Icons.receipt_long)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.pedidos.length,
                  itemBuilder: (ctx, i) {
                    final p = orders.pedidos[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text('Folio: ${p.numeroSeguimiento}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${p.creado.day}/${p.creado.month}/${p.creado.year}\nTotal: \$${p.total}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(p.estado.toUpperCase(),
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
