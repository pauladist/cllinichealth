import 'package:flutter/material.dart';
import '../../widgets/clinic_shell.dart';

class SelectDatePage extends StatefulWidget {
  const SelectDatePage({super.key});

  @override
  State<SelectDatePage> createState() => _SelectDatePageState();
}

class _SelectDatePageState extends State<SelectDatePage> {
  DateTime? _selected;
  late String patientId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    patientId = ModalRoute.of(context)!.settings.arguments as String;
  }

  void _continue() {
    if (_selected == null) return;

    Navigator.pushNamed(
      context,
      '/appt/select-slot',
      arguments: {
        'patientId': patientId,
        'date': _selected!,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(title: const Text("Seleccionar fecha")),
      body: Column(
        children: [
          SizedBox(
            height: 350,
            child: CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 0)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (d) => setState(() => _selected = d),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _selected == null ? null : _continue,
            child: const Text("Continuar"),
          ),
        ],
      ),
    );
  }
}
