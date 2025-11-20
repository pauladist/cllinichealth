import 'package:flutter/material.dart';

/// ======= Modelos simples =======
enum ApptStatus { scheduled, checkin, cancelled }

class Patient {
  final String id;
  final String nombre;
  final String apellido;
  Patient({required this.id, required this.nombre, required this.apellido});

  String get fullName => '$nombre $apellido';
}

class Appointment {
  final String id;
  final String patientId;
  DateTime start;
  DateTime end;
  String motivo;
  ApptStatus status;
  Appointment({
    required this.id,
    required this.patientId,
    required this.start,
    required this.end,
    required this.motivo,
    this.status = ApptStatus.scheduled,
  });
}

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
}

class DaySlot {
  final DateTime start;
  final DateTime end;
  final bool isFree;
  DaySlot({required this.start, required this.end, required this.isFree});
}

/// ======= FakeStore: datos en RAM para la demo =======
class FakeStore extends ChangeNotifier {
  static final FakeStore I = FakeStore._();
  FakeStore._() { _seed(); }

  final List<Patient> _patients = [];
  final List<Appointment> _appts = [];
  final List<Consultation> _notes = [];

  // -------- Pacientes --------
  List<Patient> get patients => List.unmodifiable(_patients);
  Patient? patientById(String id) => _patients.firstWhere((p) => p.id == id, orElse: () => Patient(id: 'X', nombre: 'Desconocido', apellido: ''));

  void addPatient(String nombre, String apellido) {
    final id = 'P${DateTime.now().microsecondsSinceEpoch}';
    _patients.add(Patient(id: id, nombre: nombre, apellido: apellido));
    notifyListeners();
  }

  // -------- Citas --------
  List<Appointment> get appointments => List.unmodifiable(_appts);

  List<Appointment> upcoming() {
    final now = DateTime.now();
    final list = _appts.where((a) => a.end.isAfter(now) && a.status != ApptStatus.cancelled).toList();
    list.sort((a,b)=> a.start.compareTo(b.start));
    return list;
  }

  List<Appointment> appointmentsOfDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days:1));
    return _appts.where((a)=> a.start.isAfter(start.subtract(const Duration(milliseconds:1))) && a.start.isBefore(end)).toList()
      ..sort((a,b)=> a.start.compareTo(b.start));
  }

  int countOfDay(DateTime day) => appointmentsOfDay(day).length;

  void addAppointment({required String patientId, required DateTime start, required DateTime end, required String motivo}) {
    final id = 'A${DateTime.now().microsecondsSinceEpoch}';
    _appts.add(Appointment(id: id, patientId: patientId, start: start, end: end, motivo: motivo, status: ApptStatus.scheduled));
    notifyListeners();
  }

  void setApptStatus(String apptId, ApptStatus st) {
    final i = _appts.indexWhere((a)=> a.id == apptId);
    if (i>=0) { _appts[i].status = st; notifyListeners(); }
  }

  // -------- Notas clínicas --------
  List<Consultation> notesOfPatient(String patientId) =>
      _notes.where((n)=> n.patientId == patientId).toList()..sort((a,b)=> b.fecha.compareTo(a.fecha));

  void addConsultation({required String appointmentId, required String patientId, required String resumen, required String indicaciones}) {
    final id = 'C${DateTime.now().microsecondsSinceEpoch}';
    _notes.add(Consultation(
      id: id,
      appointmentId: appointmentId,
      patientId: patientId,
      resumen: resumen,
      indicaciones: indicaciones,
      fecha: DateTime.now(),
    ));
    notifyListeners();
  }

  List<DaySlot> slotsForDay(DateTime day) {
    final base = DateTime(day.year, day.month, day.day);
    // 2 mañana, 2 tarde, 1 noche (30')
    final proposal = <DateTime>[
      base.add(const Duration(hours: 9,  minutes: 0)),  // 09:00-09:30
      base.add(const Duration(hours: 10, minutes: 0)),  // 10:00-10:30
      base.add(const Duration(hours: 15, minutes: 0)),  // 15:00-15:30
      base.add(const Duration(hours: 16, minutes: 0)),  // 16:00-16:30
      base.add(const Duration(hours: 19, minutes: 0)),  // 19:00-19:30
    ];

    final occupied = appointmentsOfDay(base);
    bool overlaps(DateTime s, DateTime e) =>
        occupied.any((a) => !(a.end.isAtSameMomentAs(s) ||
            a.start.isAtSameMomentAs(e) ||
            a.end.isBefore(s) ||
            a.start.isAfter(e)));

    return proposal.map((start) {
      final end = start.add(const Duration(minutes: 30));
      final free = !overlaps(start, end);
      return DaySlot(start: start, end: end, isFree: free);
    }).toList();
  }


  // -------- Seed de demo --------
  void _seed() {
    _patients.addAll([
      Patient(id:'P1', nombre:'Margaret', apellido:'Osborn'),
      Patient(id:'P2', nombre:'Prue', apellido:'Halliwell'),
      Patient(id:'P3', nombre:'Juan', apellido:'Pérez'),
      Patient(id:'P4', nombre:'María', apellido:'López'),
      Patient(id:'P5', nombre:'Carlos', apellido:'Gómez'),
    ]);

    final now = DateTime.now();
    final d = DateTime(now.year, now.month, now.day);
    addAppointment(patientId:'P3', start:d.add(const Duration(hours:9)), end:d.add(const Duration(hours:9, minutes:30)), motivo:'Consulta clínica');
    addAppointment(patientId:'P4', start:d.add(const Duration(hours:10)), end:d.add(const Duration(hours:10, minutes:30)), motivo:'Control');
    addAppointment(patientId:'P2', start:d.add(const Duration(days:1, hours:15)), end:d.add(const Duration(days:1, hours:15, minutes:30)), motivo:'Laboratorio');
  }
}
