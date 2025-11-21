import 'package:flutter/material.dart';

import '../widgets/clinic_shell.dart';
import '../widgets/menu_tile_wide.dart';

import 'calendar_page.dart';
import 'citas_page.dart';
import 'qr_checkin_page.dart';
import 'historial_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClinicShell(
      current: BottomTab.home,
      appBar: AppBar(
        title: const Text('Inicio'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Encabezado
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(.9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_hospital_rounded,
                    color: cs.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Bienvenido/a a ClinicHealth\nGestione turnos, historial y calendario del consultorio.',
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // BLOQUES PRINCIPALES
          MenuTileWide(
            icon: Icons.calendar_month_rounded,
            title: 'Calendario',
            subtitle: 'Visualice sus turnos por día',
            buttonText: 'Ver calendario',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarPage()),
              );
            },
          ),
          const SizedBox(height: 14),

          MenuTileWide(
            icon: Icons.edit_calendar,
            title: 'Turnos médicos',
            subtitle: 'Cree y edite citas médicas',
            buttonText: 'Ir a citas',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CitasPage()),
              );
            },
          ),
          const SizedBox(height: 14),

          MenuTileWide(
            icon: Icons.qr_code_2,
            title: 'Check-in con QR',
            subtitle: 'Valide la asistencia al turno',
            buttonText: 'Abrir lector QR',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrCheckinPage()),
              );
            },
          ),
          const SizedBox(height: 14),

          MenuTileWide(
            icon: Icons.folder_open,
            title: 'Historial médico',
            subtitle: 'Consultas y antecedentes',
            buttonText: 'Ver historial',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistorialPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
