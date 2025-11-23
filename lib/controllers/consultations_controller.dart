import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinichealth/models/consultation.dart';

class ConsultationsController {
  final _db = FirebaseFirestore.instance;

  CollectionReference _col(String patientId) {
    return _db
        .collection('patients')
        .doc(patientId)
        .collection('consultations');
  }

  Future<void> add(String patientId, Consultation c) async {
    await _col(patientId).add(c.toMap());
  }

  Stream<List<Consultation>> watchByPatient(String patientId) {
    return _col(patientId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Consultation.fromMap(
        doc.id,
        doc.data() as Map<String, dynamic>,
      ))
          .toList();
    });
  }

  Future<void> update(String patientId, Consultation c) async {
    await _col(patientId).doc(c.id).update(c.toMap());
  }

  Future<void> delete(String patientId, String consultaId) async {
    await _col(patientId).doc(consultaId).delete();
  }
}
