// lib/views/screens/appointment_new/new_patient_page.dart
import 'package:flutter/material.dart';

import '../../../controllers/patients_controller.dart';
import '../../../models/patient.dart';
import '../../widgets/clinic_shell.dart';
import '../../../models/enums.dart'; // ajustá si BottomTab está en otro lado

class NewPatientPage extends StatefulWidget {
  const NewPatientPage({super.key});

  @override
  State<NewPatientPage> createState() => _NewPatientPageState();
}

class _NewPatientPageState extends State<NewPatientPage> {
  final _formKey = GlobalKey<FormState>();

  final _dniCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _domicilioCtrl = TextEditingController();
  final _birthdateCtrl = TextEditingController(); // solo para mostrar texto

  final _patientsCtrl = PatientsController();
  bool _saving = false;

  DateTime? _selectedBirthDate;
  String? _selectedGender; // "Femenino", "Masculino", "Otro"

  @override
  void dispose() {
    _dniCtrl.dispose();
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _domicilioCtrl.dispose();
    _birthdateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 120); // por las dudas 😅
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(now.year - 30),
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('es', 'AR'),
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthdateCtrl.text =
        '${picked.day.toString().padLeft(2, "0")}/${picked.month.toString().padLeft(2, "0")}/${picked.year}';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná la fecha de nacimiento')),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná el género')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final dni = _dniCtrl.text.trim();
      final nombre = _nombreCtrl.text.trim();
      final apellido = _apellidoCtrl.text.trim();
      final telefono = _telefonoCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final domicilio = _domicilioCtrl.text.trim();

      final patient = Patient(
        id: dni,
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,                 // ya es String (aunque esté vacío)
        domicilio: domicilio,               // obligatorio en el form
        fechaNacimiento: _selectedBirthDate!, // ya validado antes
        genero: _selectedGender!,           // ya validado antes
        email: email,                       // puede venir vacío pero no null
      );

      await _patientsCtrl.create(patient);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente creado correctamente')),
      );

      Navigator.pop(context, patient.id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar paciente: $e')),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(
        title: const Text('Nuevo paciente'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Completá los datos del paciente para crear la ficha y luego asignarle una cita.',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 16),

                // DNI
                TextFormField(
                  controller: _dniCtrl,
                  decoration: const InputDecoration(
                    labelText: 'DNI',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'El DNI es obligatorio';
                    if (v.length < 7) return 'Ingresá un DNI válido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Nombre
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Apellido
                TextFormField(
                  controller: _apellidoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Apellido',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El apellido es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Domicilio
                TextFormField(
                  controller: _domicilioCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Domicilio',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El domicilio es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Fecha de nacimiento
                TextFormField(
                  controller: _birthdateCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de nacimiento',
                    prefixIcon: Icon(Icons.cake_outlined),
                    hintText: 'DD/MM/AAAA',
                  ),
                  onTap: _pickBirthDate,
                ),
                const SizedBox(height: 12),

                // Género
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Género',
                    prefixIcon: Icon(Icons.wc_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Femenino',
                      child: Text('Femenino'),
                    ),
                    DropdownMenuItem(
                      value: 'Masculino',
                      child: Text('Masculino'),
                    ),
                    DropdownMenuItem(
                      value: 'Otro',
                      child: Text('Otro / Prefiere no decir'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedGender = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Seleccioná un género';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Teléfono (opcional)
                TextFormField(
                  controller: _telefonoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono (opcional)',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                // Email (opcional)
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico (opcional)',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.check),
                  label: Text(_saving ? 'Guardando…' : 'Guardar paciente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
