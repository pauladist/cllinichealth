// lib/models/consultation.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Consultation {
  final String id;
  final String appointmentId;
  final String patientId;
  final String resumen;
  final String indicaciones;
  final DateTime fecha;

  Consultation({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.resumen,
    required this.indicaciones,
    required this.fecha,
  });

  // ---------- Firestore helpers ----------

  factory Consultation.fromMap(String id, Map<String, dynamic> data) {
    // Manejo defensivo del campo fecha (Timestamp / DateTime / String)
    final rawFecha = data['fecha'];
    late final DateTime fecha;

    if (rawFecha is Timestamp) {
      fecha = rawFecha.toDate();
    } else if (rawFecha is DateTime) {
      fecha = rawFecha;
    } else if (rawFecha is String) {
      fecha = DateTime.tryParse(rawFecha) ?? DateTime(2000, 1, 1);
    } else {
      fecha = DateTime(2000, 1, 1);
    }

    return Consultation(
      id: id,
      appointmentId: data['appointmentId'] ?? '',
      patientId: data['patientId'] ?? '',
      resumen: data['resumen'] ?? '',
      indicaciones: data['indicaciones'] ?? '',
      fecha: fecha,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'patientId': patientId,
      'resumen': resumen,
      'indicaciones': indicaciones,
      // Guardamos siempre como Timestamp para ser consistentes
      'fecha': Timestamp.fromDate(fecha),
    };
  }
}
