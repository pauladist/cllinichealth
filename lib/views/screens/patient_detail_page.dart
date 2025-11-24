import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/patient.dart';
import '../../../controllers/patients_controller.dart';
import 'appointment_new/new_patient_page.dart';
import 'historial_page.dart';

class PatientDetailPage extends StatelessWidget {
  final Patient patient;
  final _patientsCtrl = PatientsController();

  PatientDetailPage({super.key, required this.patient});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: const Text('Eliminar paciente'),
            content: const Text(
                '¿Estás segura de que querés eliminar este paciente? Esta acción no se puede deshacer.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      // 1) Borrar todas las citas de este paciente
      final apptsSnap = await FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: patient.id) // 👈 campo de Appointment
          .get();

      if (apptsSnap.docs.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();

        for (final doc in apptsSnap.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
      }

      // 2) Borrar el paciente
      await _patientsCtrl.delete(patient.id);

      // 3) Volver atrás y mostrar mensaje
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente y citas eliminados')),
      );
    }
}

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(patient.fullName)),
      body: SingleChildScrollView( //
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DATOS DEL PACIENTE
            SizedBox(
              width: double.infinity,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Datos personales',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('Nombre: ${patient.fullName}'),
                      Text('DNI: ${patient.id}'),
                      if (patient.email != null) Text('Email: ${patient.email}'),
                      if (patient.telefono != null)
                        Text('Teléfono: ${patient.telefono}'),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HistorialPage(
                      patientIdToOpen: patient.id,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('Ir al historial clínico'),
            ),

            const SizedBox(height: 24),

            // EDITAR
            FilledButton.icon(
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewPatientPage(
                      patient: patient,
                    ),
                  ),
                );

                if (updated == true) {
                  Navigator.pop(context, true);
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar paciente'),
            ),

            const SizedBox(height: 12),

            // ELIMINAR
            OutlinedButton.icon(
              onPressed: () => _confirmDelete(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.error,
              ),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Eliminar'),
            ),
          ],
        ),
      ),
    );
  }
}
