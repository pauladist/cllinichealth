// lib/models/consultation.dart

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
    return Consultation(
      id: id,
      appointmentId: data['appointmentId'] ?? '',
      patientId: data['patientId'] ?? '',
      resumen: data['resumen'] ?? '',
      indicaciones: data['indicaciones'] ?? '',
      fecha: (data['fecha'] as DateTime?) ??
          DateTime.tryParse(data['fecha'] ?? '') ??
          DateTime(2000, 1, 1),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'patientId': patientId,
      'resumen': resumen,
      'indicaciones': indicaciones,
      'fecha': fecha,
    };
  }
}
