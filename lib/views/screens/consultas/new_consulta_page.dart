import 'package:flutter/material.dart';


import '../../../models/enums.dart';
import '../../widgets/clinic_shell.dart';

// MODELOS
import '../../../models/patient.dart';
import '../../../models/appointment.dart';
import '../../../models/consultation.dart';
import '../../../models/enums.dart';

// CONTROLADORES
import '../../../controllers/patients_controller.dart';
import '../../../controllers/appointments_controller.dart';
import '../../../controllers/consultations_controller.dart';

class NewConsultaPage extends StatefulWidget {
  const NewConsultaPage({super.key});

  @override
  State<NewConsultaPage> createState() => _NewConsultaPageState();
}

class _NewConsultaPageState extends State<NewConsultaPage> {
  final _resumen = TextEditingController();
  final _indic = TextEditingController();

  final _patientsCtrl = PatientsController();
  final _appointmentsCtrl = AppointmentsController();
  final _consultationsCtrl = ConsultationsController();

  late Appointment _appt;
  late Patient _patient;

  bool _loading = true;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;

    final String apptId = args['appointmentId'];
// el patientId NO lo necesitás porque ya se carga desde la cita en _loadData()

    _loadData(apptId);

  }

  Future<void> _loadData(String apptId) async {
    try {
      final appt = await _appointmentsCtrl.getById(apptId);
      if (appt == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró la cita')),
        );
        Navigator.pop(context);
        return;
      }

      final patient = await _patientsCtrl.getById(appt.patientId);
      if (patient == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró el paciente')),
        );
        Navigator.pop(context);
        return;
      }

      if (!mounted) return;
      setState(() {
        _appt = appt;
        _patient = patient;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando datos: $e')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _guardar() async {
    if (_loading || _saving) return;

    setState(() => _saving = true);

    try {
      final consulta = Consultation(
        id: '', // Firestore genera el id
        appointmentId: _appt.id,
        patientId: _patient.id,
        resumen: _resumen.text.trim().isEmpty
            ? 'Consulta realizada'
            : _resumen.text.trim(),
        indicaciones: _indic.text.trim(),
        fecha: DateTime.now(),
      );

      // 1) Guardar consulta en el historial del paciente
      await _consultationsCtrl.add(_patient.id, consulta);

      // 2) Opcional: marcar cita como "completada / en consultorio"
      final updatedAppt = Appointment(
        id: _appt.id,
        patientId: _appt.patientId,
        dateTime: _appt.dateTime,
        motivo: _appt.motivo,
        status: ApptStatus.checkin,
      );
      await _appointmentsCtrl.update(updatedAppt);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consulta guardada y cita completada'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    _resumen.dispose();
    _indic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loading) {
      return ClinicShell(
        current: BottomTab.module,
        appBar: AppBar(title: const Text('Nueva consulta')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(title: const Text('Nueva consulta')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: CircleAvatar(child: Text(_patient.nombre[0])),
            title: Text(_patient.fullName),
            subtitle: Text('Turno: ${_hhmm(_appt.dateTime)}'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _resumen,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Resumen/Diagnóstico',
              filled: true,
              fillColor: cs.primaryContainer.withOpacity(.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _indic,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Indicaciones',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _guardar,
            icon: _saving
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.save),
            label: const Text('Guardar en historial'),
          ),
        ],
      ),
    );
  }

  String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
