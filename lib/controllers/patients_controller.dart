import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinichealth/models/patient.dart';

class PatientsController {
  final _col = FirebaseFirestore.instance.collection('patients');

  Future<void> create(Patient p) async {
    // usamos el DNI como id del doc
    await _col.doc(p.id).set(p.toMap());
  }

  Future<void> update(Patient p) async {
    await _col.doc(p.id).update(p.toMap());
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  Future<Patient?> getById(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists) return null;
    return Patient.fromMap(snap.id, snap.data() as Map<String, dynamic>);
  }

  Stream<List<Patient>> watchAll() {
    return _col.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
          Patient.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
