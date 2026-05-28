// lib/features/admin/screens/admin_coleccion_form_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../models/models.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class AdminColeccionFormScreen extends StatefulWidget {
  final String? coleccionId;
  const AdminColeccionFormScreen({super.key, this.coleccionId});

  @override
  State<AdminColeccionFormScreen> createState() =>
      _AdminColeccionFormScreenState();
}

class _AdminColeccionFormScreenState extends State<AdminColeccionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _temporadaCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    if (widget.coleccionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final prov = context.read<ColeccionProvider>();
        final c =
            prov.colecciones.firstWhere((col) => col.id == widget.coleccionId);
        setState(() {
          _nombreCtrl.text = c.nombre;
          _descCtrl.text = c.descripcion;
          _temporadaCtrl.text = c.temporada;
          _precioCtrl.text = c.precio.toString();
        });
      });
    }
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _cargando = true);
      final prov = context.read<ColeccionProvider>();

      final coleccion = Coleccion(
        id: widget.coleccionId,
        nombre: _nombreCtrl.text,
        descripcion: _descCtrl.text,
        temporada: _temporadaCtrl.text,
        fechaLanzamiento: DateTime.now(),
        estado: 'activo',
        stock: 100, // Por defecto
        precio: double.parse(_precioCtrl.text),
      );

      final exito = widget.coleccionId == null
          ? await prov.crear(coleccion)
          : await prov.actualizar(coleccion);

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Colección guardada',
                style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.success));
        context.pop();
      } else if (mounted) {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Error al guardar', style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.danger));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UfAppBar(
          title: widget.coleccionId == null
              ? 'Nueva Colección'
              : 'Editar Colección'),
      body: _cargando
          ? const UfLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                        controller: _nombreCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Nombre de Colección'),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _descCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Descripción'),
                        maxLines: 3,
                        validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: TextFormField(
                              controller: _temporadaCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Temporada (Ej. Verano 26)'),
                              validator: (v) =>
                                  v!.isEmpty ? 'Requerido' : null)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: TextFormField(
                              controller: _precioCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Precio Base \$'),
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  v!.isEmpty ? 'Requerido' : null)),
                    ]),
                    const SizedBox(height: 32),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: _guardar,
                            child: const Text('Guardar Colección')))
                  ],
                ),
              ),
            ),
    );
  }
}
