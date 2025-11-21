// lib/models/appointment.dart

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
    this.status = ApptStatus.scheduled,
  });

  String get dayKey =>
      '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

  // ---------- Firestore helpers ----------

  factory Appointment.fromMap(String id, Map<String, dynamic> data) {
    return Appointment(
      id: id,
      patientId: data['patientId'] ?? '',
      dateTime: (data['dateTime'] as DateTime?) ??
          DateTime.tryParse(data['dateTime'] ?? '') ??
          DateTime(2000, 1, 1),
      motivo: data['motivo'] ?? '',
      status: _parseStatus(data['status']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'dateTime': dateTime,
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
