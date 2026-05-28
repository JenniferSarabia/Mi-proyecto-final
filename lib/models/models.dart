// ─────────────────────────────────────────────
//  lib/models/models.dart
//  Mapeo exacto de los modelos Django → Dart
// ─────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

// ── USUARIO ──────────────────────────────────
class Usuario {
  final String uid;
  final String nombre;
  final String correo;
  final String telefono;
  final String direccion;
  final DateTime fechaRegistro;
  final bool esActivo;
  final bool esStaff;

  const Usuario({
    required this.uid,
    required this.nombre,
    required this.correo,
    this.telefono = '',
    this.direccion = '',
    required this.fechaRegistro,
    this.esActivo = true,
    this.esStaff = false,
  });

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Usuario(
      uid: doc.id,
      nombre: d['nombre'] ?? '',
      correo: d['correo'] ?? '',
      telefono: d['telefono'] ?? '',
      direccion: d['direccion'] ?? '',
      fechaRegistro:
          (d['fechaRegistro'] as Timestamp?)?.toDate() ?? DateTime.now(),
      esActivo: d['esActivo'] ?? true,
      esStaff: d['esStaff'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
        'direccion': direccion,
        'fechaRegistro': Timestamp.fromDate(fechaRegistro),
        'esActivo': esActivo,
        'esStaff': esStaff,
      };

  Usuario copyWith({
    String? nombre,
    String? telefono,
    String? direccion,
    bool? esActivo,
    bool? esStaff,
  }) =>
      Usuario(
        uid: uid,
        nombre: nombre ?? this.nombre,
        correo: correo,
        telefono: telefono ?? this.telefono,
        direccion: direccion ?? this.direccion,
        fechaRegistro: fechaRegistro,
        esActivo: esActivo ?? this.esActivo,
        esStaff: esStaff ?? this.esStaff,
      );
}

// ── TIPO DE PRODUCTO ──────────────────────────
enum TipoProducto { zapato, blusa, pantalon, accesorio }

extension TipoProductoExt on TipoProducto {
  String get etiqueta => switch (this) {
        TipoProducto.zapato => 'Zapato',
        TipoProducto.blusa => 'Sudadera/Blusa',
        TipoProducto.pantalon => 'Pantalón',
        TipoProducto.accesorio => 'Accesorio',
      };
  String get key => name; // 'zapato', 'blusa', etc.
}

// ── PRODUCTO BASE ─────────────────────────────
class Producto {
  final String? id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final String? imagenUrl;
  final String? coleccionId;
  final DateTime fechaAgregado;
  final bool esDestacado;
  final TipoProducto tipo;
  // Extra fields según tipo
  final String? marca; // zapato
  final String? categoria; // blusa, pantalon, accesorio

  const Producto({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    this.imagenUrl,
    this.coleccionId,
    required this.fechaAgregado,
    this.esDestacado = false,
    required this.tipo,
    this.marca,
    this.categoria,
  });

  factory Producto.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Producto(
      id: doc.id,
      nombre: d['nombre'] ?? '',
      descripcion: d['descripcion'] ?? '',
      precio: (d['precio'] as num?)?.toDouble() ?? 0.0,
      stock: (d['stock'] as num?)?.toInt() ?? 0,
      imagenUrl: d['imagenUrl'],
      coleccionId: d['coleccionId'],
      fechaAgregado:
          (d['fechaAgregado'] as Timestamp?)?.toDate() ?? DateTime.now(),
      esDestacado: d['esDestacado'] ?? false,
      tipo: TipoProducto.values.firstWhere(
        (t) => t.name == (d['tipo'] ?? 'zapato'),
        orElse: () => TipoProducto.zapato,
      ),
      marca: d['marca'],
      categoria: d['categoria'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'stock': stock,
        'imagenUrl': imagenUrl,
        'coleccionId': coleccionId,
        'fechaAgregado': Timestamp.fromDate(fechaAgregado),
        'esDestacado': esDestacado,
        'tipo': tipo.name,
        if (marca != null) 'marca': marca,
        if (categoria != null) 'categoria': categoria,
      };

  Producto copyWith({
    String? nombre,
    String? descripcion,
    double? precio,
    int? stock,
    String? imagenUrl,
    String? coleccionId,
    bool? esDestacado,
    String? marca,
    String? categoria,
  }) =>
      Producto(
        id: id,
        nombre: nombre ?? this.nombre,
        descripcion: descripcion ?? this.descripcion,
        precio: precio ?? this.precio,
        stock: stock ?? this.stock,
        imagenUrl: imagenUrl ?? this.imagenUrl,
        coleccionId: coleccionId ?? this.coleccionId,
        fechaAgregado: fechaAgregado,
        esDestacado: esDestacado ?? this.esDestacado,
        tipo: tipo,
        marca: marca ?? this.marca,
        categoria: categoria ?? this.categoria,
      );
}

// ── COLECCIÓN ─────────────────────────────────
class Coleccion {
  final String? id;
  final String nombre;
  final String descripcion;
  final String temporada;
  final String? imagenPortadaUrl;
  final DateTime fechaLanzamiento;
  final String estado;
  final int stock;
  final double precio;

