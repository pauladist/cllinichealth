import 'package:flutter/material.dart';
import '../../../models/dayslot.dart';
import '../../widgets/clinic_shell.dart';
import '../../../models/enums.dart';

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

    // Día seleccionado a las 8:00
    final start = DateTime(date.year, date.month, date.day, 8, 0);
    // Último horario de inicio: 21:00 (turno de 21 a 22)
    // 8..21 inclusive => 14 horarios
    for (int i = 0; i < 14; i++) {
      final s = start.add(Duration(hours: i));
      final e = s.add(const Duration(hours: 1));
      slots.add(DaySlot(start: s, end: e, isFree: true));
    }
  }

  bool _isSlotDisabled(DaySlot slot) {
    final now = DateTime.now();

    // Día actual sin hora
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);

    // Si el día es anterior a hoy, todo deshabilitado
    if (selectedDay.isBefore(today)) return true;

    // Si es un día futuro, nada deshabilitado
    if (selectedDay.isAfter(today)) return false;

    // Es hoy: deshabilitar los horarios anteriores a la hora actual
    return slot.start.isBefore(now);
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
                final hhmm =
                    "${s.start.hour.toString().padLeft(2, '0')}:${s.start.minute.toString().padLeft(2, '0')}";

                final isDisabled = _isSlotDisabled(s);
                final isSelected = _selectedSlot == s;

                return GestureDetector(
                  onTap: isDisabled
                      ? null
                      : () => setState(() => _selectedSlot = s),
                  child: Opacity(
                    opacity: isDisabled ? 0.45 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cs.primary.withOpacity(.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? cs.primary : cs.outline,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color:
                            isDisabled ? cs.onSurfaceVariant : cs.onSurface,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            hhmm,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDisabled
                                  ? cs.onSurfaceVariant
                                  : cs.onSurface,
                            ),
                          ),
                        ],
                      ),
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
