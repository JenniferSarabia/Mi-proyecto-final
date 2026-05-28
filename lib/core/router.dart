// lib/core/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/providers.dart';

// --- PANTALLAS PÚBLICAS Y CLIENTES ---
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/registro_screen.dart';
import '../features/auth/screens/perfil_screen.dart';
import '../features/shop/screens/inicio_screen.dart';
import '../features/shop/screens/tienda_screen.dart';
import '../features/shop/screens/producto_detalle_screen.dart';
import '../features/shop/screens/colecciones_screen.dart';
import '../features/shop/screens/ofertas_screen.dart';
import '../features/shop/screens/novedades_screen.dart';
import '../features/shop/screens/busqueda_screen.dart';
import '../features/cart/screens/carrito_screen.dart';
import '../features/cart/screens/checkout_screen.dart';
import '../features/cart/screens/confirmacion_screen.dart';
import '../features/orders/screens/pedidos_screen.dart';

// --- PANTALLAS DE ADMINISTRADOR ---
import '../features/admin/screens/panel_admin_screen.dart';
import '../features/admin/screens/admin_productos_screen.dart';
import '../features/admin/screens/admin_producto_form_screen.dart';
import '../features/admin/screens/admin_colecciones_screen.dart';
import '../features/admin/screens/admin_coleccion_form_screen.dart';
import '../features/admin/screens/admin_ofertas_screen.dart';
import '../features/admin/screens/admin_oferta_form_screen.dart';
import '../features/admin/screens/admin_pedidos_screen.dart';
import '../features/admin/screens/admin_pedido_detalle_screen.dart';
import '../features/admin/screens/admin_usuarios_screen.dart';
import '../features/admin/screens/admin_usuario_form_screen.dart';
import '../features/admin/screens/admin_usuario_detalle_screen.dart';

GoRouter buildRouter(AuthProvider auth) => GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final enAdmin = state.matchedLocation.startsWith('/admin');
        // Protegemos las rutas de admin para que solo entre el Staff
        if (enAdmin && !auth.esAdmin) return '/';
        return null;
      },
      routes: [
        // --- RUTAS PÚBLICAS ---
        GoRoute(path: '/', builder: (_, __) => const InicioScreen()),
        GoRoute(path: '/tienda', builder: (_, __) => const TiendaScreen()),
        GoRoute(
            path: '/producto/:tipo/:id',
            builder: (_, s) => ProductoDetalleScreen(
                tipo: s.pathParameters['tipo']!, id: s.pathParameters['id']!)),
        GoRoute(
            path: '/colecciones',
            builder: (_, __) => const ColeccionesScreen()),
        GoRoute(
            path: '/colecciones/:id',
            builder: (_, s) =>
                ColeccionesScreen(coleccionId: s.pathParameters['id'])),
        GoRoute(path: '/ofertas', builder: (_, __) => const OfertasScreen()),
        GoRoute(
            path: '/novedades', builder: (_, __) => const NovedadesScreen()),
        GoRoute(path: '/buscar', builder: (_, __) => const BusquedaScreen()),
        GoRoute(path: '/carrito', builder: (_, __) => const CarritoScreen()),
        GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
        GoRoute(
            path: '/confirmacion/:id',
            builder: (_, s) =>
                ConfirmacionScreen(pedidoId: s.pathParameters['id']!)),
        GoRoute(path: '/perfil', builder: (_, __) => const PerfilScreen()),
        GoRoute(path: '/pedidos', builder: (_, __) => const PedidosScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/registro', builder: (_, __) => const RegistroScreen()),

        // --- RUTAS DEL PANEL DE CONTROL (ADMIN) ---
        GoRoute(path: '/admin', builder: (_, __) => const PanelAdminScreen()),

        // CRUD Productos
        GoRoute(
            path: '/admin/productos/:tipo',
            builder: (_, s) =>
                AdminProductosScreen(tipo: s.pathParameters['tipo']!)),
        GoRoute(
            path: '/admin/productos/:tipo/nuevo',
            builder: (_, s) =>
                AdminProductoFormScreen(tipo: s.pathParameters['tipo']!)),
        GoRoute(
            path: '/admin/productos/:tipo/:id/editar',
            builder: (_, s) => AdminProductoFormScreen(
                tipo: s.pathParameters['tipo']!,
                productoId: s.pathParameters['id']!)),

        // CRUD Colecciones
        GoRoute(
            path: '/admin/colecciones',
            builder: (_, __) => const AdminColeccionesScreen()),
        GoRoute(
            path: '/admin/colecciones/nueva',
            builder: (_, __) => const AdminColeccionFormScreen()),
        GoRoute(
            path: '/admin/colecciones/:id/editar',
            builder: (_, s) =>
                AdminColeccionFormScreen(coleccionId: s.pathParameters['id']!)),

        // CRUD Ofertas
        GoRoute(
            path: '/admin/ofertas',
            builder: (_, __) => const AdminOfertasScreen()),
        GoRoute(
            path: '/admin/ofertas/nueva',
            builder: (_, __) => const AdminOfertaFormScreen()),
        GoRoute(
            path: '/admin/ofertas/:id/editar',
            builder: (_, s) =>
                AdminOfertaFormScreen(ofertaId: s.pathParameters['id']!)),

        // CRUD Pedidos
        GoRoute(
            path: '/admin/pedidos',
            builder: (_, __) => const AdminPedidosScreen()),
        GoRoute(
            path: '/admin/pedidos/:id/detalle',
            builder: (_, s) =>
                AdminPedidoDetalleScreen(pedidoId: s.pathParameters['id']!)),

        // CRUD Usuarios
        GoRoute(
            path: '/admin/usuarios',
            builder: (_, __) => const AdminUsuariosScreen()),
        GoRoute(
            path: '/admin/usuarios/nuevo',
            builder: (_, __) => const AdminUsuarioFormScreen()),
        GoRoute(
            path: '/admin/usuarios/:id/detalle',
            builder: (_, s) =>
                AdminUsuarioDetalleScreen(usuarioId: s.pathParameters['id']!)),
      ],
    );
