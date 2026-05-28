// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'features/providers.dart';
import 'firebase_options.dart'; // ¡Activado tras configurar flutterfire!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización oficial de Firebase para conectar con tu base de datos
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const UrbaFlowApp());
}

class UrbaFlowApp extends StatelessWidget {
  const UrbaFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => ProductProvider()..cargar()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ColeccionProvider()..cargar()),
        ChangeNotifierProvider(create: (_) => OfertaProvider()..cargar()),
        ChangeNotifierProvider(create: (_) => UserAdminProvider()),
      ],
      child: Builder(
        builder: (context) {
          final auth = context.watch<AuthProvider>();
          final router = buildRouter(auth);
          return MaterialApp.router(
            title: 'Urba & Flow',
            theme: AppTheme.theme,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
