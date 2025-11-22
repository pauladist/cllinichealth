// lib/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/clinic_shell.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import '../../../main.dart' show themeModeNotifier;

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
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          // ---------- MI PERFIL ----------
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: cs.primaryContainer,
                child: Icon(Icons.person, color: cs.onPrimaryContainer),
              ),
              title: const Text('Mi perfil'),
              subtitle: const Text('Datos del profesional'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                );
              },
            ),
          ),

          // ---------- TEMA OSCURO ----------
          Card(
            margin: const EdgeInsets.only(bottom: 32),
            child: SwitchListTile(
              secondary: Icon(
                themeModeNotifier.value == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: cs.primary,
              ),
              title: const Text('Tema oscuro'),
              subtitle:
              const Text('Cambiar entre modo claro y modo oscuro'),
              value: themeModeNotifier.value == ThemeMode.dark,
              onChanged: (bool value) {
                themeModeNotifier.value =
                value ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ),

          // ---------- CERRAR SESIÓN ----------
          ListTile(
            leading: Icon(Icons.logout, color: cs.error),
            title: Text(
              'Cerrar sesión',
              style: TextStyle(color: cs.error),
            ),
            onTap: () async {
              // 1. cerrar sesión en Firebase
              await FirebaseAuth.instance.signOut();

              // 2. navegar al login y limpiar el stack
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
