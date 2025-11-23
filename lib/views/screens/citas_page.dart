// lib/views/screens/citas_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import '../widgets/clinic_shell.dart';

import '../../controllers/appointments_controller.dart';
import '../../controllers/patients_controller.dart';
import '../../models/appointment.dart';
import '../../models/patient.dart';
import '../../models/enums.dart';

class CitasPage extends StatefulWidget {
  const CitasPage({super.key});

  @override
  State<CitasPage> createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> {
  final _apptsCtrl = AppointmentsController();
  final _patientsCtrl = PatientsController();

  StreamSubscription<List<Appointment>>? _apptsSub;
  StreamSubscription<List<Patient>>? _patientsSub;

  List<Appointment> _appointments = [];
  Map<String, Patient> _patientsById = {};

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _apptsSub = _apptsCtrl.watchAll().listen((appts) {
      setState(() {
        _appointments = appts;
        _loading = false;
      });
    });

    _patientsSub = _patientsCtrl.watchAll().listen((patients) {
      setState(() {
        _patientsById = {
          for (final p in patients) p.id: p,
        };
      });
    });
  }

  @override
  void dispose() {
    _apptsSub?.cancel();
    _patientsSub?.cancel();
    super.dispose();
  }

  List<Appointment> get _upcoming {
    final now = DateTime.now();
    final filtered = _appointments
        .where((a) => a.dateTime.isAfter(now.subtract(const Duration(hours: 1))))
        .toList();
    filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return filtered;
  }

  void _newAppointment() {
    Navigator.pushNamed(context, '/appt/select-patient');
  }


  Future<void> _confirmCancel(Appointment a) async {
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(.4),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded,
                  color: cs.primary, size: 34),
            ),
            const SizedBox(height: 14),
            const Text(
              'Cancelar cita',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '¿Seguro que querés cancelar esta cita?\n\n'
                  '${_ddmmyy(a.dateTime)}  •  ${_hhmm(a.dateTime)}',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sí'),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      final updated = Appointment(
        id: a.id,
        patientId: a.patientId,
        dateTime: a.dateTime,
        motivo: a.motivo,
        status: ApptStatus.cancelled,
      );
      await _apptsCtrl.update(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita cancelada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _upcoming;
    final cs = Theme.of(context).colorScheme;

    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(
        title: const Text('Citas'),
        actions: [
          IconButton(
            onPressed: _newAppointment,
            icon: const Icon(Icons.add),
            tooltip: 'Nueva cita',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
          ? const Center(child: Text('Sin citas próximas'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final a = list[i];
          final p = _patientsById[a.patientId];
          final status = _statusUI(a.status);

          final compact = ButtonStyle(
            visualDensity: VisualDensity.compact,
            padding: const MaterialStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          final name = p?.fullName ?? 'Paciente desconocido';

          final endTime = a.dateTime.add(const Duration(minutes: 30));

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: cs.primaryContainer,
                  child: Text(
                    name.isNotEmpty
                        ? name[0].toUpperCase()
                        : '?',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_ddmmyy(a.dateTime)}  •  '
                            '${_hhmm(a.dateTime)}–${_hhmm(endTime)}',
                      ),
                      Text(
                        a.motivo,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Chip(
                            label: Text(status.label),
                            backgroundColor: status.color.withOpacity(.15),
                            labelStyle: TextStyle(
                              color: status.color,
                            ),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                          ),
                          OutlinedButton.icon(
                            style: compact,
                            onPressed: (a.status == ApptStatus.checkin)
                                ? () => Navigator.pushNamed(
                              context,
                              '/consulta/new',
                              arguments: {
                                'appointmentId': a.id,   // id de la cita
                                'patientId': a.patientId, // id/dni del paciente
                              },
                            )
                                : null,
                            icon: const Icon(
                              Icons.note_add_outlined,
                              size: 18,
                            ),
                            label: const Text('Nota clínica'),
                          ),
                          TextButton.icon(
                            style: compact,
                            onPressed: (a.status == ApptStatus.checkin)
                                ? null
                                : () => _confirmCancel(a),
                            icon: const Icon(
                              Icons.cancel,
                              size: 18,
                            ),
                            label: const Text('Cancelar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _StatusUI _statusUI(ApptStatus st) {
    switch (st) {
      case ApptStatus.scheduled:
        return _StatusUI('Programada', const Color(0xFF607D8B));
      case ApptStatus.checkin:
        return _StatusUI('Check-in', const Color(0xFFF57C00));
      case ApptStatus.cancelled:
        return _StatusUI('Cancelada', const Color(0xFFC62828));
    }
  }

  String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _ddmmyy(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _StatusUI {
  final String label;
  final Color color;
  _StatusUI(this.label, this.color);
}
