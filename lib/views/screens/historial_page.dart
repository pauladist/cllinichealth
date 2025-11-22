import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/clinic_shell.dart';

import '../../controllers/patients_controller.dart';
import '../../controllers/consultations_controller.dart';
import '../../models/patient.dart';
import '../../models/consultation.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  final _patientsCtrl = PatientsController();
  final _consultationsCtrl = ConsultationsController();

  StreamSubscription<List<Patient>>? _patientsSub;

  List<Patient> _patients = [];
  bool _loading = true;

  /// ids de pacientes abiertos (carpetas expandidas)
  final Set<String> _openIds = {};

  /// id inicial para abrir ficha al venir desde el buscador
  String? _initialPatientId;
  bool _argsHandled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsHandled) return;
    _argsHandled = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _initialPatientId = args;
      _openIds.add(args); // marcamos esa carpeta como abierta
    }
  }


  @override
  void initState() {
    super.initState();
    _patientsSub = _patientsCtrl.watchAll().listen((list) {
      setState(() {
        _patients = list;
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _patientsSub?.cancel();
    super.dispose();
  }

  void _toggle(String id) {
    setState(() {
      if (_openIds.contains(id)) {
        _openIds.remove(id);
      } else {
        _openIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(
        title: const Text('Historial clínico'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _patients.isEmpty
          ? const Center(
        child: Text('Todavía no hay pacientes con historial'),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _patients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final p = _patients[i];
          final abierto = _openIds.contains(p.id);
          return _PacienteHistorialTile(
            patient: p,
            abierto: abierto,
            onToggle: () => _toggle(p.id),
            cs: cs,
            consultationsCtrl: _consultationsCtrl,
          );
        },
      ),
    );
  }
}

class _PacienteHistorialTile extends StatelessWidget {
  final Patient patient;
  final bool abierto;
  final VoidCallback onToggle;
  final ColorScheme cs;
  final ConsultationsController consultationsCtrl;

  const _PacienteHistorialTile({
    required this.patient,
    required this.abierto,
    required this.onToggle,
    required this.cs,
    required this.consultationsCtrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tile = InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: Text(
                patient.nombre.isNotEmpty
                    ? patient.nombre[0].toUpperCase()
                    : '?',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'DNI: ${patient.id}',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              abierto
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );

    final contenido = AnimatedCrossFade(
      duration: const Duration(milliseconds: 220),
      crossFadeState: abierto
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: const SizedBox.shrink(),
      secondChild: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 4),
        child: _ConsultasList(
          patientId: patient.id,
          consultationsCtrl: consultationsCtrl,
          cs: cs,
        ),
      ),
    );

    return Column(
      children: [
        tile,
        contenido,
      ],
    );
  }
}

class _ConsultasList extends StatelessWidget {
  final String patientId;
  final ConsultationsController consultationsCtrl;
  final ColorScheme cs;

  const _ConsultasList({
    required this.patientId,
    required this.consultationsCtrl,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Consultation>>(
      stream: consultationsCtrl.watchByPatient(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final notas = snapshot.data ?? [];

        if (notas.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'No hay consultas registradas para este paciente.',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          );
        }

        return Column(
          children: notas
              .map(
                (c) => Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _ConsultaItem(consulta: c, cs: cs),
            ),
          )
              .toList(),
        );
      },
    );
  }
}

class _ConsultaItem extends StatelessWidget {
  final Consultation consulta;
  final ColorScheme cs;

  const _ConsultaItem({
    required this.consulta,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final fechaStr = _ddmmyyyy(consulta.fecha);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fechaStr,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 4),
        if (consulta.resumen.isNotEmpty) ...[
          Text(
            consulta.resumen,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
        ],
        if (consulta.indicaciones.isNotEmpty)
          Text(
            'Indicaciones: ${consulta.indicaciones}',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
      ],
    );
  }

  String _ddmmyyyy(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
