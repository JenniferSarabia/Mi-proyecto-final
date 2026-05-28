// lib/features/admin/screens/admin_oferta_form_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../models/models.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class AdminOfertaFormScreen extends StatefulWidget {
  final String? ofertaId;
  const AdminOfertaFormScreen({super.key, this.ofertaId});

  @override
  State<AdminOfertaFormScreen> createState() => _AdminOfertaFormScreenState();
}

class _AdminOfertaFormScreenState extends State<AdminOfertaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productoIdCtrl = TextEditingController();
  final _precioAnteriorCtrl = TextEditingController();
  final _precioNuevoCtrl = TextEditingController();
  bool _cargando = false;

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _cargando = true);
      final prov = context.read<OfertaProvider>();

      final oferta = Oferta(
        id: widget.ofertaId,
        productoId: _productoIdCtrl.text,
        tipoProducto: TipoProducto.blusa,
        precioAnterior: double.parse(_precioAnteriorCtrl.text),
        precioNuevo: double.parse(_precioNuevoCtrl.text),
        fechaInicio: DateTime.now(),
        fechaFin: DateTime.now()
            .add(const Duration(days: 7)), // Dura 7 días por defecto
      );

      final exito = widget.ofertaId == null
          ? await prov.crear(oferta)
          : await prov.actualizar(oferta);

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Oferta guardada'),
            backgroundColor: AppColors.success));
        context.pop();
      }
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UfAppBar(
          title: widget.ofertaId == null ? 'Crear Oferta' : 'Editar Oferta'),
      body: _cargando
          ? const UfLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                        controller: _productoIdCtrl,
                        decoration: const InputDecoration(
                            labelText: 'ID del Producto (Cópialo de Firebase)'),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: TextFormField(
                              controller: _precioAnteriorCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Precio Original \$'),
                              keyboardType: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: TextFormField(
                              controller: _precioNuevoCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Precio Rebajado \$'),
                              keyboardType: TextInputType.number)),
                    ]),
                    const SizedBox(height: 32),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange),
                            onPressed: _guardar,
                            child: const Text('Guardar Oferta')))
                  ],
                ),
              ),
            ),
    );
  }
}
