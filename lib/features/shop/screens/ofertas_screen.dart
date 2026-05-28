// lib/features/shop/screens/ofertas_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class OfertasScreen extends StatelessWidget {
  const OfertasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductProvider>();
    final enOferta =
        productos.productos.where((p) => productos.tieneOferta(p)).toList();

    return Scaffold(
      appBar: const UfAppBar(title: 'Ofertas Urba & Flow'),
      drawer: const AppDrawer(),
      body: productos.cargando
          ? const UfLoading()
          : enOferta.isEmpty
              ? const UfEmptyState(
                  mensaje: 'No hay ofertas activas en este momento',
                  icono: Icons.local_offer_outlined)
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: enOferta.length,
                  itemBuilder: (_, i) {
                    final p = enOferta[i];
                    return ProductCard(
                      producto: p,
                      precioFinal: productos.precioFinal(p),
                      tieneOferta: true,
                    );
                  },
                ),
    );
  }
}