  const Coleccion({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.temporada,
    this.imagenPortadaUrl,
    required this.fechaLanzamiento,
    required this.estado,
    required this.stock,
    required this.precio,
  });

  factory Coleccion.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Coleccion(
      id: doc.id,
      nombre: d['nombre'] ?? '',
      descripcion: d['descripcion'] ?? '',
      temporada: d['temporada'] ?? '',
      imagenPortadaUrl: d['imagenPortadaUrl'],
      fechaLanzamiento:
          (d['fechaLanzamiento'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estado: d['estado'] ?? 'activo',
      stock: (d['stock'] as num?)?.toInt() ?? 0,
      precio: (d['precio'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'temporada': temporada,
        'imagenPortadaUrl': imagenPortadaUrl,
        'fechaLanzamiento': Timestamp.fromDate(fechaLanzamiento),
        'estado': estado,
        'stock': stock,
        'precio': precio,
      };
}

// ── OFERTA ────────────────────────────────────
class Oferta {
  final String? id;
  final String productoId;
  final TipoProducto tipoProducto;
  final double precioAnterior;
  final double precioNuevo;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String mensaje;

  const Oferta({
    this.id,
    required this.productoId,
    required this.tipoProducto,
    required this.precioAnterior,
    required this.precioNuevo,
    required this.fechaInicio,
    required this.fechaFin,
    this.mensaje = '',
  });

  bool get estaActiva {
    final hoy = DateTime.now();
    return hoy.isAfter(fechaInicio) &&
        hoy.isBefore(fechaFin.add(const Duration(days: 1)));
  }

  int get diasRestantes => fechaFin.difference(DateTime.now()).inDays;

  factory Oferta.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Oferta(
      id: doc.id,
      productoId: d['productoId'] ?? '',
      tipoProducto: TipoProducto.values.firstWhere(
        (t) => t.name == (d['tipoProducto'] ?? 'zapato'),
        orElse: () => TipoProducto.zapato,
      ),
      precioAnterior: (d['precioAnterior'] as num?)?.toDouble() ?? 0.0,
      precioNuevo: (d['precioNuevo'] as num?)?.toDouble() ?? 0.0,
      fechaInicio: (d['fechaInicio'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaFin: (d['fechaFin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mensaje: d['mensaje'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'productoId': productoId,
        'tipoProducto': tipoProducto.name,
        'precioAnterior': precioAnterior,
        'precioNuevo': precioNuevo,
        'fechaInicio': Timestamp.fromDate(fechaInicio),
        'fechaFin': Timestamp.fromDate(fechaFin),
        'mensaje': mensaje,
      };
}

// ── ITEM CARRITO ──────────────────────────────
class ItemCarrito {
  final String productoId;
  final String nombreProducto;
  final TipoProducto tipo;
  final int cantidad;
  final double precioUnitario;
  final String? imagenUrl;

  const ItemCarrito({
    required this.productoId,
    required this.nombreProducto,
    required this.tipo,
    required this.cantidad,
    required this.precioUnitario,
    this.imagenUrl,
  });

  double get subtotal => cantidad * precioUnitario;

  ItemCarrito copyWith({int? cantidad, double? precioUnitario}) => ItemCarrito(
        productoId: productoId,
        nombreProducto: nombreProducto,
        tipo: tipo,
        cantidad: cantidad ?? this.cantidad,
        precioUnitario: precioUnitario ?? this.precioUnitario,
        imagenUrl: imagenUrl,
      );

  Map<String, dynamic> toMap() => {
        'productoId': productoId,
        'nombreProducto': nombreProducto,
        'tipo': tipo.name,
        'cantidad': cantidad,
        'precioUnitario': precioUnitario,
        'imagenUrl': imagenUrl,
      };

  factory ItemCarrito.fromMap(Map<String, dynamic> d) => ItemCarrito(
        productoId: d['productoId'] ?? '',
        nombreProducto: d['nombreProducto'] ?? '',
        tipo: TipoProducto.values.firstWhere(
          (t) => t.name == (d['tipo'] ?? 'zapato'),
          orElse: () => TipoProducto.zapato,
        ),
        cantidad: (d['cantidad'] as num?)?.toInt() ?? 1,
        precioUnitario: (d['precioUnitario'] as num?)?.toDouble() ?? 0.0,
        imagenUrl: d['imagenUrl'],
      );
}

// ── PEDIDO ────────────────────────────────────
class PedidoItem {
  final String nombreProducto;
  final String tipoProducto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  const PedidoItem({
    required this.nombreProducto,
    required this.tipoProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() => {
        'nombreProducto': nombreProducto,
        'tipoProducto': tipoProducto,
        'cantidad': cantidad,
        'precioUnitario': precioUnitario,
        'subtotal': subtotal,
      };

  factory PedidoItem.fromMap(Map<String, dynamic> d) => PedidoItem(
        nombreProducto: d['nombreProducto'] ?? '',
        tipoProducto: d['tipoProducto'] ?? '',
        cantidad: (d['cantidad'] as num?)?.toInt() ?? 1,
        precioUnitario: (d['precioUnitario'] as num?)?.toDouble() ?? 0.0,
        subtotal: (d['subtotal'] as num?)?.toDouble() ?? 0.0,
      );
}

class Pedido {
  final String? id;
  final String usuarioId;
  final String usuarioNombre;
  final double subtotal;
  final double impuestos;
  final double total;
  final String formaPago;
  final String direccionEnvio;
  final String numeroSeguimiento;
  final String detallePedido;
  final String estado; // <-- CORRECCIÓN: Campo agregado
  final DateTime creado;
  final List<PedidoItem> items;

  const Pedido({
    this.id,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.subtotal,
    required this.impuestos,
    required this.total,
    required this.formaPago,
    required this.direccionEnvio,
    required this.numeroSeguimiento,
    this.detallePedido = '',
    this.estado = 'pendiente', // <-- CORRECCIÓN: Valor inicial
    required this.creado,
    required this.items,
  });

  factory Pedido.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final rawItems = (d['items'] as List<dynamic>?) ?? [];
    return Pedido(
      id: doc.id,
      usuarioId: d['usuarioId'] ?? '',
      usuarioNombre: d['usuarioNombre'] ?? '',
      subtotal: (d['subtotal'] as num?)?.toDouble() ?? 0.0,
      impuestos: (d['impuestos'] as num?)?.toDouble() ?? 0.0,
      total: (d['total'] as num?)?.toDouble() ?? 0.0,
      formaPago: d['formaPago'] ?? '',
      direccionEnvio: d['direccionEnvio'] ?? '',
      numeroSeguimiento: d['numeroSeguimiento'] ?? '',
      detallePedido: d['detallePedido'] ?? '',
      estado: d['estado'] ?? 'pendiente', // <-- CORRECCIÓN: Lectura de BD
      creado: (d['creado'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: rawItems
          .map((i) => PedidoItem.fromMap(i as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'usuarioId': usuarioId,
        'usuarioNombre': usuarioNombre,
        'subtotal': subtotal,
        'impuestos': impuestos,
        'total': total,
        'formaPago': formaPago,
        'direccionEnvio': direccionEnvio,
        'numeroSeguimiento': numeroSeguimiento,
        'detallePedido': detallePedido,
        'estado': estado, // <-- CORRECCIÓN: Guardado a BD
        'creado': Timestamp.fromDate(creado),
        'items': items.map((i) => i.toMap()).toList(),
      };
}
