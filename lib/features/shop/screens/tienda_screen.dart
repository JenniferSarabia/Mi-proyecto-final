// lib/features/shop/screens/tienda_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../models/models.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class TiendaScreen extends StatefulWidget {
  const TiendaScreen({super.key});
  @override
  State<TiendaScreen> createState() => _TiendaScreenState();
}

class _TiendaScreenState extends State<TiendaScreen> {
  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductProvider>();

    return Scaffold(
      appBar: UfAppBar(title: 'Tienda'),
      drawer: const AppDrawer(),
      body: Column(children: [
        // Filtros
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              _FiltroChip('Todos', null, productos.filtroTipo,
                  productos.filtrarPorTipo),
              for (final tipo in TipoProducto.values)
                _FiltroChip(tipo.etiqueta, tipo, productos.filtroTipo,
                    productos.filtrarPorTipo),
            ]),
          ),
        ),
        // Grid
        Expanded(
          child: productos.cargando
              ? const UfLoading()
              : productos.productos.isEmpty
                  ? const UfEmptyState(
                      mensaje: 'No hay productos disponibles',
                      icono: Icons.inventory_2_outlined)
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
        ),
      ]),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final TipoProducto? tipo;
  final TipoProducto? seleccionado;
  final void Function(TipoProducto?) onTap;
  const _FiltroChip(this.label, this.tipo, this.seleccionado, this.onTap);

  @override
  Widget build(BuildContext context) {
    final activo = tipo == seleccionado;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: activo,
        onSelected: (_) => onTap(tipo),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: activo ? Colors.white : AppColors.textDark,
          fontWeight: activo ? FontWeight.w600 : FontWeight.normal,
        ),
        checkmarkColor: Colors.white,
        side: BorderSide(
            color: activo ? AppColors.primary : AppColors.cardBorder),
      ),
    );
  }
}
