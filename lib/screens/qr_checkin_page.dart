import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/clinic_shell.dart';
import '../data/fake_store.dart';


class QrCheckinPage extends StatefulWidget {
  const QrCheckinPage({super.key});

  @override
  State<QrCheckinPage> createState() => _QrCheckinPageState();
}

class _QrCheckinPageState extends State<QrCheckinPage> {
  bool _found = false;
  String? _lastCode;

  void _onDetect(BarcodeCapture capture) {
    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

// Suponemos que el QR contiene el ID de la CITA (Appointment.id)
    final store = FakeStore.I;
    final match = store.appointments.where((a) => a.id == code).toList();

    final ok = match.isNotEmpty && match.first.status != ApptStatus.cancelled;
    if (ok) {
      store.setApptStatus(code, ApptStatus.checkin);
    }

// UI de confirmación
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: Icon(ok ? Icons.check_circle : Icons.error,
            color: ok ? Colors.green : Colors.red, size: 48),
        title: Text(ok ? 'Paciente verificado' : 'QR inválido'),
        content: Text(ok
            ? 'Se marcó Check-in para la cita $code'
            : 'No se encontró una cita válida con ese código.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
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
          Text('Apunte la cámara al código QR del paciente',
              style: TextStyle(color: cs.onSurfaceVariant)),
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
          if (_lastCode != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Último código: $_lastCode',
                  style: TextStyle(color: cs.onSurfaceVariant)),
            ),
          ElevatedButton(
            onPressed: () {
              // simula haber escaneado el id de una cita existente
              final store = FakeStore.I;
              if (store.appointments.isNotEmpty) {
                final id = store.appointments.first.id;
                _onDetect(BarcodeCapture(barcodes: [Barcode(rawValue: id)], image: null));
              }
            },
            child: const Text('Simular QR de primera cita'),
          ),
        ],
      ),
    );
  }
}
