import 'dart:async';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../widgets/clinic_shell.dart';

import '../../controllers/appointments_controller.dart';
import '../../controllers/patients_controller.dart';
import '../../models/appointment.dart';
import '../../models/patient.dart';
import '../../models/enums.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _apptsCtrl = AppointmentsController();
  final _patientsCtrl = PatientsController();

  StreamSubscription<List<Appointment>>? _apptsSub;
  StreamSubscription<List<Patient>>? _patientsSub;

  CalendarFormat _format = CalendarFormat.month;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  /// citas agrupadas por día (clave = año-mes-día a las 00:00)
  final Map<DateTime, List<Appointment>> _apptsByDay = {};

  /// pacientes indexados por id (dni)
  Map<String, Patient> _patientsById = {};

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;

    _apptsSub = _apptsCtrl.watchAll().listen((appts) {
      setState(() {
        _buildApptsByDay(appts);
        _loading = false;
      });
    });

    _patientsSub = _patientsCtrl.watchAll().listen((patients) {
      setState(() {
        _patientsById = {for (final p in patients) p.id: p};
      });
    });
  }

  @override
  void dispose() {
    _apptsSub?.cancel();
    _patientsSub?.cancel();
    super.dispose();
  }

  void _buildApptsByDay(List<Appointment> appts) {
    _apptsByDay.clear();

    for (final a in appts) {
      final key = DateTime(a.dateTime.year, a.dateTime.month, a.dateTime.day);
      _apptsByDay.putIfAbsent(key, () => []);
      _apptsByDay[key]!.add(a);
    }
  }

  List<Appointment> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _apptsByDay[key] ?? const [];
  }

  void _goToday() {
    final now = DateTime.now();
    setState(() {
      _focusedDay = DateTime(now.year, now.month, now.day);
      _selectedDay = _focusedDay;
      _format = CalendarFormat.week;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final monthTitle = _monthName(_focusedDay);
    final eventsToday = _getEventsForDay(_selectedDay);

    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(
        title: Text('Calendario — $monthTitle'),
        actions: [
          IconButton(
            tooltip: 'Hoy',
            onPressed: _goToday,
            icon: const Icon(Icons.today),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(cs),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : eventsToday.isEmpty
                ? const Center(child: Text('No hay citas para este día'))
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: eventsToday.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final a = eventsToday[i];
                final patient = _patientsById[a.patientId];
                return _ApptTile(appt: a, patient: patient);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(ColorScheme cs) {
    return TableCalendar<Appointment>(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      calendarFormat: _format,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Mes',
        CalendarFormat.week: 'Semana',
      },
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() => _format = format);
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      eventLoader: _getEventsForDay,
      calendarStyle: CalendarStyle(
        markerDecoration: BoxDecoration(
          color: cs.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: cs.primary.withOpacity(.2),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: cs.primary,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
      ),
    );
  }

  String _monthName(DateTime d) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

// ------- Tile de cita en lista inferior -------

class _ApptTile extends StatelessWidget {
  final Appointment appt;
  final Patient? patient;

  const _ApptTile({required this.appt, required this.patient});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final name = patient?.fullName ?? 'Paciente';
    final time = _hhmm(appt.dateTime);
    final statusUI = _statusUI(appt.status);

    return Container(
      padding: const EdgeInsets.all(12),
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
            child: Text(name.isNotEmpty ? name[0] : '?'),
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
                const SizedBox(height: 4),
                Text(
                  'Hora: $time',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusUI.color.withOpacity(.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusUI.label,
                        style: TextStyle(
                          color: statusUI.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: cs.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  static String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static _StatusUI _statusUI(ApptStatus st) {
    switch (st) {
      case ApptStatus.scheduled:
        return _StatusUI('Programada', const Color(0xFF607D8B));
      case ApptStatus.checkin:
        return _StatusUI('Check-in', const Color(0xFFF57C00));
      case ApptStatus.cancelled:
        return _StatusUI('Cancelada', const Color(0xFFC62828));
    }
  }
}

class _StatusUI {
  final String label;
  final Color color;
  const _StatusUI(this.label, this.color);
}
