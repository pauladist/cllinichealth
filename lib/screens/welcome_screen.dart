import 'package:flutter/material.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 280,
              width: double.infinity,
              child: Stack(children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withOpacity(.95),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(56)),
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, .9),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 24, offset: const Offset(0, 8))],
                    ),
                    child: Image.asset('assets/images/icon.jpg', width: 72, height: 72, fit: BoxFit.contain),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Text('ClinicHealth', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: cs.onSurface)),
            const SizedBox(height: 8),
            Text('Dr. John Zoindberg \nWoop woop woop!', textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Iniciar sesión'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
