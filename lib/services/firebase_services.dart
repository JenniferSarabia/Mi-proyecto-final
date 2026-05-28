// lib/services/firebase_services.dart
// Equivalente a views.py (lógica de acceso a datos)

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

// ─────────────────────────────────────────────
//  AUTH SERVICE  (registro / login / logout)
// ─────────────────────────────────────────────
class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Usuario?> registrar({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: correo,
      password: password,
    );
    final usuario = Usuario(
      uid: cred.user!.uid,
      nombre: nombre,
      correo: correo,
      fechaRegistro: DateTime.now(),
    );
    await _db
        .collection('users')
        .doc(cred.user!.uid)
        .set(usuario.toFirestore());
    return usuario;
  }

  Future<void> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: correo, password: password);
  }

  Future<void> cerrarSesion() => _auth.signOut();

  Future<Usuario?> obtenerUsuarioActual() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      // El documento no existe en Firestore (pasó cuando había error de permisos)
      // Lo creamos ahora con los datos básicos del Auth
      final usuario = Usuario(
        uid: user.uid,
        nombre: user.displayName ?? 'Usuario',
        correo: user.email ?? '',
        fechaRegistro: DateTime.now(),
      );
      await _db.collection('users').doc(user.uid).set(usuario.toFirestore());
      return usuario;
    }
    return Usuario.fromFirestore(doc);
  }

  Future<void> actualizarPerfil(Usuario usuario) async {
    await _db
        .collection('users')
        .doc(usuario.uid)
        .update(usuario.toFirestore());
  }
}

// ─────────────────────────────────────────────
//  PRODUCT SERVICE  (CRUD productos)
// ─────────────────────────────────────────────
class ProductService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  static const _col = 'products';

  Future<List<Producto>> obtenerTodos({TipoProducto? tipo}) async {
    Query q = _db.collection(_col).orderBy('fechaAgregado', descending: true);
    if (tipo != null) q = q.where('tipo', isEqualTo: tipo.name);
    final snap = await q.get();
    return snap.docs.map(Producto.fromFirestore).toList();
  }

  Future<List<Producto>> buscar(String query) async {
    final snap = await _db
        .collection(_col)
        .orderBy('nombre')
        .startAt([query]).endAt(['$query\uf8ff']).get();
    return snap.docs.map(Producto.fromFirestore).toList();
  }

  Future<List<Producto>> obtenerDestacados() async {
    final snap = await _db
        .collection(_col)
        .where('esDestacado', isEqualTo: true)
        .limit(8)
        .get();
    return snap.docs.map(Producto.fromFirestore).toList();
  }

  Future<Producto?> obtenerPorId(String id) async {
    final doc = await _db.collection(_col).doc(id).get();
    return doc.exists ? Producto.fromFirestore(doc) : null;
  }

  Future<List<Producto>> obtenerPorColeccion(String coleccionId) async {
    final snap = await _db
        .collection(_col)
        .where('coleccionId', isEqualTo: coleccionId)
        .get();
    return snap.docs.map(Producto.fromFirestore).toList();
  }

  Future<Producto> crear(Producto producto, {File? imagen}) async {
    String? imagenUrl;
    if (imagen != null) {
      imagenUrl = await _subirImagen(imagen);
    }
    final p = producto.copyWith(imagenUrl: imagenUrl);
    final ref = await _db.collection(_col).add(p.toFirestore());
    return p.copyWith();
  }

  Future<void> actualizar(Producto producto, {File? nuevaImagen}) async {
    String? imagenUrl = producto.imagenUrl;
    if (nuevaImagen != null) {
      imagenUrl = await _subirImagen(nuevaImagen, docId: producto.id);
    }
    final p = producto.copyWith(imagenUrl: imagenUrl);
    await _db.collection(_col).doc(producto.id).update(p.toFirestore());
  }

  Future<void> eliminar(String id) async {
    await _db.collection(_col).doc(id).delete();
  }

  Future<void> actualizarStock(String id, int cantidad) async {
    await _db.collection(_col).doc(id).update({
      'stock': FieldValue.increment(cantidad),
    });
  }

  Future<String> _subirImagen(File imagen, {String? docId}) async {
    final name = docId ?? const Uuid().v4();
    final ref = _storage.ref('productos/$name.jpg');
    await ref.putFile(imagen);
    return ref.getDownloadURL();
  }

  Stream<List<Producto>> streamPorTipo(TipoProducto tipo) {
    return _db
        .collection(_col)
        .where('tipo', isEqualTo: tipo.name)
        .orderBy('fechaAgregado', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Producto.fromFirestore).toList());
  }
}

