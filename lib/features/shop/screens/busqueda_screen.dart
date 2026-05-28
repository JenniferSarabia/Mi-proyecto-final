// lib/features/shop/screens/busqueda_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class BusquedaScreen extends StatelessWidget {
  const BusquedaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Buscar ropa, estilo, color...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (v) => context.read<ProductProvider>().buscar(v),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: productos.cargando
          ? const UfLoading()
          : productos.productos.isEmpty
              ? const UfEmptyState(
                  mensaje: 'No encontramos prendas con ese nombre',
                  icono: Icons.search_off)
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: productos.productos.length,
                  itemBuilder: (_, i) {
                    final p = productos.productos[i];
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
