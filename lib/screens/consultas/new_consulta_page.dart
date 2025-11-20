import 'package:flutter/material.dart';
import '../../widgets/clinic_shell.dart';
import '../../data/fake_store.dart';

class NewConsultaPage extends StatefulWidget {
  const NewConsultaPage({super.key});

  @override
  State<NewConsultaPage> createState() => _NewConsultaPageState();
}

class _NewConsultaPageState extends State<NewConsultaPage> {
  final store = FakeStore.I;
  final resumen = TextEditingController();
  final indic = TextEditingController();

  late Appointment appt;
  late Patient patient;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final apptId = ModalRoute.of(context)!.settings.arguments as String;
    appt = store.appointments.firstWhere((a)=> a.id == apptId);
    patient = store.patientById(appt.patientId)!;
  }

  void _guardar() {
    store.addConsultation(
          appointmentId: appt.id,
          patientId: patient.id,
          resumen: resumen.text.trim().isEmpty ? 'Consulta realizada' : resumen.text.trim(),
          indicaciones: indic.text.trim(),
    );
    // no cambiamos estado de la cita (queda en Check-in)
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Consulta guardada y cita completada')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(title: const Text('Nueva consulta')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: CircleAvatar(child: Text(patient.nombre[0])),
            title: Text(patient.fullName),
            subtitle: Text('Turno: ${_hhmm(appt.start)} – ${_hhmm(appt.end)}'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: resumen, maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Resumen/Diagnóstico',
              filled: true, fillColor: cs.primaryContainer.withOpacity(.15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: indic, maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Indicaciones',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _guardar,
            icon: const Icon(Icons.save),
            label: const Text('Guardar en historial'),
          )
        ],
      ),
    );
  }

  String _hhmm(DateTime d) => '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
}
