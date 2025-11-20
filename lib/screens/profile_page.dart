import 'package:flutter/material.dart';
import '../widgets/clinic_shell.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClinicShell(
      current: BottomTab.profile,
      appBar: AppBar(title: const Text('Mi perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: const AssetImage('assets/images/icon.jpg'),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Dr. John Zoidberg', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Text('ClinicHealth', style: TextStyle(color: cs.onSurfaceVariant)),
            ]),
          ]),
          const SizedBox(height: 16),
          const ListTile(leading: Icon(Icons.mail), title: Text('zoidberg@clinichealth.com')),
          const ListTile(leading: Icon(Icons.phone), title: Text('555-1234')),
        ],
      ),
    );
  }
}
