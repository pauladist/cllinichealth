import 'package:flutter/material.dart';
import '../../widgets/clinic_shell.dart';
import '../../data/fake_store.dart';

class SelectSlotPage extends StatelessWidget {
  const SelectSlotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final String patientId = args['patientId'];
    final DateTime day = args['day'];

    final store = FakeStore.I;
    final slots = store.slotsForDay(day);

    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(title: const Text('Elegí el horario')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Fecha: ${day.day.toString().padLeft(2,'0')}/${day.month.toString().padLeft(2,'0')}/${day.year}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: slots.map((s){
              final label = '${_hhmm(s.start)} – ${_hhmm(s.end)}';
              return ChoiceChip(
                label: Text(label),
                selected: false,
                onSelected: s.isFree ? (_){
                  Navigator.pushNamed(context, '/appt/review', arguments: {
                    'patientId': patientId,
                    'start': s.start,
                    'end': s.end,
                  });
                } : null,
                disabledColor: Colors.black12,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text('Los horarios ocupados aparecen deshabilitados.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  String _hhmm(DateTime d) => '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
}
