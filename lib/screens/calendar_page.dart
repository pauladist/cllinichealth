import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/clinic_shell.dart';
import '../data/fake_store.dart';

final store = FakeStore.I;

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _format = CalendarFormat.month;
  late DateTime _focusedDay;
  DateTime _selectedDay = DateTime.now();

  // ======= Datos de ejemplo (eventos por día) =======
  // clave: día normalizado (YYYY-MM-DD 00:00), valor: lista de citas
  final Map<DateTime, List<Appointment>> _events = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // arrancamos en Octubre del año actual (si querés: DateTime(now.year, 10, 1))
    _focusedDay = DateTime(now.year, 10, 1);
    _seedSampleAppointments(_focusedDay);
  }

  // Normaliza un DateTime al día (sin hora)
  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  // Genera citas de demo para el mes visible (determinístico)
  void _seedSampleAppointments(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(month.year, month.month, i);
      final key = _dayKey(day);

      // si ya generamos ese mes, no repetir
      if (_events.containsKey(key)) continue;

      final weekday = day.weekday; // 1=Lun .. 7=Dom
      final count =
      (weekday == DateTime.saturday || weekday == DateTime.monday) ? 3 :
      (weekday == DateTime.tuesday || weekday == DateTime.thursday) ? 2 :
      (weekday == DateTime.sunday) ? 0 : 1;

      final list = <Appointment>[];
      for (int k = 0; k < count; k++) {
        final start = DateTime(day.year, day.month, day.day, 8 + k * 1, 30);
        final end   = start.add(const Duration(minutes: 45));
        list.add(Appointment(
          patient: _fakeName((i + k) * 37),
          note: k == 0 ? 'Consulta' : (k == 1 ? 'Controles' : 'Laboratorio'),
          start: start,
          end: end,
          ok: (k % 2 == 0),
        ));
      }
      _events[key] = list;
    }
  }

  String _fakeName(int seed) {
    const names = ['Matt Smith','Angelika Kravets','Emily Blunt','Juan Pérez','María López','Carlos Gómez','Prue Halliwell','Margaret Osborn'];
    return names[seed % names.length];
  }

  // Nivel de ocupación por cantidad de turnos (sin porcentajes)
  BusyLevel _busyFor(DateTime day) {
    final n = (_events[_dayKey(day)] ?? const []).length;
    if (n >= 3) return BusyLevel.high;     // rojo
    if (n == 2) return BusyLevel.medium;   // amarillo
    if (n == 1) return BusyLevel.low;      // verde
    return BusyLevel.none;                 // sin punto
  }

  Color _dotColor(BusyLevel level) {
    switch (level) {
      case BusyLevel.high:   return Colors.red.shade600;
      case BusyLevel.medium: return Colors.amber.shade700;
      case BusyLevel.low:    return Colors.green.shade500;
      case BusyLevel.none:   return Colors.transparent;
    }
  }

  List<Appointment> _eventsOf(DateTime day) => _events[_dayKey(day)] ?? const [];

  void _goMonth(int delta) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + delta, 1);
      _seedSampleAppointments(_focusedDay);
    });
  }

  void _goToday() {
    setState(() {
      _focusedDay = DateTime.now();
      _selectedDay = _dayKey(DateTime.now());
      _seedSampleAppointments(_focusedDay);
      _format = CalendarFormat.week; // ir a semana de hoy
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final monthTitle = _monthName(_focusedDay);

    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(
        title: Text('Calendario — $monthTitle'),
        actions: [
          // Switch Semana / Mes (a la derecha)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SegmentedButton<CalendarFormat>(
              segments: const [
                ButtonSegment(value: CalendarFormat.week, label: Text('Semana')),
                ButtonSegment(value: CalendarFormat.month, label: Text('Mes')),
              ],
              selected: <CalendarFormat>{_format},
              onSelectionChanged: (s) => setState(() => _format = s.first),
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        children: [
          // Navegación de meses + Hoy
          Row(
            children: [
              IconButton(
                tooltip: 'Mes anterior',
                onPressed: () => _goMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Center(
                  child: Text(monthTitle,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              IconButton(
                tooltip: 'Mes siguiente',
                onPressed: () => _goMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
              const SizedBox(width: 6),
              TextButton.icon(
                onPressed: _goToday,
                icon: const Icon(Icons.today, size: 18),
                label: const Text('Hoy'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _legend(cs, Colors.green.shade500, 'Baja'),
              _legend(cs, Colors.amber.shade700, 'Media'),
              _legend(cs, Colors.red.shade600, 'Alta'),
            ],
          ),
          const SizedBox(height: 8),

          // ======= Calendario =======
          Material(
            color: cs.primaryContainer.withOpacity(.22),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TableCalendar<Appointment>(
                locale: 'es',
                firstDay: DateTime(2020, 1, 1),
                lastDay: DateTime(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _format,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerVisible: false,
                onPageChanged: (focused) {
                  setState(() {
                    _focusedDay = DateTime(focused.year, focused.month, 1);
                    _seedSampleAppointments(_focusedDay);
                  });
                },
                selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                onDaySelected: (sel, foc) {
                  setState(() {
                    _selectedDay = _dayKey(sel);
                    _focusedDay = foc;
                    // si estoy en Mes, voy a Semana con ese día
                    if (_format == CalendarFormat.month) {
                      _format = CalendarFormat.week;
                    }
                  });
                },
                eventLoader: (day) => _eventsOf(day),
                calendarStyle: CalendarStyle(
                  // fondo normal; NO pintamos la celda
                  todayDecoration: BoxDecoration(
                    border: Border.all(color: cs.primary, width: 2),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration:
                  BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                  markersAlignment: Alignment.bottomCenter,
                  markersMaxCount: 1, // solo un puntito
                ),
                // Puntito por ocupación (sin colorear la celda)
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    final n = store.countOfDay(day);
                    Color color;
                    if (n >= 3) color = Colors.red.shade600;
                    else if (n == 2) color = Colors.amber.shade700;
                    else if (n == 1) color = Colors.green.shade500;
                    else color = Colors.transparent;

                    if (color == Colors.transparent) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Container(width: 6, height: 6,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    );
                  },
                ),
              ),
            ),
          ),

          // ======= Lista del día seleccionado (sólo en Semana) =======
          if (_format == CalendarFormat.week) ...[
            const SizedBox(height: 12),
            _dayHeader(context, _selectedDay),
            const SizedBox(height: 8),
            ..._buildAppointmentsForDay(cs, _selectedDay),
            if (_buildAppointmentsForDay(cs, _selectedDay).isEmpty)
              Center(
                child: Text('Sin pacientes para este día',
                    style: TextStyle(color: cs.onSurfaceVariant)),
              ),
          ],
        ],
      ),
    );
  }

  // Widgets auxiliares

  String _monthName(DateTime d) {
    const months = [
      'Enero','Febrero','Marzo','Abril','Mayo','Junio',
      'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  Widget _legend(ColorScheme cs, Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label),
    ],
  );

  Widget _dayHeader(BuildContext ctx, DateTime day) {
    final cs = Theme.of(ctx).colorScheme;
    final wd = ['Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'][day.weekday - 1];
    final text = '$wd ${day.day}';
    return Row(
      children: [
        Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const Spacer(),
        IconButton(
          onPressed: () => setState(() => _selectedDay = _dayKey(_selectedDay.subtract(const Duration(days: 1)))),
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          onPressed: () => setState(() => _selectedDay = _dayKey(_selectedDay.add(const Duration(days: 1)))),
          icon: const Icon(Icons.chevron_right),
        ),
        TextButton.icon(
          onPressed: () => setState(() => _selectedDay = _dayKey(DateTime.now())),
          icon: const Icon(Icons.today, size: 18),
          label: const Text('Hoy'),
          style: TextButton.styleFrom(foregroundColor: cs.primary),
        ),
      ],
    );
  }

  List<Widget> _buildAppointmentsForDay(ColorScheme cs, DateTime day) {
    final items = _eventsOf(day);
    items.sort((a, b) => a.start.compareTo(b.start));
    return items.map((a) => _AppointmentCard(a, cs)).toList();
  }
}

// ===== Tipos y widgets de cita =====

enum BusyLevel { none, low, medium, high }

class Appointment {
  final String patient;
  final String note;
  final DateTime start;
  final DateTime end;
  final bool ok;
  Appointment({
    required this.patient,
    required this.note,
    required this.start,
    required this.end,
    required this.ok,
  });
}

class _AppointmentCard extends StatelessWidget {
  final Appointment a;
  final ColorScheme cs;
  const _AppointmentCard(this.a, this.cs);

  @override
  Widget build(BuildContext context) {
    final time =
        '${_hhmm(a.start)} - ${_hhmm(a.end)}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(radius: 22, child: Text(a.patient[0])),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.patient, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(a.note, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              const SizedBox(height: 6),
              Text(time, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            ]),
          ),
          Icon(a.ok ? Icons.check_circle : Icons.radio_button_unchecked,
              color: a.ok ? Colors.green : cs.onSurfaceVariant),
        ],
      ),
    );
  }

  static String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}