import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../widgets/clinic_shell.dart';
import '../../data/fake_store.dart';

class SelectDatePage extends StatefulWidget {
  const SelectDatePage({super.key});

  @override
  State<SelectDatePage> createState() => _SelectDatePageState();
}

class _SelectDatePageState extends State<SelectDatePage> {
  final store = FakeStore.I;
  late String patientId;

  CalendarFormat _format = CalendarFormat.month;
  late DateTime _focused;
  DateTime _selected = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    patientId = ModalRoute.of(context)!.settings.arguments as String;
    _focused = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  Color _dotForDay(DateTime day){
    final n = store.countOfDay(day);
    if (n >= 3) return Colors.red.shade600;
    if (n == 2) return Colors.amber.shade700;
    if (n == 1) return Colors.green.shade500;
    return Colors.transparent;
  }

  void _goSlots(DateTime day){
    Navigator.pushNamed(context, '/appt/select-slot', arguments: {
      'patientId': patientId,
      'day': DateTime(day.year, day.month, day.day),
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(title: const Text('Elegí la fecha')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Material(
            color: cs.primaryContainer.withOpacity(.22),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TableCalendar(
                locale: 'es',
                firstDay: DateTime(2020,1,1),
                lastDay: DateTime(2030,12,31),
                focusedDay: _focused,
                calendarFormat: _format,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerVisible: false,
                onPageChanged: (f)=> setState(()=> _focused = DateTime(f.year,f.month,1)),
                selectedDayPredicate: (d)=> d.year==_selected.year && d.month==_selected.month && d.day==_selected.day,
                onDaySelected: (sel, foc){
                  setState(()=> _selected = sel);
                  // ir directo a slots (como pediste)
                  _goSlots(sel);
                },
                calendarStyle: const CalendarStyle(markersMaxCount: 1),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (ctx, day, events){
                    final color = _dotForDay(day);
                    if (color == Colors.transparent) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Container(width:6,height:6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SegmentedButton<CalendarFormat>(
                segments: const [
                  ButtonSegment(value: CalendarFormat.week, label: Text('Semana')),
                  ButtonSegment(value: CalendarFormat.month, label: Text('Mes')),
                ],
                selected: <CalendarFormat>{_format},
                onSelectionChanged: (s)=> setState(()=> _format = s.first),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Tocá un día para ver horarios disponibles.', textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
