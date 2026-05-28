// lib/features/admin/screens/admin_producto_form_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../models/models.dart';
import '../../providers.dart';
import '../../../services/firebase_services.dart';

class AdminProductoFormScreen extends StatefulWidget {
  final String tipo;
  final String? productoId;
  const AdminProductoFormScreen(
      {super.key, required this.tipo, this.productoId});

  @override
  State<AdminProductoFormScreen> createState() =>
      _AdminProductoFormScreenState();
}

class _AdminProductoFormScreenState extends State<AdminProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _imagenUrlCtrl = TextEditingController(); // NUEVO: Para la imagen
  TipoProducto _tipoSeleccionado = TipoProducto.zapato;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    if (widget.productoId != null && widget.productoId != 'nuevo') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final prov = context.read<ProductProvider>();
        final p =
            prov.productos.firstWhere((prod) => prod.id == widget.productoId);
        setState(() {
          _nombreCtrl.text = p.nombre;
          _descCtrl.text = p.descripcion;
          _precioCtrl.text = p.precio.toString();
          _stockCtrl.text = p.stock.toString();
          _imagenUrlCtrl.text = p.imagenUrl ?? ''; // Cargar URL
          _tipoSeleccionado = p.tipo;
        });
      });
    }
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _cargando = true);

      final nuevoProducto = Producto(
        id: widget.productoId != 'nuevo' ? widget.productoId : null,
        nombre: _nombreCtrl.text,
        descripcion: _descCtrl.text,
        precio: double.parse(_precioCtrl.text),
        stock: int.parse(_stockCtrl.text),
        imagenUrl: _imagenUrlCtrl.text.isEmpty
            ? null
            : _imagenUrlCtrl.text, // Guardar URL
        tipo: _tipoSeleccionado,
        fechaAgregado: DateTime.now(),
      );

      try {
        if (widget.productoId != null && widget.productoId != 'nuevo') {
          await ProductService().actualizar(nuevoProducto);
        } else {
          await ProductService().crear(nuevoProducto);
        }
        await context.read<ProductProvider>().cargar();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Guardado exitosamente'),
              backgroundColor: AppColors.success));
          context.pop();
        }
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Error al guardar'),
              backgroundColor: AppColors.danger));
      } finally {
        if (mounted) setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.productoId != 'nuevo' ? 'Editar Prenda' : 'Añadir Prenda',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop()),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                        controller: _nombreCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Nombre de la prenda'),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _descCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Descripción'),
                        maxLines: 2),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: TextFormField(
                              controller: _precioCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Precio', prefixText: '\$'),
                              keyboardType: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: TextFormField(
                              controller: _stockCtrl,
                              decoration:
                                  const InputDecoration(labelText: 'Stock'),
                              keyboardType: TextInputType.number)),
                    ]),
                    const SizedBox(height: 16),
                    // NUEVO: CAMPO DE IMAGEN
                    TextFormField(
                      controller: _imagenUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Link de la Imagen (URL)',
                        hintText: 'Ej: https://misitio.com/foto.jpg',
                        prefixIcon: Icon(Icons.image),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TipoProducto>(
                      value: _tipoSeleccionado,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: TipoProducto.values
                          .map((t) => DropdownMenuItem(
                              value: t, child: Text(t.etiqueta)))
                          .toList(),
                      onChanged: (v) => setState(() => _tipoSeleccionado = v!),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: _guardar,
                            child: const Text('Guardar Prenda')))
                  ],
                ),
              ),
            ),
    );
  }
}
