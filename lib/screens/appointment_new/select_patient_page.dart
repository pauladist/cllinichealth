import 'package:flutter/material.dart';
import '../../widgets/clinic_shell.dart';
import '../../data/fake_store.dart';

class SelectPatientPage extends StatefulWidget {
  const SelectPatientPage({super.key});

  @override
  State<SelectPatientPage> createState() => _SelectPatientPageState();
}

class _SelectPatientPageState extends State<SelectPatientPage> {
  final store = FakeStore.I;
  final q = TextEditingController();
  List<Patient> list = [];

  @override
  void initState() {
    super.initState();
    list = store.patients;
  }

  void _filter(String s) {
    final t = s.trim().toLowerCase();
    setState(()=> list = store.patients.where((p){
      final n = '${p.nombre} ${p.apellido}'.toLowerCase();
      return n.contains(t);
    }).toList());
  }

  void _addPatientDialog() async {
    final name = TextEditingController();
    final last = TextEditingController();
    await showDialog(context: context, builder: (_)=> AlertDialog(
      title: const Text('Nuevo paciente'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText:'Nombre')),
        const SizedBox(height: 8),
        TextField(controller: last, decoration: const InputDecoration(labelText:'Apellido')),
      ]),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: (){
          if (name.text.trim().isNotEmpty) {
            store.addPatient(name.text.trim(), last.text.trim());
            setState(()=> list = store.patients);
          }
          Navigator.pop(context);
        }, child: const Text('Guardar')),
      ],
    ));
  }

  void _next(Patient p){
    Navigator.pushNamed(context, '/appt/select-date', arguments: p.id);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(title: const Text('Elegir paciente')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16,12,16,8),
            child: TextField(
              controller: q,
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o apellido…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: cs.primaryContainer.withOpacity(.25),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_,i){
                final p = list[i];
                return ListTile(
                  leading: CircleAvatar(child: Text(p.nombre[0])),
                  title: Text(p.fullName),
                  subtitle: const Text('Paciente'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: ()=> _next(p),
                );
              },
              separatorBuilder: (_,__)=> const Divider(height: 8),
              itemCount: list.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: OutlinedButton.icon(
              onPressed: _addPatientDialog,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Registrar nuevo paciente'),
            ),
          ),
        ],
      ),
    );
  }
}
