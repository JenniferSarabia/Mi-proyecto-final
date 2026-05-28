// lib/features/admin/screens/admin_ofertas_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class AdminOfertasScreen extends StatelessWidget {
  const AdminOfertasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ofProv = context.watch<OfertaProvider>();

    return Scaffold(
      appBar: const UfAppBar(title: 'Gestión de Ofertas'),
      body: ofProv.cargando
          ? const UfLoading()
          : ofProv.ofertas.isEmpty
              ? const UfEmptyState(
                  mensaje: 'No hay ofertas activas', icono: Icons.local_offer)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ofProv.ofertas.length,
                  itemBuilder: (context, i) {
                    final o = ofProv.ofertas[i];
                    return AdminListTile(
                      titulo:
                          'Oferta: \$${o.precioNuevo} (Antes \$${o.precioAnterior})',
                      subtitulo:
                          'Activa hasta: ${o.fechaFin.day}/${o.fechaFin.month}/${o.fechaFin.year}',
                      leading:
                          const Icon(Icons.money_off, color: Colors.orange),
                      onEdit: () =>
                          context.push('/admin/ofertas/${o.id}/editar'),
                      onDelete: () => ofProv.eliminar(o.id!),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Nueva Oferta', style: TextStyle(color: Colors.white)),
        onPressed: () => context.push('/admin/ofertas/nueva'),
      ),
    );
  }
}
