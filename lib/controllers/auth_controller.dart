// lib/controllers/auth_controller.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Inicia sesión con email y contraseña
  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Cierra sesión
  Future<void> logout() {
    return _auth.signOut();
  }

  /// Cambios de estado de sesión (por si después querés usarlo)
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
