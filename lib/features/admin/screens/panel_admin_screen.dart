// lib/features/admin/screens/panel_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class PanelAdminScreen extends StatelessWidget {
  const PanelAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prodProv = context.watch<ProductProvider>();
    final orderProv = context.watch<OrderProvider>();

    return Scaffold(
      appBar: const UfAppBar(title: 'Panel de Control (Admin)'),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen Estadístico (Indicadores superiores)
            Text(
              'Resumen de Operaciones',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    titulo: 'Prendas Totales',
                    valor: '${prodProv.productos.length}',
                    icono: Icons.checkroom,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    titulo: 'Pedidos Recibidos',
                    valor: '${orderProv.pedidos.length}',
                    icono: Icons.shopping_bag,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Requerimiento CRUD 100%
            Text(
              'Módulos de Gestión Administrativa',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
              children: [
                _AdminModuleCard(
                  titulo: 'Inventario Ropa',
                  descripcion: 'CRUD de prendas individuales',
                  icono: Icons.inventory_2_outlined,
                  color: AppColors.primary,
                  onTap: () => context.push('/admin/productos/todos'),
                ),
                _AdminModuleCard(
                  titulo: 'Colecciones',
                  descripcion: 'Lanzamientos y temporadas',
                  icono: Icons.style_outlined,
                  color: AppColors.accent,
                  onTap: () => context.push('/admin/colecciones'),
                ),
                _AdminModuleCard(
                  titulo: 'Ofertas Flash',
                  descripcion: 'Promociones y descuentos',
                  icono: Icons.local_offer_outlined,
                  color: Colors.orange,
                  onTap: () => context.push('/admin/ofertas'),
                ),
                _AdminModuleCard(
                  titulo: 'Control Pedidos',
                  descripcion: 'Estatus y envíos de clientes',
                  icono: Icons.local_shipping_outlined,
                  color: AppColors.success,
                  onTap: () => context.push('/admin/pedidos'),
                ),
                _AdminModuleCard(
                  titulo: 'Usuarios y Staff',
                  descripcion: 'Control de accesos y roles',
                  icono: Icons.people_alt_outlined,
                  color: Colors.purple,
                  onTap: () => context.push('/admin/usuarios'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _MetricCard(
      {required this.titulo,
      required this.valor,
      required this.icono,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icono, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(valor,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminModuleCard extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;

  const _AdminModuleCard({
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icono, size: 34, color: color),
              const SizedBox(height: 12),
              Text(titulo,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87)),
              const SizedBox(height: 4),
              Text(descripcion,
                  style:
                      const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
