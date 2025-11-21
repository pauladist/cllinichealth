import 'package:flutter/material.dart';
import '../../../models/dayslot.dart';
import '../../../models/appointment.dart';
import '../../../models/enums.dart';

import '../../../controllers/appointments_controller.dart';
import '../../widgets/clinic_shell.dart';

class ReviewConfirmPage extends StatefulWidget {
  const ReviewConfirmPage({super.key});

  @override
  State<ReviewConfirmPage> createState() => _ReviewConfirmPageState();
}

class _ReviewConfirmPageState extends State<ReviewConfirmPage> {
  late String patientId;
  late DaySlot slot;

  final _apptCtrl = AppointmentsController();
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    patientId = args['patientId'];
    slot = args['slot'];
  }

  Future<void> _confirm() async {
    setState(() => _saving = true);

    final appt = Appointment(
      id: '', // Firestore asigna id automáticamente
      patientId: patientId,
      dateTime: slot.start,
      motivo: "Consulta médica",
      status: ApptStatus.scheduled,
    );

    final newId = await _apptCtrl.create(appt);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cita creada (ID: $newId)')),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/citas',
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hhmm =
        '${slot.start.hour.toString().padLeft(2, '0')}:${slot.start.minute.toString().padLeft(2, '0')}';

    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(title: const Text("Confirmar cita")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Paciente DNI: $patientId",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text("Día: ${slot.start.toLocal()}"),
            const SizedBox(height: 12),
            Text("Horario: $hhmm"),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _confirm,
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text("Confirmar cita"),
            ),
          ],
        ),
      ),
    );
  }
}
