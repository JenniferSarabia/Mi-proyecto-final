// lib/features/shop/screens/inicio_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductProvider>();
    return Scaffold(
      appBar: UfAppBar(title: 'URBA & FLOW'),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Hero banner azul
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'ESTILO\nCALLEJERO\nCON ACTITUD',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge!
                    .copyWith(color: Colors.white, height: 1.1, fontSize: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ropa urbana de hombre · Colección azul',
                style: TextStyle(color: Color(0xFFBBDEFB), fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/tienda'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                ),
                child: const Text('Ver colección',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
          // Categorías rápidas
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Categorías',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _CatChip('Zapatos', Icons.sports_gymnastics,
                        () => context.go('/tienda?tipo=zapato')),
                    _CatChip('Sudaderas', Icons.dry_cleaning,
                        () => context.go('/tienda?tipo=blusa')),
                    _CatChip('Pantalones', Icons.accessibility_new,
                        () => context.go('/tienda?tipo=pantalon')),
                    _CatChip('Accesorios', Icons.watch,
                        () => context.go('/tienda?tipo=accesorio')),
                  ],
                ),
              ),
            ]),
          ),
          // Destacados
          if (productos.cargando)
            const Padding(padding: EdgeInsets.all(32), child: UfLoading())
          else if (productos.destacados.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Destacados',
                        style: Theme.of(context).textTheme.headlineMedium),
                    TextButton(
                        onPressed: () => context.go('/tienda'),
                        child: const Text('Ver todos')),
                  ]),
            ),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: productos.destacados.length,
                itemBuilder: (_, i) {
                  final p = productos.destacados[i];
                  return SizedBox(
                    width: 180,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: ProductCard(
                        producto: p,
                        precioFinal: productos.precioFinal(p),
                        tieneOferta: productos.tieneOferta(p),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          // Novedades rápidas
          if (productos.productos.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Novedades',
                        style: Theme.of(context).textTheme.headlineMedium),
                    TextButton(
                        onPressed: () => context.go('/novedades'),
                        child: const Text('Ver más')),
                  ]),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: productos.productos.take(8).length,
              itemBuilder: (_, i) {
                final p = productos.productos[i];
                return ProductCard(
                  producto: p,
                  precioFinal: productos.precioFinal(p),
                  tieneOferta: productos.tieneOferta(p),
                );
              },
            ),
          ],
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _CatChip(this.label, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 10),
        child: ActionChip(
          avatar: Icon(icon, color: AppColors.primary, size: 18),
          label: Text(label,
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.cardBorder),
          onPressed: onTap,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
}
