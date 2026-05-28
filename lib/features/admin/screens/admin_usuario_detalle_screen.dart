// lib/features/admin/screens/admin_usuario_detalle_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../providers.dart';
import '../../../services/firebase_services.dart';

class AdminUsuarioDetalleScreen extends StatefulWidget {
  final String usuarioId;
  const AdminUsuarioDetalleScreen({super.key, required this.usuarioId});

  @override
  State<AdminUsuarioDetalleScreen> createState() =>
      _AdminUsuarioDetalleScreenState();
}

class _AdminUsuarioDetalleScreenState extends State<AdminUsuarioDetalleScreen> {
  double _totalGastado = 0;
  int _totalPedidos = 0;
  bool _cargandoStats = true;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  void _cargarEstadisticas() async {
    try {
      final userService = UserService();
      final pedidos = await userService.contarPedidos(widget.usuarioId);
      final gastado = await userService.totalGastado(widget.usuarioId);

      if (mounted) {
        setState(() {
          _totalPedidos = pedidos;
          _totalGastado = gastado;
          _cargandoStats = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _cargandoStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserAdminProvider>();
    final u = userProv.usuarios.firstWhere(
        (user) => user.uid == widget.usuarioId,
        orElse: () => throw Exception('Usuario no encontrado'));

    return Scaffold(
      appBar: const UfAppBar(title: 'Perfil del Cliente'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: u.esStaff ? Colors.purple : AppColors.primaryLight,
            child: Icon(u.esStaff ? Icons.admin_panel_settings : Icons.person,
                size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(u.nombre,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium),
          Text(u.correo,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 16)),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Historial Comercial',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Divider(),
                  const SizedBox(height: 16),
                  if (_cargandoStats)
                    const CircularProgressIndicator()
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.shopping_bag,
                                color: AppColors.primary, size: 36),
                            const SizedBox(height: 8),
                            const Text('Pedidos Realizados',
                                style: TextStyle(color: AppColors.textMuted)),
                            Text('$_totalPedidos',
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.attach_money,
                                color: AppColors.success, size: 36),
                            const SizedBox(height: 8),
                            const Text('Total Gastado',
                                style: TextStyle(color: AppColors.textMuted)),
                            Text('\$$_totalGastado',
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
