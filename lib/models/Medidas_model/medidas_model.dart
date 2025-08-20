class Medidas {
  final String id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String icono;
  final String fechaCreacion;

  Medidas({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.icono,
    required this.fechaCreacion,
  });

  factory Medidas.fromJson(Map<String, dynamic> j) => Medidas(
    id: j['id'] ?? '',
    titulo: j['titulo'] ?? '',
    descripcion: j['descripcion'] ?? '',
    categoria: j['categoria'] ?? '',
    icono: j['icono'] ?? '',
    fechaCreacion: j['fecha_creacion'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'categoria': categoria,
    'icono': icono,
    'fecha_creacion': fechaCreacion,
  };

  @override
  String toString() => 'Medidas(titulo: $titulo)';
}