// ─────────────────────────────────────────────
//  COLECCION SERVICE
// ─────────────────────────────────────────────
class ColeccionService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  static const _col = 'collections';

  Future<List<Coleccion>> obtenerTodas() async {
    final snap = await _db
        .collection(_col)
        .orderBy('fechaLanzamiento', descending: true)
        .get();
    return snap.docs.map(Coleccion.fromFirestore).toList();
  }

  Future<Coleccion?> obtenerPorId(String id) async {
    final doc = await _db.collection(_col).doc(id).get();
    return doc.exists ? Coleccion.fromFirestore(doc) : null;
  }

  Future<void> crear(Coleccion coleccion, {File? imagen}) async {
    String? imgUrl;
    if (imagen != null) {
      final ref = _storage.ref('colecciones/${const Uuid().v4()}.jpg');
      await ref.putFile(imagen);
      imgUrl = await ref.getDownloadURL();
    }
    final c = Coleccion(
      nombre: coleccion.nombre,
      descripcion: coleccion.descripcion,
      temporada: coleccion.temporada,
      imagenPortadaUrl: imgUrl ?? coleccion.imagenPortadaUrl,
      fechaLanzamiento: coleccion.fechaLanzamiento,
      estado: coleccion.estado,
      stock: coleccion.stock,
      precio: coleccion.precio,
    );
    await _db.collection(_col).add(c.toFirestore());
  }

  Future<void> actualizar(Coleccion coleccion, {File? nuevaImagen}) async {
    String? imgUrl = coleccion.imagenPortadaUrl;
    if (nuevaImagen != null) {
      final ref = _storage.ref('colecciones/${coleccion.id}.jpg');
      await ref.putFile(nuevaImagen);
      imgUrl = await ref.getDownloadURL();
    }
    final data = coleccion.toFirestore();
    if (imgUrl != null) data['imagenPortadaUrl'] = imgUrl;
    await _db.collection(_col).doc(coleccion.id).update(data);
  }

  Future<void> eliminar(String id) async {
    await _db.collection(_col).doc(id).delete();
  }
}

// ─────────────────────────────────────────────
//  OFERTA SERVICE
// ─────────────────────────────────────────────
class OfertaService {
  final _db = FirebaseFirestore.instance;
  static const _col = 'offers';

  Future<List<Oferta>> obtenerTodas() async {
    final snap = await _db.collection(_col).orderBy('fechaFin').get();
    return snap.docs.map(Oferta.fromFirestore).toList();
  }

  Future<List<Oferta>> obtenerActivas() async {
    final hoy = Timestamp.fromDate(DateTime.now());
    final snap = await _db
        .collection(_col)
        .where('fechaInicio', isLessThanOrEqualTo: hoy)
        .where('fechaFin', isGreaterThanOrEqualTo: hoy)
        .get();
    return snap.docs.map(Oferta.fromFirestore).toList();
  }

  Future<Oferta?> obtenerPorProducto(String productoId) async {
    final hoy = Timestamp.fromDate(DateTime.now());
    final snap = await _db
        .collection(_col)
        .where('productoId', isEqualTo: productoId)
        .where('fechaFin', isGreaterThanOrEqualTo: hoy)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Oferta.fromFirestore(snap.docs.first);
  }

  Future<void> crear(Oferta oferta) async {
    await _db.collection(_col).add(oferta.toFirestore());
  }

  Future<void> actualizar(Oferta oferta) async {
    await _db.collection(_col).doc(oferta.id).update(oferta.toFirestore());
  }

  Future<void> eliminar(String id) async {
    await _db.collection(_col).doc(id).delete();
  }
}

// ─────────────────────────────────────────────
//  ORDER SERVICE  (Pedido + cancelar)
// ─────────────────────────────────────────────
class OrderService {
  final _db = FirebaseFirestore.instance;
  static const _col = 'orders';
  static const _prodCol = 'products';

  static String _generarSeguimiento() {
    final hex =
        const Uuid().v4().replaceAll('-', '').substring(0, 6).toUpperCase();
    return 'URB-$hex';
  }

