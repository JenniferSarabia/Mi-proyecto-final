// lib/features/cart/screens/confirmacion_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class ConfirmacionScreen extends StatelessWidget {
  final String pedidoId;
  const ConfirmacionScreen({super.key, required this.pedidoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.success, size: 100),
              const SizedBox(height: 24),
              Text('¡Compra Exitosa!',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge!
                      .copyWith(fontSize: 28)),
              const SizedBox(height: 8),
              const Text('Tu estilo está en camino.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12)),
                child: SelectableText('Folio de pedido:\n$pedidoId',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Volver a la tienda')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
