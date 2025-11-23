import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinichealth/models/appointment.dart';

class AppointmentsController {
  final _col = FirebaseFirestore.instance.collection('appointments');

  /// Crear nueva cita
  Future<String> create(Appointment a) async {
    final data = a.toMap();
    // Asegurarnos que dateTime es DateTime (Firestore lo guarda como Timestamp)
    // y que tiene patientId, motivo, status
    final doc = await _col.add(data);
    return doc.id;
  }

  /// Actualizar cita existente
  Future<void> update(Appointment a) async {
    await _col.doc(a.id).update(a.toMap());
  }

  /// Eliminar cita
  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  /// Obtener una cita por id
  Future<Appointment?> getById(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists) return null;
    return Appointment.fromMap(
      snap.id,
      snap.data() as Map<String, dynamic>,
    );
  }

  /// Ver citas de un día específico
  Stream<List<Appointment>> watchByDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return _col
        .where('dateTime', isGreaterThanOrEqualTo: start)
        .where('dateTime', isLessThan: end)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromMap(
        doc.id,
        doc.data() as Map<String, dynamic>,
      ))
          .toList();
    });
  }

  /// Ver todas las citas (para calendario, listado, etc.)
  Stream<List<Appointment>> watchAll() {
    return _col.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromMap(
        doc.id,
        doc.data() as Map<String, dynamic>,
      ))
          .toList();
    });
  }
  Stream<List<Appointment>> watchByPatient(String patientId) {
    return _col
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => Appointment.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }

}
