import 'dart:async';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import '../widgets/clinic_shell.dart';

import '../../controllers/patients_controller.dart';
import '../../controllers/consultations_controller.dart';
import '../../models/patient.dart';
import '../../models/consultation.dart';

class HistorialPage extends StatefulWidget {
  /// Si viene desde la ficha de un paciente, abrimos directamente esa carpeta.
  final String? patientIdToOpen;

  const HistorialPage({super.key, this.patientIdToOpen});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}


class _HistorialPageState extends State<HistorialPage> {
  final _patientsCtrl = PatientsController();
  final _consultationsCtrl = ConsultationsController();

  StreamSubscription<List<Patient>>? _patientsSub;

  List<Patient> _patients = [];
  bool _loading = true;

  final Set<String> _openIds = {};

  @override
  void initState() {
    super.initState();
    _listenPatients();
  }

  void _listenPatients() {
    _patientsSub?.cancel();
    _patientsSub = _patientsCtrl.watchAll().listen(
          (patients) {
        setState(() {
          _patients = patients;
          _loading = false;

          if (widget.patientIdToOpen != null &&
              _patients.any((p) => p.id == widget.patientIdToOpen)) {
            _openIds
              ..clear()
              ..add(widget.patientIdToOpen!);
          }
        });
      },
      onError: (e) {
        debugPrint('Error escuchando pacientes: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error cargando historial clínico'),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _patientsSub?.cancel();
    super.dispose();
  }

  void _toggle(String id) {
    setState(() {
      if (_openIds.contains(id)) {
        _openIds.clear();
      } else {
        _openIds
          ..clear()
          ..add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(
        title: const Text('Historial clínico'),
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _patients.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Todavía no hay pacientes con historial clínico.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      )
          : ListView.separated(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemBuilder: (context, index) {
          final p = _patients[index];
          final abierto = _openIds.contains(p.id);

          return _PacienteHistorialTile(
            patient: p,
            abierto: abierto,
            onToggle: () => _toggle(p.id),
            cs: cs,
            consultationsCtrl: _consultationsCtrl,
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: _patients.length,
      ),
    );
  }
}

class _PacienteHistorialTile extends StatelessWidget {
  final Patient patient;
  final bool abierto;
  final VoidCallback onToggle;
  final ColorScheme cs;
  final ConsultationsController consultationsCtrl;

  const _PacienteHistorialTile({
    required this.patient,
    required this.abierto,
    required this.onToggle,
    required this.cs,
    required this.consultationsCtrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Tarjeta del paciente
    final header = InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: Text(
                patient.nombre.isNotEmpty
                    ? patient.nombre[0].toUpperCase()
                    : '?',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'DNI: ${patient.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              abierto
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );

    // Contenido: línea vertical + carpetitas
    final contenido = AnimatedCrossFade(
      duration: const Duration(milliseconds: 220),
      crossFadeState:
      abierto ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: const SizedBox.shrink(),
      secondChild: Container(
        margin: const EdgeInsets.only(left: 8, right: 4, top: 6),
        padding: const EdgeInsets.only(left: 12, top: 4, bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: cs.primary.withOpacity(0.25),
              width: 2,
            ),
          ),
        ),
        child: _ConsultasList(
          patient: patient,
          consultationsCtrl: consultationsCtrl,
          cs: cs,
        ),
      ),
    );

    return Column(
      children: [
        header,
        contenido,
      ],
    );
  }
}

class _ConsultasList extends StatelessWidget {
  final Patient patient;
  final ConsultationsController consultationsCtrl;
  final ColorScheme cs;

  const _ConsultasList({
    required this.patient,
    required this.consultationsCtrl,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Consultation>>(
      stream: consultationsCtrl.watchByPatient(patient.id),
      builder: (context, snapshot) {
        final notas = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (notas.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'No hay consultas registradas para este paciente.',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          );
        }

        return Column(
          children: [
            const SizedBox(height: 4),
            ...notas.map(
                  (c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _ConsultaItem(
                  patient: patient,
                  consulta: c,
                  cs: cs,
                  consultationsCtrl: consultationsCtrl,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ConsultaItem extends StatelessWidget {
  final Patient patient;
  final Consultation consulta;
  final ColorScheme cs;
  final ConsultationsController consultationsCtrl;

  const _ConsultaItem({
    required this.patient,
    required this.consulta,
    required this.cs,
    required this.consultationsCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final fecha = consulta.fecha;
    final fechaStr = DateFormat('dd/MM/yyyy').format(fecha);
    final horaStr = DateFormat('HH:mm').format(fecha);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ConsultaDetailPage(
              patient: patient,
              consulta: consulta,
              consultationsCtrl: consultationsCtrl,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withOpacity(.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Iconito médico redondo
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medical_information_outlined,
                color: cs.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$fechaStr • $horaStr',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    consulta.resumen.isEmpty
                        ? 'Consulta sin título'
                        : consulta.resumen,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  if (consulta.indicaciones.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      consulta.indicaciones,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class ConsultaDetailPage extends StatefulWidget {
  final Patient patient;
  final Consultation consulta;
  final ConsultationsController consultationsCtrl;

  const ConsultaDetailPage({
    super.key,
    required this.patient,
    required this.consulta,
    required this.consultationsCtrl,
  });

  @override
  State<ConsultaDetailPage> createState() => _ConsultaDetailPageState();
}

class _ConsultaDetailPageState extends State<ConsultaDetailPage> {
  late TextEditingController _resumenCtrl;
  late TextEditingController _indicCtrl;
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _resumenCtrl = TextEditingController(text: widget.consulta.resumen);
    _indicCtrl = TextEditingController(text: widget.consulta.indicaciones);
  }

  @override
  void dispose() {
    _resumenCtrl.dispose();
    _indicCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final updated = Consultation(
        id: widget.consulta.id,
        appointmentId: widget.consulta.appointmentId,
        patientId: widget.consulta.patientId,
        resumen: _resumenCtrl.text.trim(),
        indicaciones: _indicCtrl.text.trim(),
        fecha: widget.consulta.fecha,
      );

      await widget.consultationsCtrl.update(widget.patient.id, updated);

      if (!mounted) return;
      setState(() {
        _editing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota clínica actualizada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    if (_saving) return;

    final cs = Theme.of(context).colorScheme;

    // 🔹 Diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar nota clínica'),
        content: const Text(
          '¿Estás segura de que querés eliminar esta nota clínica del historial?\n'
              'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: cs.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await widget.consultationsCtrl
          .delete(widget.patient.id, widget.consulta.id);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota clínica eliminada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fecha = widget.consulta.fecha;
    final fechaStr = DateFormat('dd/MM/yyyy').format(fecha);
    final horaStr = DateFormat('HH:mm').format(fecha);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nota clínica'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Paciente + icono médico
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      widget.patient.nombre.isNotEmpty
                          ? widget.patient.nombre[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.patient.fullName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'DNI: ${widget.patient.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.medical_services_outlined,
                    color: cs.primary,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Fecha y hora de la consulta
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 20,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$fechaStr • $horaStr',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------- TARJETA PRINCIPAL DE LA NOTA ----------
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    color: cs.surface,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Encabezado de la tarjeta
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: cs.primary.withOpacity(.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.description_outlined,
                                  color: cs.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Resumen de la consulta',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Historial médico de ${widget.patient.nombre}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Diagnóstico
                          Text(
                            'Diagnóstico',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _editing
                              ? TextField(
                            controller: _resumenCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          )
                              : Text(
                            _resumenCtrl.text.isEmpty
                                ? 'Sin información'
                                : _resumenCtrl.text,
                            style: TextStyle(color: cs.onSurface),
                          ),

                          const SizedBox(height: 16),

                          // Indicaciones
                          Text(
                            'Indicaciones',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _editing
                              ? TextField(
                            controller: _indicCtrl,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          )
                              : Text(
                            _indicCtrl.text.isEmpty
                                ? 'Sin indicaciones registradas'
                                : _indicCtrl.text,
                            style: TextStyle(color: cs.onSurface),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Botones: editar/guardar + eliminar
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _saving
                          ? null
                          : () {
                        if (_editing) {
                          _save();
                        } else {
                          setState(() => _editing = true);
                        }
                      },
                      icon: _saving
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : Icon(_editing ? Icons.save : Icons.edit),
                      label: Text(
                          _editing ? 'Guardar cambios' : 'Editar nota clínica'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _saving ? null : _delete,
                    icon: const Icon(Icons.delete_outline),
                    color: cs.error,
                    tooltip: 'Eliminar nota',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