  Future<Pedido> crearDesdeCarrito({
    required Usuario usuario,
    required List<ItemCarrito> items,
    required double subtotal,
    required double impuestos,
    required double total,
    required String formaPago,
    required String direccionEnvio,
    String detallePedido = '',
  }) async {
    final batch = _db.batch();

    for (final item in items) {
      final prodRef = _db.collection(_prodCol).doc(item.productoId);
      batch.update(prodRef, {'stock': FieldValue.increment(-item.cantidad)});
    }

    final pedido = Pedido(
      usuarioId: usuario.uid,
      usuarioNombre: usuario.nombre,
      subtotal: subtotal,
      impuestos: impuestos,
      total: total,
      formaPago: formaPago,
      direccionEnvio: direccionEnvio,
      numeroSeguimiento: _generarSeguimiento(),
      detallePedido: detallePedido,
      creado: DateTime.now(),
      items: items
          .map((i) => PedidoItem(
                nombreProducto: i.nombreProducto,
                tipoProducto: i.tipo.etiqueta,
                cantidad: i.cantidad,
                precioUnitario: i.precioUnitario,
                subtotal: i.subtotal,
              ))
          .toList(),
    );

    final pedidoRef = _db.collection(_col).doc();
    batch.set(pedidoRef, pedido.toFirestore());
    await batch.commit();
    return Pedido(
      id: pedidoRef.id,
      usuarioId: pedido.usuarioId,
      usuarioNombre: pedido.usuarioNombre,
      subtotal: pedido.subtotal,
      impuestos: pedido.impuestos,
      total: pedido.total,
      formaPago: pedido.formaPago,
      direccionEnvio: pedido.direccionEnvio,
      numeroSeguimiento: pedido.numeroSeguimiento,
      detallePedido: pedido.detallePedido,
      creado: pedido.creado,
      items: pedido.items,
    );
  }

  Future<List<Pedido>> obtenerPorUsuario(String usuarioId) async {
    final snap = await _db
        .collection(_col)
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('creado', descending: true)
        .get();
    return snap.docs.map(Pedido.fromFirestore).toList();
  }

  Future<List<Pedido>> obtenerTodos({String? query}) async {
    Query q = _db.collection(_col).orderBy('creado', descending: true);
    final snap = await q.get();
    var pedidos = snap.docs.map(Pedido.fromFirestore).toList();
    if (query != null && query.isNotEmpty) {
      final q2 = query.toLowerCase();
      pedidos = pedidos
          .where((p) =>
              p.numeroSeguimiento.toLowerCase().contains(q2) ||
              p.usuarioNombre.toLowerCase().contains(q2) ||
              p.id!.contains(q2))
          .toList();
    }
    return pedidos;
  }

  Future<Pedido?> obtenerPorId(String id) async {
    final doc = await _db.collection(_col).doc(id).get();
    return doc.exists ? Pedido.fromFirestore(doc) : null;
  }

  Future<void> cancelar(Pedido pedido) async {
    final batch = _db.batch();
    for (final item in pedido.items) {
      final snap = await _db
          .collection(_prodCol)
          .where('nombre', isEqualTo: item.nombreProducto)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        batch.update(snap.docs.first.reference, {
          'stock': FieldValue.increment(item.cantidad),
        });
      }
    }
    batch.delete(_db.collection(_col).doc(pedido.id));
    await batch.commit();
  }

  Future<void> eliminar(String id) async {
    await _db.collection(_col).doc(id).delete();
  }
}

// ─────────────────────────────────────────────
//  USER SERVICE  (admin: CRUD usuarios)
// ─────────────────────────────────────────────
class UserService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  static const _col = 'users';

  Future<List<Usuario>> obtenerTodos({String? query}) async {
    final snap = await _db
        .collection(_col)
        .orderBy('fechaRegistro', descending: true)
        .get();
    var users = snap.docs.map(Usuario.fromFirestore).toList();
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      users = users
          .where((u) =>
              u.nombre.toLowerCase().contains(q) ||
              u.correo.toLowerCase().contains(q))
          .toList();
    }
    return users;
  }

  Future<Usuario?> obtenerPorId(String id) async {
    final doc = await _db.collection(_col).doc(id).get();
    return doc.exists ? Usuario.fromFirestore(doc) : null;
  }

  Future<Usuario> crear({
    required String nombre,
    required String correo,
    required String password,
    bool esStaff = false,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: correo,
      password: password,
    );
    final usuario = Usuario(
      uid: cred.user!.uid,
      nombre: nombre,
      correo: correo,
      fechaRegistro: DateTime.now(),
      esStaff: esStaff,
    );
    await _db.collection(_col).doc(cred.user!.uid).set(usuario.toFirestore());
    return usuario;
  }

  Future<void> actualizar(Usuario usuario) async {
    await _db.collection(_col).doc(usuario.uid).update(usuario.toFirestore());
  }

  Future<void> eliminar(String id) async {
    await _db.collection(_col).doc(id).delete();
  }

  Future<int> contarPedidos(String usuarioId) async {
    final snap = await _db
        .collection('orders')
        .where('usuarioId', isEqualTo: usuarioId)
        .get();
    return snap.size;
  }

  // <-- CORREGIDO ERROR DE CAST <double>
  Future<double> totalGastado(String usuarioId) async {
    final snap = await _db
        .collection('orders')
        .where('usuarioId', isEqualTo: usuarioId)
        .get();
    return snap.docs.fold<double>(0.0, (acc, doc) {
      final d = doc.data() as Map<String, dynamic>;
      return acc + ((d['total'] as num?)?.toDouble() ?? 0.0);
    });
  }
}
