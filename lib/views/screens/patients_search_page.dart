// lib/views/screens/patients_search_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import '../widgets/clinic_shell.dart';

import '../../controllers/patients_controller.dart';
import '../../models/patient.dart';

class PatientsSearchPage extends StatefulWidget {
  const PatientsSearchPage({super.key});

  @override
  State<PatientsSearchPage> createState() => _PatientsSearchPageState();
}

class _PatientsSearchPageState extends State<PatientsSearchPage> {
  final _queryCtrl = TextEditingController();
  final _patientsCtrl = PatientsController();

  StreamSubscription<List<Patient>>? _sub;

  List<Patient> _allPatients = [];
  List<Patient> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _queryCtrl.addListener(_onQueryChange);

    _sub = _patientsCtrl.watchAll().listen((patients) {
      setState(() {
        _allPatients = patients;
        _applyFilter();
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _queryCtrl.removeListener(_onQueryChange);
    _queryCtrl.dispose();
    _sub?.cancel();
    super.dispose();
  }

  void _onQueryChange() {
    setState(_applyFilter);
  }

  void _applyFilter() {
    final q = _normalize(_queryCtrl.text.trim());
    if (q.isEmpty) {
      _results = List<Patient>.from(_allPatients);
      return;
    }

    final tokens = q.split(RegExp(r'\s+'));
    bool matches(Patient p) {
      final full = _normalize('${p.nombre} ${p.apellido}');
      return tokens.every((t) => full.contains(t));
    }

    _results = _allPatients.where(matches).toList();
  }

  String _normalize(String s) {
    final lower = s.toLowerCase();
    const from = 'áàäâãÁÀÄÂÃéèëêÉÈËÊíìïîÍÌÏÎóòöôõÓÒÖÔÕúùüûÚÙÜÛñÑ';
    const to   = 'aaaaaAAAAAeeeeEEEEiiiiIIIIoooooOOOOOuuuuUUUUnN';
    var out = lower;
    for (int i = 0; i < from.length; i++) {
      out = out.replaceAll(from[i], to[i]);
    }
    return out;
  }

  void _clear() {
    _queryCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClinicShell(
      current: BottomTab.search,
      appBar: AppBar(title: const Text('Buscar pacientes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _queryCtrl,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Nombre, apellido o letras…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _queryCtrl.text.isEmpty
                    ? null
                    : IconButton(
                  tooltip: 'Limpiar',
                  onPressed: _clear,
                  icon: const Icon(Icons.close_rounded),
                ),
                filled: true,
                fillColor: cs.primaryContainer.withOpacity(.25),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? _EmptyState(onClear: _clear)
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, i) {
                final p = _results[i];
                final name = p.fullName;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                    cs.primaryContainer.withOpacity(.6),
                    child: Text(name.isNotEmpty ? name[0] : '?'),
                  ),
                  title: _HighlightedText(
                    text: name,
                    query: _queryCtrl.text,
                    highlightColor: cs.primary,
                  ),
                  subtitle: Text(
                    'DNI: ${p.id}',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/historial',
                      arguments: p.id, // DNI / id del paciente
                    );
                  },
                );
              },
              separatorBuilder: (_, __) =>
              const Divider(height: 8),
              itemCount: _results.length,
            ),
          ),
        ],
      ),
    );
  }
}

// ====== Widgets auxiliares ======

class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;
  const _EmptyState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 56, color: cs.onSurfaceVariant),
          const SizedBox(height: 10),
          Text(
            'Sin resultados',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Probá con otro nombre',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.clear),
            label: const Text('Limpiar búsqueda'),
          ),
        ],
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final Color highlightColor;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) return Text(text);

    String normalize(String s) {
      final lower = s.toLowerCase();
      const from =
          'áàäâãÁÀÄÂÃéèëêÉÈËÊíìïîÍÌÏÎóòöôõÓÒÖÔÕúùüûÚÙÜÛñÑ';
      const to =
          'aaaaaAAAAAeeeeEEEEiiiiIIIIoooooOOOOOuuuuUUUUnN';
      var out = lower;
      for (int i = 0; i < from.length; i++) {
        out = out.replaceAll(from[i], to[i]);
      }
      return out;
    }

    final normText = normalize(text);
    final normQuery = normalize(query.trim());

    final ranges = <TextSpan>[];
    int start = 0;
    int index = normText.indexOf(normQuery);
    while (index != -1) {
      if (index > start) {
        ranges.add(TextSpan(text: text.substring(start, index)));
      }
      ranges.add(
        TextSpan(
          text: text.substring(index, index + normQuery.length),
          style: TextStyle(
            backgroundColor: highlightColor.withOpacity(.2),
            color: highlightColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      start = index + normQuery.length;
      index = normText.indexOf(normQuery, start);
    }
    ranges.add(TextSpan(text: text.substring(start)));

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: ranges,
      ),
    );
  }
}
