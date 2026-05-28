// lib/features/shop/screens/colecciones_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';

class ColeccionesScreen extends StatelessWidget {
  final String? coleccionId;
  const ColeccionesScreen({super.key, this.coleccionId});

  @override
  Widget build(BuildContext context) {
    final colProvider = context.watch<ColeccionProvider>();

    return Scaffold(
      appBar: const UfAppBar(title: 'Colecciones Exclusivas'),
      drawer: const AppDrawer(),
      body: colProvider.cargando
          ? const UfLoading()
          : colProvider.colecciones.isEmpty
              ? const UfEmptyState(
                  mensaje: 'Aún no hay colecciones disponibles',
                  icono: Icons.collections)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: colProvider.colecciones.length,
                  itemBuilder: (ctx, i) {
                    final c = colProvider.colecciones[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 150,
                            color: AppColors.primaryLight,
                            child: const Center(
                                child: Icon(Icons.style,
                                    size: 64, color: Colors.white)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.nombre,
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                Text(c.descripcion,
                                    style: const TextStyle(
                                        color: AppColors.textMuted)),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
