class FilaTabla {
  final int fichaId;
  final String nombre;
  final int total;
  final int puesto;

  const FilaTabla({required this.fichaId, required this.nombre, required this.total, required this.puesto});

  factory FilaTabla.desdeJson(Map<String, dynamic> json) => FilaTabla(
        fichaId: json['id'] as int,
        nombre: json['nombre'] as String,
        total: json['total'] as int,
        puesto: json['puesto'] as int,
      );
}
