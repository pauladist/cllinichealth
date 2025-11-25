import 'package:flutter/material.dart';
import '../widgets/clinic_shell.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClinicShell(
      current: BottomTab.settings,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Foto / ícono principal
            CircleAvatar(
              radius: 48,
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.person, color: cs.primary, size: 48),
            ),

            const SizedBox(height: 20),

            // Nombre del profesional (más adelante, desde Firestore/Auth)
            Text(
              "Dr. John Zoindberg",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Médico clínico",
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
            ),

            const Divider(height: 40),

            // Información general
            ListTile(
              leading: Icon(Icons.badge, color: cs.primary),
              title: const Text("Matrícula profesional"),
              subtitle: const Text("M-12345"),
            ),

            ListTile(
              leading: Icon(Icons.phone, color: cs.primary),
              title: const Text("Teléfono"),
              subtitle: const Text("+54 9 261 555 1234"),
            ),

            ListTile(
              leading: Icon(Icons.email, color: cs.primary),
              title: const Text("Correo"),
              subtitle: const Text("supervisorgeobuild@gmail.com"),
            ),
          ],
        ),
      ),
    );
  }
}
