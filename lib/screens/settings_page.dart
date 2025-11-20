import 'package:flutter/material.dart';
import '../widgets/clinic_shell.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClinicShell(
      current: BottomTab.settings,
      appBar: AppBar(
        title: const Text('Ajustes'),
        centerTitle: true,
        leading: const Icon(Icons.settings), // 🛠 Icono de la tuerquita
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),

          // ====== Apariencia ======
          Text('Apariencia',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Modo oscuro'),
            subtitle: const Text('Cambia el tema de la aplicación'),
            value: _darkMode,
            activeColor: cs.primary,
            onChanged: (v) {
              setState(() => _darkMode = v);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Demo: el tema se cambiaría desde main.dart',
                  ),
                ),
              );
            },
          ),
          const Divider(height: 24),

          // ====== Notificaciones ======
          Text('Notificaciones',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Activar notificaciones'),
            subtitle: const Text('Recibir alertas y recordatorios'),
            value: _notificationsEnabled,
            activeColor: cs.primary,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          const Divider(height: 24),

          // ====== Información ======
          Text('Información',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.info_outline, color: cs.primary),
            title: const Text('Versión'),
            subtitle: Text('ClinicHealth v1.0.0',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: cs.primary),
            title: const Text('Política de privacidad'),
            subtitle:
            Text('Términos y condiciones de uso',
                style: TextStyle(color: cs.onSurfaceVariant)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Abrir enlace a política de privacidad...')),
              );
            },
          ),
          const Divider(height: 24),

          // ====== Cierre de sesión ======
          Center(
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sesión cerrada')),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: cs.primary.withOpacity(.85),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}