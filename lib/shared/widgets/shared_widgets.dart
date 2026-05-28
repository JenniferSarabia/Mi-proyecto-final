// lib/shared/widgets/shared_widgets.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../features/providers.dart';
import '../../models/models.dart';

// ─────────────────────────────────────────────
//  NAVEGACIÓN LATERAL (igual al nav Django)
// ─────────────────────────────────────────────
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    return Drawer(
      backgroundColor: AppColors.primary,
      child: Column(children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: AppColors.primaryLight),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.store, color: Colors.white, size: 42),
            const SizedBox(height: 8),
            Text(
              'URBA & FLOW',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.white, fontSize: 20, letterSpacing: 2),
            ),
            Text(
              'Estilo callejero con actitud',
              style: const TextStyle(color: Color(0xFFBBDEFB), fontSize: 12),
            ),
          ]),
        ),
        _NavItem(
            icon: Icons.home, label: 'Inicio', onTap: () => context.go('/')),
        _NavItem(
            icon: Icons.collections,
            label: 'Colecciones',
            onTap: () => context.go('/colecciones')),
        ExpansionTile(
          iconColor: Colors.white,
          collapsedIconColor: const Color(0xFF90CAF9),
          leading: const Icon(Icons.storefront, color: Color(0xFF90CAF9)),
          title: const Text('Tienda', style: TextStyle(color: Colors.white)),
          children: [
            _SubNavItem('Todos', () => context.go('/tienda')),
            _SubNavItem('Zapatos', () => context.go('/tienda?tipo=zapato')),
            _SubNavItem('Sudaderas', () => context.go('/tienda?tipo=blusa')),
            _SubNavItem(
                'Pantalones', () => context.go('/tienda?tipo=pantalon')),
            _SubNavItem(
                'Accesorios', () => context.go('/tienda?tipo=accesorio')),
          ],
        ),
        _NavItem(
            icon: Icons.local_offer,
            label: 'Ofertas',
            onTap: () => context.go('/ofertas')),
        _NavItem(
            icon: Icons.fiber_new,
            label: 'Novedades',
            onTap: () => context.go('/novedades')),
        const Divider(color: Color(0x40FFFFFF)),
        if (auth.autenticado) ...[
          _NavItem(
              icon: Icons.person,
              label: auth.usuario!.nombre,
              onTap: () => context.go('/perfil')),
          _NavItem(
              icon: Icons.receipt_long,
              label: 'Mis pedidos',
              onTap: () => context.go('/pedidos')),
          if (auth.esAdmin)
            _NavItem(
              icon: Icons.admin_panel_settings,
              label: 'Panel Admin',
              onTap: () => context.go('/admin'),
              highlight: true,
            ),
          _NavItem(
            icon: Icons.logout,
            label: 'Cerrar sesión',
            onTap: () async {
              await auth.cerrarSesion();
              if (context.mounted) context.go('/');
            },
          ),
        ] else ...[
          _NavItem(
              icon: Icons.login,
              label: 'Iniciar sesión',
              onTap: () => context.go('/login')),
          _NavItem(
              icon: Icons.person_add,
              label: 'Registrarse',
              onTap: () => context.go('/registro')),
        ],
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Ropa de hombre · Colección azul',
            style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ),
      ]),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;
  const _NavItem(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.highlight = false});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon,
            color:
                highlight ? const Color(0xFFFFD700) : const Color(0xFF90CAF9)),
        title: Text(label,
            style: TextStyle(
              color: highlight ? const Color(0xFFFFD700) : Colors.white,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.normal,
            )),
        onTap: () {
          Navigator.of(context).pop();
          onTap();
        },
        hoverColor: Colors.white10,
      );
}

class _SubNavItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SubNavItem(this.label, this.onTap);

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.only(left: 56),
        title: Text(label,
            style: const TextStyle(color: Color(0xFFBBDEFB), fontSize: 14)),
        onTap: () {
          Navigator.of(context).pop();
          onTap();
        },
      );
}

