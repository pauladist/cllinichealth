import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/patients_search_page.dart';
import '../screens/settings_page.dart';
import '../screens/notifications_page.dart';
import '../screens/profile_page.dart';

// Agregamos "module" para pantallas que dependen del Home (calendario, citas, etc.)
enum BottomTab { settings, search, home, notifications, profile, module }

class ClinicShell extends StatelessWidget {
  final BottomTab current;
  final PreferredSizeWidget? appBar;
  final Widget body;

  const ClinicShell({
    super.key,
    required this.current,
    this.appBar,
    required this.body,
  });

  void _goHome(BuildContext context) {
    // ⚠️ SIEMPRE navega al Home (aunque el tab actual sea "module")
    if (current == BottomTab.home) return; // ya estás en Home
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
    );
  }

  void _go(BuildContext context, BottomTab tab) {
    if (current == tab) return;
    Widget page;
    switch (tab) {
      case BottomTab.settings: page = const SettingsPage(); break;
      case BottomTab.search: page = const PatientsSearchPage(); break;
      case BottomTab.notifications: page = const NotificationsPage(); break;
      case BottomTab.profile: page = const ProfilePage(); break;
      case BottomTab.home: page = const HomeScreen(); break;
      case BottomTab.module: page = const HomeScreen(); break; // no se usa desde barra
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final active = cs.primary;
    final inactive = cs.onSurfaceVariant;

    Widget buildIcon({
      required Widget icon,
      required String tooltip,
      required VoidCallback onTap,
      required bool isActive,
    }) {
      return InkResponse(
        onTap: onTap,
        radius: 28,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
          child: IconTheme(
            data: IconThemeData(color: isActive ? active : inactive, size: 26),
            child: Tooltip(message: tooltip, child: icon),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: cs.primaryContainer.withOpacity(.35),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 12, offset: const Offset(0, -2))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildIcon(
                icon: const Icon(Icons.settings),
                tooltip: 'Ajustes',
                onTap: () => _go(context, BottomTab.settings),
                isActive: current == BottomTab.settings,
              ),
              buildIcon(
                icon: const Icon(Icons.search_rounded),
                tooltip: 'Buscar pacientes',
                onTap: () => _go(context, BottomTab.search),
                isActive: current == BottomTab.search,
              ),
              // Home: activo solo si estamos realmente en Home
              buildIcon(
                icon: const Icon(Icons.home_rounded),
                tooltip: 'Inicio',
                onTap: () => _goHome(context),
                isActive: current == BottomTab.home,
              ),
              buildIcon(
                icon: const Icon(Icons.notifications_rounded),
                tooltip: 'Notificaciones',
                onTap: () => _go(context, BottomTab.notifications),
                isActive: current == BottomTab.notifications,
              ),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _go(context, BottomTab.profile),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: current == BottomTab.profile ? active.withOpacity(.2) : cs.surface,
                    backgroundImage: const AssetImage('assets/images/icon.jpg'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
