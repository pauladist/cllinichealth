// lib/models/enums.dart

/// Estado de una cita médica
enum ApptStatus {
  scheduled, // agendada
  checkin,   // paciente ya se presentó
  cancelled, // cancelada
}

extension ApptStatusX on ApptStatus {
  String get label {
    switch (this) {
      case ApptStatus.scheduled:
        return 'Agendada';
      case ApptStatus.checkin:
        return 'En consultorio';
      case ApptStatus.cancelled:
        return 'Cancelada';
    }
  }
}
