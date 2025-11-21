import 'package:flutter/material.dart';
import '../widgets/clinic_shell.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClinicShell(
      current: BottomTab.settings,
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),

          // Perfil
          ListTile(
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.person, color: cs.primary),
            ),
            title: const Text("Mi perfil"),
            subtitle: const Text("Datos del profesional"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),

          const Divider(height: 32),

          // Notificaciones
          ListTile(
            leading: Icon(Icons.notifications, color: cs.primary),
            title: const Text("Notificaciones"),
            subtitle: const Text("Preferencias de recordatorios"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),

          const Divider(height: 32),

          // Cerrar sesión (más adelante se conecta con Firebase Auth)
          ListTile(
            leading: Icon(Icons.logout, color: cs.error),
            title: const Text(
              "Cerrar sesión",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Cerrar sesión (todavía no conectado)"),
                ),
              );

              // Más adelante:
              // await AuthController().logout();
            },
          ),
        ],
      ),
    );
  }
}
