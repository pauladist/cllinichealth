import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/patients_search_page.dart';
import '../screens/settings_page.dart';
import '../screens/notifications_page.dart';
import '../screens/profile_page.dart';

/// Tabs inferiores de la app.
/// `module` se usa para pantallas internas que dependen del Home
/// (ej.: calendario, detalle de citas, etc.) pero queremos que
/// visualmente quede seleccionado el icono de "Inicio".
enum BottomTab {
  settings,
  search,
  home,
  notifications,
  profile,
  module,
}

class ClinicShell extends StatelessWidget {
  final BottomTab current;
  final PreferredSizeWidget? appBar;
  final Widget body;

  const ClinicShell({
    super.key,
    required this.current,
    required this.body,
    this.appBar,
  });

  void _goTo(BuildContext context, BottomTab target) {
    // Si ya estamos en ese tab (o en un módulo que cuelga de Home), no hacemos nada
    if (current == target ||
        (current == BottomTab.module && target == BottomTab.home)) {
      return;
    }

    Widget screen;

    switch (target) {
      case BottomTab.home:
      case BottomTab.module:
        screen = const HomeScreen();
        break;
      case BottomTab.search:
        screen = const PatientsSearchPage();
        break;
      case BottomTab.notifications:
        screen = const NotificationsPage();
        break;
      case BottomTab.settings:
        screen = const SettingsPage();
        break;
      case BottomTab.profile:
        screen = const ProfilePage();
        break;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Para marcar visualmente el botón activo:
    final effective =
    current == BottomTab.module ? BottomTab.home : current;

    final activeColor = cs.primary;
    final inactiveColor = cs.onSurfaceVariant;

    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Settings
              _BottomItem(
                icon: Icons.settings_outlined,
                label: 'Ajustes',
                selected: effective == BottomTab.settings,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => _goTo(context, BottomTab.settings),
              ),
              // Search / Pacientes
              _BottomItem(
                icon: Icons.search,
                label: 'Pacientes',
                selected: effective == BottomTab.search,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => _goTo(context, BottomTab.search),
              ),
              // Home
              _BottomItem(
                icon: Icons.home_filled,
                label: 'Inicio',
                selected: effective == BottomTab.home,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => _goTo(context, BottomTab.home),
              ),
              // Notificaciones
              _BottomItem(
                icon: Icons.notifications_none_rounded,
                label: 'Alertas',
                selected: effective == BottomTab.notifications,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => _goTo(context, BottomTab.notifications),
              ),
              // Perfil (avatar)
              GestureDetector(
                onTap: () => _goTo(context, BottomTab.profile),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor:
                  effective == BottomTab.profile
                      ? activeColor.withOpacity(.15)
                      : cs.surface,
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundImage:
                    AssetImage('assets/images/icon.jpg'),
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

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
