import 'dart:async';
import 'package:flutter/material.dart';

import '../../../controllers/patients_controller.dart';
import '../../../models/patient.dart';
import '../../widgets/clinic_shell.dart';
import '../../../models/enums.dart';

class SelectPatientPage extends StatefulWidget {
  const SelectPatientPage({super.key});

  @override
  State<SelectPatientPage> createState() => _SelectPatientPageState();
}

class _SelectPatientPageState extends State<SelectPatientPage> {
  final _patientsCtrl = PatientsController();

  StreamSubscription<List<Patient>>? _sub;
  List<Patient> _patients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _sub = _patientsCtrl.watchAll().listen((list) {
      setState(() {
        _patients = list;
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _createPatient() async {
    // Vamos al formulario y esperamos a ver si devuelve un id
    final result = await Navigator.pushNamed(context, '/appt/new-patient');

    if (!mounted) return;

    if (result is String && result.isNotEmpty) {
      // Opcional: mostrar mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente creado, seleccioná fecha')),
      );

      // Continuamos el flujo de turno con ese paciente
      Navigator.pushNamed(
        context,
        '/appt/select-date',
        arguments: result,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(
        title: const Text("Seleccionar paciente"),
        actions: [
          IconButton(
            onPressed: _createPatient,
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Nuevo paciente',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _patients.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 56,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            const Text('Todavía no hay pacientes'),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _createPatient,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Crear primer paciente'),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _patients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final p = _patients[i];
          return ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: CircleAvatar(
              child: Text(p.nombre[0]),
            ),
            title: Text('${p.nombre} ${p.apellido}'),
            subtitle: Text('DNI: ${p.id}'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/appt/select-date',
                arguments: p.id,
              );
            },
          );
        },
      ),
    );
  }
}
