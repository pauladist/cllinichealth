// lib/models/patient.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  /// Usamos el DNI como id principal del paciente
  final String id; // = dni
  final String nombre;
  final String apellido;
  final String telefono;
  final String domicilio;
  final DateTime fechaNacimiento;
  final String genero;
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

  /// id = id del documento (en tu caso, el DNI)
  factory Patient.fromMap(String id, Map<String, dynamic> data) {
    final rawFecha = data['fechaNacimiento'];
    late final DateTime fecha;

    if (rawFecha is Timestamp) {
      // Caso típico cuando se guardó como Timestamp
      fecha = rawFecha.toDate();
    } else if (rawFecha is DateTime) {
      // Por si en algún momento ya viene como DateTime
      fecha = rawFecha;
    } else if (rawFecha is String) {
      // Por si quedó algún registro viejo guardado como texto
      fecha = DateTime.tryParse(rawFecha) ?? DateTime(2000, 1, 1);
    } else {
      // Fallback súper defensivo para no romper el stream
      fecha = DateTime(2000, 1, 1);
    }

    return Patient(
      id: id,
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      telefono: data['telefono'] ?? '',
      domicilio: data['domicilio'] ?? '',
      fechaNacimiento: fecha,
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
      // Siempre guardamos como Timestamp para que sea consistente
      'fechaNacimiento': Timestamp.fromDate(fechaNacimiento),
      'genero': genero,
      'email': email,
    };
  }
}
