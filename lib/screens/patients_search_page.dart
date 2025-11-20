import 'package:flutter/material.dart';
import '../widgets/clinic_shell.dart';

// ===== Datos de ejemplo (podés reemplazar por tu backend luego)
final _allPatients = <Map<String, String>>[
  {'nombre': 'Margaret', 'apellido': 'Osborn'},
  {'nombre': 'Prue', 'apellido': 'Halliwell'},
  {'nombre': 'Juan', 'apellido': 'Pérez'},
  {'nombre': 'María', 'apellido': 'López'},
  {'nombre': 'Carlos', 'apellido': 'Gómez'},
  {'nombre': 'Zoila', 'apellido': 'Delgado'},
  {'nombre': 'Jhon', 'apellido': 'Doe'},
];

class PatientsSearchPage extends StatefulWidget {
  const PatientsSearchPage({super.key});

  @override
  State<PatientsSearchPage> createState() => _PatientsSearchPageState();
}

class _PatientsSearchPageState extends State<PatientsSearchPage> {
  final _queryCtrl = TextEditingController();
  List<Map<String, String>> _results = List.from(_allPatients);

  @override
  void initState() {
    super.initState();
    _queryCtrl.addListener(_onQueryChange);
  }

  @override
  void dispose() {
    _queryCtrl.removeListener(_onQueryChange);
    _queryCtrl.dispose();
    super.dispose();
  }

  // ——— Búsqueda: sin acentos, case-insensitive y multi-palabra
  void _onQueryChange() {
    final q = _normalize(_queryCtrl.text.trim());
    if (q.isEmpty) {
      setState(() => _results = List.from(_allPatients));
      return;
    }

    final tokens = q.split(RegExp(r'\s+')); // admite “mar lo”, etc.
    bool matches(Map<String, String> p) {
      final full = _normalize('${p['nombre']} ${p['apellido']}');
      // cada token debe existir en el “full” normalizado
      return tokens.every((t) => full.contains(t));
    }

    setState(() => _results = _allPatients.where(matches).toList());
  }

  // Normaliza: quita tildes/diacríticos y pasa a minúsculas
  String _normalize(String s) {
    final lower = s.toLowerCase();
    // reemplazos rápidos comunes (sin usar paquetes)
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          Expanded(
            child: _results.isEmpty
                ? _EmptyState(onClear: _clear)
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, i) {
                final p = _results[i];
                final name = '${p['nombre']} ${p['apellido']}';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primaryContainer.withOpacity(.6),
                    child: Text(name[0]),
                  ),
                  title: _HighlightedText(
                    text: name,
                    query: _queryCtrl.text,
                    highlightColor: cs.primary,
                  ),
                  subtitle: const Text('Paciente'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // acá podrías abrir la ficha clínica del paciente
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Abrir ficha: $name')),
                    );
                  },
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 8),
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
          Text('Sin resultados', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Probá con otro nombre o apellido', style: TextStyle(color: cs.onSurfaceVariant)),
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

  // resalta coincidencias (sin acentos y case-insensitive)
  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) return Text(text);

    String normalize(String s) {
      final lower = s.toLowerCase();
      const from = 'áàäâãÁÀÄÂÃéèëêÉÈËÊíìïîÍÌÏÎóòöôõÓÒÖÔÕúùüûÚÙÜÛñÑ';
      const to   = 'aaaaaAAAAAeeeeEEEEiiiiIIIIoooooOOOOOuuuuUUUUnN';
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
      ranges.add(TextSpan(
        text: text.substring(index, index + normQuery.length),
        style: TextStyle(
          backgroundColor: highlightColor.withOpacity(.2),
          color: highlightColor,
          fontWeight: FontWeight.w700,
        ),
      ));
      start = index + normQuery.length;
      index = normText.indexOf(normQuery, start);
    }
    ranges.add(TextSpan(text: text.substring(start)));

    return RichText(text: TextSpan(style: DefaultTextStyle.of(context).style, children: ranges));
  }
}
