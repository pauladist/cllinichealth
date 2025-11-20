import 'package:flutter/material.dart';
import '../widgets/clinic_shell.dart';
import '../data/fake_store.dart';

class CitasPage extends StatefulWidget {
  const CitasPage({super.key});

  @override
  State<CitasPage> createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> {
  final store = FakeStore.I;

  @override
  void initState() {
    super.initState();
    store.addListener(_onChanged);
  }

  @override
  void dispose() {
    store.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _newAppointment() {
    Navigator.pushNamed(context, '/appt/select-patient');
  }

  Future<void> _confirmCancel(Appointment a) async {
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(.4),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: cs.primary, size: 34),
            ),
            const SizedBox(height: 14),
            const Text('Cancelar cita',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              '¿Seguro que querés cancelar esta cita?\n\n'
                  '${_ddmmyy(a.start)}  •  ${_hhmm(a.start)}–${_hhmm(a.end)}',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sí'),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      store.setApptStatus(a.id, ApptStatus.cancelled);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita cancelada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = store.upcoming();

    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(
        title: const Text('Citas'),
        actions: [IconButton(onPressed: _newAppointment, icon: const Icon(Icons.add))],
      ),
      body: list.isEmpty
          ? const Center(child: Text('Sin citas próximas'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final a = list[i];
          final p = store.patientById(a.patientId)!;
          final status = _statusUI(a.status);
          final cs = Theme.of(context).colorScheme;

          // estilos compactos para que no desborde
          final compact = ButtonStyle(
            visualDensity: VisualDensity.compact,
            padding: const MaterialStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: cs.primaryContainer,
                  child: Text(p.nombre[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('${_ddmmyy(a.start)}  •  ${_hhmm(a.start)}–${_hhmm(a.end)}'),
                      Text(a.motivo, style: TextStyle(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 8),

                      // Acciones
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Chip(
                            label: Text(status.label),
                            backgroundColor: status.color.withOpacity(.15),
                            labelStyle: TextStyle(color: status.color),
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),

                          // Check-in (si no está cancelada)
                          TextButton.icon(
                            style: compact,
                            onPressed: (a.status == ApptStatus.cancelled)
                                ? null
                                : () => store.setApptStatus(a.id, ApptStatus.checkin),
                            icon: const Icon(Icons.how_to_reg, size: 18),
                            label: const Text('Check-in'),
                          ),

                          // Nota clínica (solo si llegó)
                          OutlinedButton.icon(
                            style: compact,
                            onPressed: (a.status == ApptStatus.checkin)
                                ? () => Navigator.pushNamed(context, '/consulta/new', arguments: a.id)
                                : null,
                            icon: const Icon(Icons.note_add_outlined, size: 18),
                            label: const Text('Nota clínica'),
                          ),

                          // Cancelar (pide confirmación)
                          TextButton.icon(
                            style: compact,
                            onPressed: (a.status == ApptStatus.checkin)
                                ? null // no cancelar si ya llegó
                                : () => _confirmCancel(a),
                            icon: const Icon(Icons.cancel, size: 18),
                            label: const Text('Cancelar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _StatusUI _statusUI(ApptStatus st) {
    switch (st) {
      case ApptStatus.scheduled:
        return _StatusUI('Programada', const Color(0xFF607D8B));
      case ApptStatus.checkin:
        return _StatusUI('Check-in', const Color(0xFFF57C00));
      case ApptStatus.cancelled:
        return _StatusUI('Cancelada', const Color(0xFFC62828));
    }
  }

  String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  String _ddmmyy(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _StatusUI {
  final String label;
  final Color color;
  _StatusUI(this.label, this.color);
}
