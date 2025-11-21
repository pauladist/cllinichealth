// lib/models/appointment.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinichealth/models/enums.dart';

/// Modelo de cita médica
class Appointment {
  final String id;
  final String patientId;  // DNI del paciente
  final DateTime dateTime; // Día y hora de la cita
  final String motivo;
  final ApptStatus status; // scheduled / checkin / cancelled

  Appointment({
    required this.id,
    required this.patientId,
    required this.dateTime,
    required this.motivo,
    required this.status,
  });

  factory Appointment.fromMap(String id, Map<String, dynamic> data) {
    final rawDate = data['dateTime'];
    late final DateTime dt;

    if (rawDate is Timestamp) {
      dt = rawDate.toDate();
    } else if (rawDate is DateTime) {
      dt = rawDate;
    } else if (rawDate is String) {
      dt = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      dt = DateTime.now();
    }

    return Appointment(
      id: id,
      patientId: data['patientId'] ?? '',
      dateTime: dt,
      motivo: data['motivo'] ?? '',
      status: _parseStatus(data['status']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      // Guardamos como Timestamp para que sea consistente
      'dateTime': Timestamp.fromDate(dateTime),
      'motivo': motivo,
      'status': status.name,
    };
  }

  static ApptStatus _parseStatus(dynamic raw) {
    if (raw is String) {
      return ApptStatus.values.firstWhere(
            (s) => s.name == raw,
        orElse: () => ApptStatus.scheduled,
      );
    }
    return ApptStatus.scheduled;
  }
}
