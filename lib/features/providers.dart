// lib/features/providers.dart
// Equivalente a los "managers de estado" del Django (Context Processors + Views logic)

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_services.dart';

// ─────────────────────────────────────────────
//  AUTH PROVIDER
// ─────────────────────────────────────────────
class AuthProvider extends ChangeNotifier {
  final AuthService _svc = AuthService();
  Usuario? _usuario;
  bool _cargando = false;
  String? _error;

  Usuario? get usuario => _usuario;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get autenticado => _usuario != null;
  bool get esAdmin => _usuario?.esStaff ?? false;

  Future<void> init() async {
    _usuario = await _svc.obtenerUsuarioActual();
    notifyListeners();
  }

  Future<bool> registrar(String nombre, String correo, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _usuario = await _svc.registrar(
          nombre: nombre, correo: correo, password: password);
      return true;
    } catch (e) {
      _error = _mensajeError(e.toString());
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> iniciarSesion(String correo, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      await _svc.iniciarSesion(correo: correo, password: password);
      _usuario = await _svc.obtenerUsuarioActual();
      return true;
    } catch (e) {
      _error = _mensajeError(e.toString());
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cerrarSesion() async {
    await _svc.cerrarSesion();
    _usuario = null;
    notifyListeners();
  }

  Future<bool> actualizarPerfil(
      String nombre, String telefono, String direccion) async {
    if (_usuario == null) return false;
    try {
      final updated = _usuario!
          .copyWith(nombre: nombre, telefono: telefono, direccion: direccion);
      await _svc.actualizarPerfil(updated);
      _usuario = updated;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  String _mensajeError(String raw) {
    if (raw.contains('email-already-in-use'))
      return 'Este correo ya está registrado.';
    if (raw.contains('wrong-password')) return 'Contraseña incorrecta.';
    if (raw.contains('user-not-found'))
      return 'No existe cuenta con ese correo.';
    if (raw.contains('weak-password')) return 'La contraseña es muy débil.';
    return raw; // 👈 solo cambia esta línea
  }
}

// ─────────────────────────────────────────────
//  PRODUCT PROVIDER
// ─────────────────────────────────────────────
class ProductProvider extends ChangeNotifier {
  final ProductService _svc = ProductService();
  final OfertaService _ofertaSvc = OfertaService();

  List<Producto> _productos = [];
  List<Producto> _destacados = [];
  Map<String, Oferta> _ofertas = {}; // productoId -> Oferta
  bool _cargando = false;
  String? _error;
  TipoProducto? _filtroTipo;
  String _busqueda = '';

  List<Producto> get productos => _productosFiltrados();
  List<Producto> get destacados => _destacados;
  bool get cargando => _cargando;
  String? get error => _error;
  TipoProducto? get filtroTipo => _filtroTipo;

  double precioFinal(Producto p) {
    final oferta = _ofertas[p.id];
    if (oferta != null && oferta.estaActiva) return oferta.precioNuevo;
    return p.precio;
  }

  bool tieneOferta(Producto p) {
    final o = _ofertas[p.id];
    return o != null && o.estaActiva;
  }

  Oferta? ofertaDe(Producto p) => _ofertas[p.id];

  List<Producto> _productosFiltrados() {
    var lista = [..._productos];
    if (_filtroTipo != null) {
      lista = lista.where((p) => p.tipo == _filtroTipo).toList();
    }
    if (_busqueda.isNotEmpty) {
      final q = _busqueda.toLowerCase();
      lista = lista
          .where((p) =>
              p.nombre.toLowerCase().contains(q) ||
              p.descripcion.toLowerCase().contains(q))
          .toList();
    }
    return lista;
  }

  Future<void> cargar() async {
    _cargando = true;
    notifyListeners();
    try {
      _productos = await _svc.obtenerTodos();
      _destacados = await _svc.obtenerDestacados();
      final ofertas = await _ofertaSvc.obtenerActivas();
      _ofertas = {for (final o in ofertas) o.productoId: o};
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void filtrarPorTipo(TipoProducto? tipo) {
    _filtroTipo = tipo;
    notifyListeners();
  }

  void buscar(String q) {
    _busqueda = q;
    notifyListeners();
  }

  // Admin CRUD
  Future<bool> crearProducto(Producto p, {File? imagen}) async {
    try {
      await _svc.crear(p, imagen: imagen);
      await cargar();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> actualizarProducto(Producto p, {File? imagen}) async {
    try {
      await _svc.actualizar(p, nuevaImagen: imagen);
      await cargar();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminarProducto(String id) async {
    try {
      await _svc.eliminar(id);
      _productos.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<Producto>> obtenerPorColeccion(String colId) =>
      _svc.obtenerPorColeccion(colId);
}

// ─────────────────────────────────────────────
//  CART PROVIDER
// ─────────────────────────────────────────────
class CartProvider extends ChangeNotifier {
  final List<ItemCarrito> _items = [];

  List<ItemCarrito> get items => List.unmodifiable(_items);
  int get cantidadTotal => _items.fold(0, (s, i) => s + i.cantidad);

  double get subtotal => _items.fold(0, (s, i) => s + i.subtotal);
  double get impuestos => double.parse((subtotal * 0.16).toStringAsFixed(2));
  double get total => double.parse((subtotal + impuestos).toStringAsFixed(2));

  void agregar(Producto p, double precioPagar) {
    final idx = _items.indexWhere((i) => i.productoId == p.id);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(cantidad: _items[idx].cantidad + 1);
    } else {
      _items.add(ItemCarrito(
        productoId: p.id!,
        nombreProducto: p.nombre,
        tipo: p.tipo,
        cantidad: 1,
        precioUnitario: precioPagar,
        imagenUrl: p.imagenUrl,
      ));
    }
    notifyListeners();
  }

  void actualizar(String productoId, int cantidad) {
    final idx = _items.indexWhere((i) => i.productoId == productoId);
    if (idx < 0) return;
    if (cantidad <= 0) {
      _items.removeAt(idx);
    } else {
      _items[idx] = _items[idx].copyWith(cantidad: cantidad);
    }
    notifyListeners();
  }

  void eliminar(String productoId) {
    _items.removeWhere((i) => i.productoId == productoId);
    notifyListeners();
  }

  void vaciar() {
    _items.clear();
    notifyListeners();
  }
}

// ─────────────────────────────────────────────
//  ORDER PROVIDER
// ─────────────────────────────────────────────
class OrderProvider extends ChangeNotifier {
  final OrderService _svc = OrderService();
  List<Pedido> _pedidos = [];
  bool _cargando = false;

  List<Pedido> get pedidos => _pedidos;
  bool get cargando => _cargando;

  Future<void> cargarMios(String usuarioId) async {
    _cargando = true;
    notifyListeners();
    _pedidos = await _svc.obtenerPorUsuario(usuarioId);
    _cargando = false;
    notifyListeners();
  }

  Future<void> cargarTodos({String? query}) async {
    _cargando = true;
    notifyListeners();
    _pedidos = await _svc.obtenerTodos(query: query);
    _cargando = false;
    notifyListeners();
  }

  Future<Pedido?> hacer({
    required Usuario usuario,
    required CartProvider cart,
    required String formaPago,
    required String direccion,
    String detalle = '',
  }) async {
    try {
      final pedido = await _svc.crearDesdeCarrito(
        usuario: usuario,
        items: cart.items.toList(),
        subtotal: cart.subtotal,
        impuestos: cart.impuestos,
        total: cart.total,
        formaPago: formaPago,
        direccionEnvio: direccion,
        detallePedido: detalle,
      );
      cart.vaciar();
      _pedidos.insert(0, pedido);
      notifyListeners();
      return pedido;
    } catch (_) {
      return null;
    }
  }

  Future<bool> cancelar(Pedido pedido) async {
    try {
      await _svc.cancelar(pedido);
      _pedidos.removeWhere((p) => p.id == pedido.id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminar(String id) async {
    try {
      await _svc.eliminar(id);
      _pedidos.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}

// ─────────────────────────────────────────────
//  COLECCION PROVIDER
// ─────────────────────────────────────────────
class ColeccionProvider extends ChangeNotifier {
  final ColeccionService _svc = ColeccionService();
  List<Coleccion> _colecciones = [];
  bool _cargando = false;

  List<Coleccion> get colecciones => _colecciones;
  bool get cargando => _cargando;

  Future<void> cargar() async {
    _cargando = true;
    notifyListeners();
    _colecciones = await _svc.obtenerTodas();
    _cargando = false;
    notifyListeners();
  }

  Future<bool> crear(Coleccion c, {File? imagen}) async {
    try {
      await _svc.crear(c, imagen: imagen);
      await cargar();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> actualizar(Coleccion c, {File? imagen}) async {
    try {
      await _svc.actualizar(c, nuevaImagen: imagen);
      await cargar();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminar(String id) async {
    try {
      await _svc.eliminar(id);
      _colecciones.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}

// ─────────────────────────────────────────────
//  OFERTA PROVIDER
// ─────────────────────────────────────────────
class OfertaProvider extends ChangeNotifier {
  final OfertaService _svc = OfertaService();
  List<Oferta> _ofertas = [];
  bool _cargando = false;

  List<Oferta> get ofertas => _ofertas;
  List<Oferta> get ofertasActivas =>
      _ofertas.where((o) => o.estaActiva).toList();
  bool get cargando => _cargando;

  Future<void> cargar() async {
    _cargando = true;
    notifyListeners();
    _ofertas = await _svc.obtenerTodas();
    _cargando = false;
    notifyListeners();
  }

  Future<bool> crear(Oferta o) async {
    try {
      await _svc.crear(o);
      await cargar();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> actualizar(Oferta o) async {
    try {
      await _svc.actualizar(o);
      await cargar();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminar(String id) async {
    try {
      await _svc.eliminar(id);
      _ofertas.removeWhere((o) => o.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}

// ─────────────────────────────────────────────
//  USER ADMIN PROVIDER
// ─────────────────────────────────────────────
class UserAdminProvider extends ChangeNotifier {
  final UserService _svc = UserService();
  List<Usuario> _usuarios = [];
  bool _cargando = false;

  List<Usuario> get usuarios => _usuarios;
  bool get cargando => _cargando;

  Future<void> cargar({String? query}) async {
    _cargando = true;
    notifyListeners();
    _usuarios = await _svc.obtenerTodos(query: query);
    _cargando = false;
    notifyListeners();
  }

  Future<bool> crear(
      String nombre, String correo, String pass, bool esStaff) async {
    try {
      final u = await _svc.crear(
          nombre: nombre, correo: correo, password: pass, esStaff: esStaff);
      _usuarios.insert(0, u);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> actualizar(Usuario u) async {
    try {
      await _svc.actualizar(u);
      final idx = _usuarios.indexWhere((x) => x.uid == u.uid);
      if (idx >= 0) {
        _usuarios[idx] = u;
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminar(String id) async {
    try {
      await _svc.eliminar(id);
      _usuarios.removeWhere((u) => u.uid == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> statsUsuario(String id) async {
    final pedidos = await _svc.contarPedidos(id);
    final total = await _svc.totalGastado(id);
    return {'pedidos': pedidos, 'totalGastado': total};
  }
}
