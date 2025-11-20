import 'package:flutter/material.dart';
import '../widgets/clinic_shell.dart';
import '../data/fake_store.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  final store = FakeStore.I;

  /// ids de pacientes abiertos (carpetas expandidas)
  final Set<String> _openIds = {};

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

  void _toggle(String id) {
    setState(() {
      _openIds.contains(id) ? _openIds.remove(id) : _openIds.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final patients = [...store.patients]..sort(
            (a, b) => a.apellido.toLowerCase().compareTo(b.apellido.toLowerCase()));

    return ClinicShell(
      current: BottomTab.module,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('Historial médico'),
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8A3D37), Color(0xFFB0554C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: patients.isEmpty
                    ? [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text('No hay pacientes cargados.'),
                  ),
                ]
                    : patients
                    .map((p) {
                  final abierto = _openIds.contains(p.id);
                  final notes = store.notesOfPatient(p.id);
                  return _PacienteFolder(
                    pacienteNombre: '${p.nombre} ${p.apellido}',
                    pacienteId: p.id,
                    abierto: abierto,
                    onToggle: () => _toggle(p.id),
                    cs: cs,
                    notas: notes,
                  );
                })
                    .expand((w) => [
                  w,
                  const SizedBox(height: 14),
                ])
                    .toList()
                  ..removeLast(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PacienteFolder extends StatelessWidget {
  final String pacienteId;
  final String pacienteNombre;
  final bool abierto;
  final VoidCallback onToggle;
  final ColorScheme cs;
  final List<Consultation> notas;

  const _PacienteFolder({
    required this.pacienteId,
    required this.pacienteNombre,
    required this.abierto,
    required this.onToggle,
    required this.cs,
    required this.notas,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorAccent = cs.primary;

    final tile = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: colorAccent.withOpacity(.12),
            child: Icon(
              abierto ? Icons.folder_open : Icons.folder,
              color: colorAccent,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              pacienteNombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          TextButton.icon(
            onPressed: onToggle,
            icon: Icon(abierto ? Icons.expand_less : Icons.expand_more),
            label: const Text('Ver historial'),
          ),
        ],
      ),
    );

    final contenido = AnimatedCrossFade(
      duration: const Duration(milliseconds: 220),
      crossFadeState:
      abierto ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: const SizedBox.shrink(),
      secondChild: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant.withOpacity(.4)),
        ),
        child: notas.isEmpty
            ? ListTile(
          leading: const Icon(Icons.inbox_outlined),
          title: const Text('Sin consultas registradas'),
          subtitle: Text(
            'Cuando cargues una nota clínica desde una cita con Check-in, aparecerá aquí.',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        )
            : Column(
          children: notas
              .map(
                (n) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.description_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.resumen,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          n.indicaciones.isEmpty
                              ? '—'
                              : n.indicaciones,
                          style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(_ddmmyyyy(n.fecha)),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          )
              .toList(),
        ),
      ),
    );

    return Column(children: [tile, contenido]);
  }

  String _ddmmyyyy(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
