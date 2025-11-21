// lib/models/patient.dart
class Patient {
  /// Usamos el DNI como id principal del paciente
  final String id; // = dni
  final String nombre;
  final String apellido;
  final String telefono;
  final String domicilio;
  final DateTime fechaNacimiento;
  final String genero; // ej: "Femenino", "Masculino", "Otro"
  final String email;

  Patient({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.domicilio,
    required this.fechaNacimiento,
    required this.genero,
    required this.email,
  });

  String get fullName => '$nombre $apellido';

  // ---------- Helpers para Firestore ----------

  factory Patient.fromMap(String id, Map<String, dynamic> data) {
    return Patient(
      id: id,
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      telefono: data['telefono'] ?? '',
      domicilio: data['domicilio'] ?? '',
      fechaNacimiento:
      (data['fechaNacimiento'] as DateTime?) ??
          DateTime.tryParse(data['fechaNacimiento'] ?? '') ??
          DateTime(2000, 1, 1),
      genero: data['genero'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'domicilio': domicilio,
      'fechaNacimiento': fechaNacimiento,
      'genero': genero,
      'email': email,
    };
  }
}
