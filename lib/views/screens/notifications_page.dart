import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../widgets/clinic_shell.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _permissionGranted = false;
  String? _fcmToken;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final settings =
    await FirebaseMessaging.instance.getNotificationSettings();

    final token = await FirebaseMessaging.instance.getToken();

    setState(() {
      _permissionGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized;
      _fcmToken = token;
      _loading = false;
    });
  }

  Future<void> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    setState(() {
      _permissionGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized;
    });

    // refrescamos token por las dudas
    await _loadStatus();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClinicShell(
      current: BottomTab.settings,
      appBar: AppBar(title: const Text("Notificaciones")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(
                _permissionGranted
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: _permissionGranted ? cs.primary : cs.error,
                size: 30,
              ),
              title: Text(
                _permissionGranted
                    ? 'Notificaciones activadas'
                    : 'Notificaciones desactivadas',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'La app puede recibir recordatorios de turnos.',
              ),
              trailing: !_permissionGranted
                  ? TextButton(
                onPressed: _requestPermission,
                child: const Text('Permitir'),
              )
                  : null,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            const Text(
              'Token FCM del dispositivo',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _fcmToken ?? '(no se pudo obtener el token)',
                style: TextStyle(color: cs.onSurface, fontSize: 13),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            Text(
              'Esta pantalla es solo informativa.\n\n'
                  'Los recordatorios de turnos se envían automáticamente '
                  'desde Firebase Functions 10 minutos antes del turno.',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
