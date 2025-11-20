import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/clinic_shell.dart';

class AppNotification {
  final String title;
  final String detail;
  final DateTime createdAt;
  final bool read;

  AppNotification({
    required this.title,
    required this.detail,
    required this.createdAt,
    this.read = false,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with WidgetsBindingObserver {
  final _items = <AppNotification>[];
  Timer? _gcTimer;

  /// Tiempo de vida: 24 horas
  static const _ttl = Duration(hours: 24);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Seed de ejemplo
    final now = DateTime.now();
    _items.addAll([
      // 🔸 Esta queda a 2 minutos de expirar (23:58 hs)
      AppNotification(
        title: 'Recordatorio',
        detail: 'Juan Perez • ayer 09:00',
        createdAt: now.subtract(const Duration(hours: 23, minutes: 58)),
      ),
      // Esta ya debería expirar inmediatamente
      AppNotification(
        title: 'Nuevo mensaje',
        detail: 'Laboratorio listo',
        createdAt: now.subtract(const Duration(hours: 25)),
      ),
      // Esta es reciente
      AppNotification(
        title: 'Recordatorio',
        detail: 'Prue Halliwell • mañana 09:00',
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
    ]);

    _pruneOld(); // limpieza inicial
    // Revisamos seguido para que veas cómo desaparece al minuto 24:00
    _gcTimer = Timer.periodic(const Duration(seconds: 20), (_) => _pruneOld());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gcTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _pruneOld();
  }

  void _pruneOld() {
    final limit = DateTime.now().subtract(_ttl);
    final before = _items.length;
    _items.removeWhere((n) => n.createdAt.isBefore(limit));
    if (mounted && before != _items.length) setState(() {});
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'justo ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    return 'hace ${diff.inDays} d';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClinicShell(
      current: BottomTab.notifications,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            tooltip: 'Limpiar >24h',
            onPressed: _pruneOld,
            icon: const Icon(Icons.auto_delete),
          ),
        ],
      ),
      body: _items.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined, size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: 8),
            Text('Sin notificaciones recientes', style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text('Las notificaciones caducan a las 24 horas automáticamente.',
                style: TextStyle(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final n = _items[i];
          return Dismissible(
            key: ValueKey('${n.title}-${n.createdAt.millisecondsSinceEpoch}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => setState(() => _items.removeAt(i)),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_active_outlined),
                title: Text(n.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${n.detail}  •  ${_timeAgo(n.createdAt)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}
