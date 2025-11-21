import 'package:flutter/material.dart';
import '../../../models/dayslot.dart';
import '../../widgets/clinic_shell.dart';

class SelectSlotPage extends StatefulWidget {
  const SelectSlotPage({super.key});

  @override
  State<SelectSlotPage> createState() => _SelectSlotPageState();
}

class _SelectSlotPageState extends State<SelectSlotPage> {
  late String patientId;
  late DateTime date;

  DaySlot? _selectedSlot;

  List<DaySlot> slots = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    patientId = args['patientId'];
    date = args['date'];

    _generateSlots();
  }

  void _generateSlots() {
    slots.clear();
    final start = DateTime(date.year, date.month, date.day, 8, 0);
    for (int i = 0; i < 18; i++) {
      final s = start.add(Duration(minutes: 30 * i));
      final e = s.add(const Duration(minutes: 30));
      slots.add(DaySlot(start: s, end: e, isFree: true));
    }
  }

  void _continue() {
    if (_selectedSlot == null) return;
    Navigator.pushNamed(
      context,
      '/appt/review',
      arguments: {
        'patientId': patientId,
        'slot': _selectedSlot!,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(title: const Text('Seleccionar horario')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: slots.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final s = slots[i];
                final hhmm = "${s.start.hour.toString().padLeft(2, '0')}:${s.start.minute.toString().padLeft(2, '0')}";

                return GestureDetector(
                  onTap: () => setState(() => _selectedSlot = s),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedSlot == s
                          ? cs.primary.withOpacity(.15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedSlot == s ? cs.primary : cs.outline,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 12),
                        Text(hhmm, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _selectedSlot == null ? null : _continue,
              child: const Text("Confirmar horario"),
            ),
          ),
        ],
      ),
    );
  }
}
