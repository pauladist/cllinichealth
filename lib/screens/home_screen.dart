import 'package:clinichealth/widgets/clinic_shell.dart';
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 150,
            backgroundColor: cs.primary,
            toolbarHeight: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8A3D37), Color(0xFFB0554C)],
                  ),
                ),
                child: Stack(children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 26,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0, 1.1),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.10), blurRadius: 24, offset: const Offset(0, 8))],
                      ),
                      child: Image.asset('assets/images/icon.jpg', width: 52, height: 52, fit: BoxFit.contain),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
              child: Text('Seleccione la acción que desee realizar:', style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(children: [
                MenuTileWide(
                  icon: Icons.calendar_month, title: 'Visualice su calendario', subtitle: 'Citas por día y mes',
                  buttonText: 'Abrir calendario',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarPage())),
                ),
                const SizedBox(height: 14),
                MenuTileWide(
                  icon: Icons.edit_calendar, title: 'Anote sus citas', subtitle: 'Cree y edite turnos',
                  buttonText: 'Ir a citas',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CitasPage())),
                ),
                const SizedBox(height: 14),
                MenuTileWide(
                  icon: Icons.qr_code_2, title: 'Valide asistencia de turno', subtitle: 'Check-in con código/QR',
                  buttonText: 'Abrir lector QR',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QrCheckinPage())),
                ),
                const SizedBox(height: 14),
                MenuTileWide(
                  icon: Icons.folder_open, title: 'Historial médico', subtitle: 'Estudios y antecedentes',
                  buttonText: 'Ver historial',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistorialPage())),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
