// lib/features/shop/screens/producto_detalle_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../models/models.dart';
import '../../../services/firebase_services.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class ProductoDetalleScreen extends StatefulWidget {
  final String tipo, id;
  const ProductoDetalleScreen(
      {super.key, required this.tipo, required this.id});
  @override
  State<ProductoDetalleScreen> createState() => _State();
}

class _State extends State<ProductoDetalleScreen> {
  Producto? _p;
  bool _cargando = true;
  int _cantidad = 1;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    _p = await ProductService().obtenerPorId(widget.id);
    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductProvider>();
    final auth = context.watch<AuthProvider>();
    final cart = context.read<CartProvider>();
    final fmt = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    if (_cargando) return const Scaffold(body: UfLoading());
    if (_p == null)
      return const Scaffold(
          body: UfEmptyState(mensaje: 'Producto no encontrado'));

    final p = _p!;
    final precio = productos.precioFinal(p);
    final oferta = productos.ofertaDe(p);

    return Scaffold(
      appBar: UfAppBar(title: p.nombre),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Imagen
          AspectRatio(
            aspectRatio: 1.2,
            child: p.imagenUrl != null
                ? CachedNetworkImage(imageUrl: p.imagenUrl!, fit: BoxFit.cover)
                : Container(
                    color: AppColors.surface,
                    child: const Center(
                        child: Icon(Icons.dry_cleaning,
                            size: 80, color: AppColors.primaryLight)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Badges
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(p.tipo.etiqueta,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
                if (p.esDestacado) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(4)),
                    child: const Text('DESTACADO',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
                if (oferta != null && oferta.estaActiva) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text('OFERTA -${oferta.diasRestantes}d',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ]),
              const SizedBox(height: 12),
              Text(p.nombre, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              // Precio
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                  fmt.format(precio),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color:
                        oferta != null ? AppColors.danger : AppColors.primary,
                  ),
                ),
                if (oferta != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    fmt.format(p.precio),
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textMuted,
                      fontSize: 16,
                    ),
                  ),
                ],
              ]),
              const SizedBox(height: 4),
              Text(
                'Stock disponible: ${p.stock}',
                style: TextStyle(
                    color: p.stock > 0 ? AppColors.success : AppColors.danger,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Text(p.descripcion,
                  style: const TextStyle(
                      color: AppColors.textMuted, height: 1.6, fontSize: 15)),
              if (p.marca != null) ...[
                const SizedBox(height: 8),
                Text('Marca: ${p.marca}',
                    style: const TextStyle(color: AppColors.textMuted)),
              ],
              if (p.categoria != null) ...[
                const SizedBox(height: 4),
                Text('Categoría: ${p.categoria}',
                    style: const TextStyle(color: AppColors.textMuted)),
              ],
              if (oferta != null && oferta.mensaje.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.local_offer, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(oferta.mensaje,
                            style: const TextStyle(color: AppColors.textDark))),
                  ]),
                ),
              ],
              const SizedBox(height: 24),
              // Cantidad
              Row(children: [
                const Text('Cantidad:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                IconButton(
                  onPressed:
                      _cantidad > 1 ? () => setState(() => _cantidad--) : null,
                  icon: const Icon(Icons.remove_circle_outline,
                      color: AppColors.primary),
                ),
                Text('$_cantidad',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                IconButton(
                  onPressed: _cantidad < p.stock
                      ? () => setState(() => _cantidad++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppColors.primary),
                ),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: p.stock <= 0
                      ? null
                      : () {
                          if (!auth.autenticado) {
                            context.go('/login');
                            return;
                          }
                          for (int i = 0; i < _cantidad; i++) {
                            cart.agregar(p, precio);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${p.nombre} agregado al carrito'),
                              backgroundColor: AppColors.success,
                              action: SnackBarAction(
                                  label: 'Ver carrito',
                                  textColor: Colors.white,
                                  onPressed: () => context.go('/carrito')),
                            ),
                          );
                        },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label:
                      Text(p.stock <= 0 ? 'Sin stock' : 'Agregar al carrito'),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
