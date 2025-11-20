import 'package:flutter/material.dart';
import '../../widgets/clinic_shell.dart';
import '../../data/fake_store.dart';

class ReviewConfirmPage extends StatefulWidget {
  const ReviewConfirmPage({super.key});

  @override
  State<ReviewConfirmPage> createState() => _ReviewConfirmPageState();
}

class _ReviewConfirmPageState extends State<ReviewConfirmPage> {
  final store = FakeStore.I;
  final motivoCtrl = TextEditingController();

  late String patientId;
  late DateTime start;
  late DateTime end;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    patientId = args['patientId'];
    start = args['start'];
    end = args['end'];
  }

  void _confirm() {
    store.addAppointment(patientId: patientId, start: start, end: end, motivo: motivoCtrl.text.trim().isEmpty ? 'Consulta' : motivoCtrl.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita creada')));
    Navigator.popUntil(context, (r)=> r.settings.name == '/citas' || r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final p = store.patientById(patientId)!;
    final cs = Theme.of(context).colorScheme;

    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(title: const Text('Confirmar cita')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: CircleAvatar(child: Text(p.nombre[0])),
            title: Text(p.fullName),
            subtitle: const Text('Paciente'),
          ),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.event, text: 'Fecha: ${start.day.toString().padLeft(2,'0')}/${start.month.toString().padLeft(2,'0')}/${start.year}'),
          _InfoRow(icon: Icons.schedule, text: 'Hora: ${_hhmm(start)} – ${_hhmm(end)}'),
          const SizedBox(height: 12),
          TextField(
            controller: motivoCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Motivo/Notas',
              filled: true,
              fillColor: cs.primaryContainer.withOpacity(.15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _confirm,
            icon: const Icon(Icons.check),
            label: const Text('Confirmar cita'),
          ),
        ],
      ),
    );
  }

  String _hhmm(DateTime d) => '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String text;
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon), const SizedBox(width: 8), Expanded(child: Text(text)),
  ]);
}
