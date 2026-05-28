// lib/features/shop/screens/novedades_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class NovedadesScreen extends StatelessWidget {
  const NovedadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductProvider>();

    // Mostramos solo los últimos 10 agregados
    final novedades = productos.productos.take(10).toList();

    return Scaffold(
      appBar: const UfAppBar(title: 'Lo Más Nuevo'),
      drawer: const AppDrawer(),
      body: productos.cargando
          ? const UfLoading()
          : novedades.isEmpty
              ? const UfEmptyState(
                  mensaje: 'Aún no hay prendas nuevas', icono: Icons.fiber_new)
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: novedades.length,
                  itemBuilder: (_, i) {
                    final p = novedades[i];
                    return ProductCard(
                      producto: p,
                      precioFinal: productos.precioFinal(p),
                      tieneOferta: productos.tieneOferta(p),
                    );
                  },
                ),
    );
  }
}
