import 'package:flutter/material.dart';
import '../main.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true, _loading = false;

  @override
  void dispose() { _userCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _doLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 450));
    if (_userCtrl.text.trim() == AppAuth.user && _passCtrl.text == AppAuth.pass) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario o contraseña incorrectos')));
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Acceder'), centerTitle: true),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const SizedBox(height: 6),
        Center(child: Column(children: [
          Image.asset('assets/images/icon.jpg', width: 72, height: 72),
          const SizedBox(height: 10),
          Text('ClinicHealth', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 4),
          Text('Woop woop woop!', style: TextStyle(color: cs.onSurfaceVariant)),
        ])),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(children: [
            Align(alignment: Alignment.centerLeft, child: Text('Tu email', style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface))),
            const SizedBox(height: 8),
            TextFormField(
              controller: _userCtrl,
              decoration: const InputDecoration(hintText: 'admin', prefixIcon: Icon(Icons.person_outline)),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresá el correo';
                }

                final email = v.trim();
                // Debe contener @, .com, gmail y mínimo 3 letras
                final emailRegex = RegExp(r'^[a-zA-Z]{3,}.*@(gmail\.com)$');

                if (!emailRegex.hasMatch(email)) {
                  return 'Correo inválido (ej: jhon@gmail.com)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Align(alignment: Alignment.centerLeft, child: Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface))),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: 'Mín. 3 caracteres',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Ingresá la contraseña';
                }
                if (v.length < 5) {
                  return 'Mínimo 5 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _doLogin,
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Iniciar sesión'),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