// ─────────────────────────────────────────────
//  APP BAR CON BÚSQUEDA Y CARRITO
// ─────────────────────────────────────────────
class UfAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  const UfAppBar({super.key, required this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => context.go('/buscar'),
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined),
              onPressed: () => context.go('/carrito'),
            ),
            if (cart.cantidadTotal > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${cart.cantidadTotal}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
        ...?actions,
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  TARJETA DE PRODUCTO
// ─────────────────────────────────────────────
class ProductCard extends StatelessWidget {
  final Producto producto;
  final double? precioFinal;
  final bool tieneOferta;
  const ProductCard({
    super.key,
    required this.producto,
    this.precioFinal,
    this.tieneOferta = false,
  });

  @override
  Widget build(BuildContext context) {
    final precio = precioFinal ?? producto.precio;
    final fmt = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () =>
            context.go('/producto/${producto.tipo.name}/${producto.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            AspectRatio(
              aspectRatio: 1,
              child: Stack(fit: StackFit.expand, children: [
                producto.imagenUrl != null
                    ? CachedNetworkImage(
                        imageUrl: producto.imagenUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppColors.surface),
                        errorWidget: (_, __, ___) =>
                            _PlaceholderImg(tipo: producto.tipo),
                      )
                    : _PlaceholderImg(tipo: producto.tipo),
                if (tieneOferta)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'OFERTA',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                if (producto.esDestacado)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'DESTACADO',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ]),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      producto.tipo.etiqueta,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(children: [
                      Text(
                        fmt.format(precio),
                        style: TextStyle(
                          color: tieneOferta
                              ? AppColors.danger
                              : AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (tieneOferta) ...[
                        const SizedBox(width: 6),
                        Text(
                          fmt.format(producto.precio),
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      'Stock: ${producto.stock}',
                      style: TextStyle(
                        color: producto.stock > 0
                            ? AppColors.success
                            : AppColors.danger,
                        fontSize: 12,
                      ),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImg extends StatelessWidget {
  final TipoProducto tipo;
  const _PlaceholderImg({required this.tipo});

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.surface,
        child: Center(
          child: Icon(
            switch (tipo) {
              TipoProducto.zapato => Icons.sports_gymnastics,
              TipoProducto.blusa => Icons.dry_cleaning,
              TipoProducto.pantalon => Icons.accessibility_new,
              TipoProducto.accesorio => Icons.watch,
            },
            color: AppColors.primaryLight,
            size: 48,
          ),
        ),
      );
}

// ─────────────────────────────────────────────
//  WIDGETS REUTILIZABLES
// ─────────────────────────────────────────────
class UfLoading extends StatelessWidget {
  const UfLoading({super.key});
  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
}

class UfEmptyState extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  const UfEmptyState(
      {super.key, required this.mensaje, this.icono = Icons.inbox});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icono, size: 64, color: AppColors.cardBorder),
          const SizedBox(height: 16),
          Text(mensaje,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 16)),
        ]),
      );
}

class UfErrorWidget extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onRetry;
  const UfErrorWidget({super.key, required this.mensaje, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
          const SizedBox(height: 12),
          Text(mensaje, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ]),
      );
}

class AdminListTile extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final Widget? leading;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  const AdminListTile({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.leading,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(
          onTap: onTap,
          leading: leading,
          title:
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: subtitulo != null ? Text(subtitulo!) : null,
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.accent, size: 20),
                onPressed: onEdit,
                tooltip: 'Editar',
              ),
            if (onDelete != null)
              IconButton(
                icon:
                    const Icon(Icons.delete, color: AppColors.danger, size: 20),
                onPressed: onDelete,
                tooltip: 'Eliminar',
              ),
          ]),
        ),
      );
}

// Confirmar eliminación
Future<bool?> confirmarEliminacion(BuildContext context, String descripcion) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirmar eliminación'),
      content: Text(
          '¿Estás seguro de eliminar $descripcion? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
}
