// lib/features/cart/screens/carrito_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        // Flecha forzada para regresar a la tienda
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: cart.items.isEmpty
          ? const UfEmptyState(
              mensaje: 'Tu carrito está vacío',
              icono: Icons.shopping_cart_outlined)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                final item = cart.items[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading:
                        const Icon(Icons.checkroom, color: AppColors.primary),
                    title: Text(item.nombreProducto),
                    subtitle: Text(
                        'Cantidad: ${item.cantidad} | Subtotal: \$${item.subtotal}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.danger),
                      onPressed: () => cart.removerItem(item.productoId),
                    ),
                  ),
                );
              },
            ),
      // Barra inferior con los botones de acción
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('\$${cart.total}',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.go('/tienda'),
                          child: const Text('Seguir Comprando'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success),
                          onPressed: () => context.push('/checkout'),
                          child: const Text('Avanzar al Pago'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
