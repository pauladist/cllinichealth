// lib/views/screens/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/clinic_shell.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final user = FirebaseAuth.instance.currentUser;
    final doctorId = 'doctor'; // mismo que usás en la Function

    final query = FirebaseFirestore.instance
        .collection('notifications')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true);

    return ClinicShell(
      current: BottomTab.notifications,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar las notificaciones',
                style: TextStyle(color: cs.error),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No hay notificaciones recientes.\n\n'
                    'Cuando haya recordatorios de turnos, aparecerán acá.',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final title = data['title'] as String? ?? 'Notificación';
              final body = data['body'] as String? ?? '';
              final read = data['read'] as bool? ?? false;
              final ts = data['createdAt'] as Timestamp?;
              final createdAt = ts?.toDate();

              String subtitle = body;
              if (createdAt != null) {
                final hh = createdAt.hour.toString().padLeft(2, '0');
                final mm = createdAt.minute.toString().padLeft(2, '0');
                subtitle += '\n$hh:$mm';
              }

              return Card(
                child: ListTile(
                  leading: Icon(
                    read ? Icons.notifications_none : Icons.notifications,
                    color: read ? cs.outline : cs.primary,
                  ),
                  title: Text(title),
                  subtitle: Text(
                    subtitle,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // marcar como leída
                    doc.reference.update({'read': true});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
