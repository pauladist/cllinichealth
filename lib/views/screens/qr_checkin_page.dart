import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../widgets/clinic_shell.dart';
import '../../controllers/appointments_controller.dart';
import 'package:clinichealth/models/appointment.dart';
import 'package:clinichealth/models/enums.dart';

class QrCheckinPage extends StatefulWidget {
  const QrCheckinPage({super.key});

  @override
  State<QrCheckinPage> createState() => _QrCheckinPageState();
}

class _QrCheckinPageState extends State<QrCheckinPage> {
  final _appointmentsCtrl = AppointmentsController();

  bool _processing = false;
  String? _lastCode;

  void _onDetect(BarcodeCapture capture) {
    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    _handleCode(code.trim());
  }

  Future<void> _handleCode(String code) async {
    if (_processing) return;
    if (_lastCode == code) return; // evita procesar mil veces el mismo QR

    setState(() {
      _processing = true;
      _lastCode = code;
    });

    bool ok = false;
    String message;

    try {
      final appt = await _appointmentsCtrl.getById(code);

      if (appt == null) {
        ok = false;
        message = 'No se encontró una cita con el código $code.';
      } else if (appt.status == ApptStatus.cancelled) {
        ok = false;
        message = 'La cita con código $code está cancelada.';
      } else if (appt.status == ApptStatus.checkin) {
        ok = false;
        message = 'Esta cita ya tiene registrado el Check-in.';
      } else {
        // marcamos la cita como checkin
        final updated = Appointment(
          id: appt.id,
          patientId: appt.patientId,
          dateTime: appt.dateTime,
          motivo: appt.motivo,
          status: ApptStatus.checkin,
        );

        await _appointmentsCtrl.update(updated);
        ok = true;
        message = 'Se marcó Check-in para la cita $code.';
      }
    } catch (e) {
      ok = false;
      message = 'Ocurrió un error al verificar el código: $e';
    }

    if (!mounted) return;

    setState(() {
      _processing = false;
    });

    // UI de confirmación
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          icon: Icon(
            ok ? Icons.check_circle : Icons.error,
            color: ok ? Colors.green : cs.error,
            size: 48,
          ),
          title: Text(ok ? 'Paciente verificado' : 'QR inválido'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _simulateFirstAppointment() async {
    try {
      final list = await _appointmentsCtrl.watchAll().first;
      if (list.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay citas en el sistema para simular.'),
          ),
        );
        return;
      }

      final first = list.first;
      await _handleCode(first.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al simular QR: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClinicShell(
      current: BottomTab.module,
      appBar: AppBar(title: const Text('Check-in QR')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            'Apunte la cámara al código QR del paciente',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.primary, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: MobileScanner(
                  controller: MobileScannerController(
                    detectionSpeed: DetectionSpeed.normal,
                    facing: CameraFacing.back,
                  ),
                  onDetect: _onDetect,
                ),
              ),
            ),
          ),
          if (_processing) ...[
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: CircularProgressIndicator(),
            ),
          ],
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextButton(
              onPressed: _simulateFirstAppointment,
              child: const Text('Simular QR de primera cita'),
            ),
          ),
        ],
      ),
    );
  }
}
