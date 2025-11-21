import 'dart:async';
import 'package:flutter/material.dart';

import '../../../controllers/patients_controller.dart';
import '../../../models/patient.dart';
import '../../widgets/clinic_shell.dart';

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

  @override
  Widget build(BuildContext context) {
    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(title: const Text("Seleccionar paciente")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
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
