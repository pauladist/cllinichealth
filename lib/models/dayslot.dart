// lib/models/day_slot.dart

class DaySlot {
  final DateTime start; // inicio del turno (fecha + hora)
  final DateTime end;   // fin del turno
  final bool isFree;    // true = disponible, false = ocupado

  DaySlot({
    required this.start,
    required this.end,
    required this.isFree,
  });

  Duration get duration => end.difference(start);

  // Opcional: clave de día para agrupar en el calendario
  String get dayKey => '${start.year}-${start.month}-${start.day}';
}
