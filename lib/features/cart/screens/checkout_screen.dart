// lib/features/cart/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../providers.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _dirCtrl = TextEditingController();
  String _pago = 'tarjeta'; // Valor por defecto
  bool _procesando = false;

  void _procesar() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();

    if (_dirCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ingresa una dirección de envío'),
          backgroundColor: AppColors.danger));
      return;
    }

    setState(() => _procesando = true);

    try {
      final pedido = await orders.hacer(
        usuario: auth.usuario!,
        cart: cart,
        formaPago: _pago, // 'tarjeta' o 'efectivo'
        direccion: _dirCtrl.text,
      );

      if (pedido != null && mounted) {
        context.go('/confirmacion/${pedido.id}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error al procesar pago'),
          backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.items.isEmpty)
      return const Scaffold(body: Center(child: Text('Carrito vacío')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar Compra',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop()),
      ),
      body: _procesando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('1. Dirección de Envío',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                    controller: _dirCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Calle, Número, Colonia, C.P.',
                        border: OutlineBorder())),
                const SizedBox(height: 32),
                const Text('2. Método de Pago',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      RadioListTile(
                        title: const Text('Tarjeta de Crédito / Débito'),
                        subtitle: const Text('Pago seguro y automático'),
                        secondary: const Icon(Icons.credit_card,
                            color: AppColors.primary),
                        value: 'tarjeta',
                        groupValue: _pago,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _pago = v.toString()),
                      ),
                      const Divider(height: 1),
                      RadioListTile(
                        title: const Text('Efectivo en OXXO'),
                        subtitle: const Text('Paga en tu sucursal más cercana'),
                        secondary:
                            const Icon(Icons.money, color: AppColors.success),
                        value: 'efectivo',
                        groupValue: _pago,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _pago = v.toString()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _procesar,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary),
                  child: Text('Confirmar y Pagar \$${cart.total}',
                      style:
                          const TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
    );
  }
}
