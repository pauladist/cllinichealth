import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

// VIEWS
import 'views/screens/welcome_screen.dart';
import 'views/screens/citas_page.dart';
import 'views/screens/appointment_new/select_patient_page.dart';
import 'views/screens/appointment_new/select_date_page.dart';
import 'views/screens/appointment_new/select_slot_page.dart';
import 'views/screens/appointment_new/review_confirm_page.dart';
import 'views/screens/consultas/new_consulta_page.dart';

/// -------------------------
/// FCM BACKGROUND HANDLER
/// -------------------------
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Podés loguear algo si querés
  debugPrint('📩 Mensaje FCM en background: ${message.messageId}');
}

/// Inicializar Firebase Messaging (FCM)
Future<void> _initFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;

  // 1) Pedir permisos (Android 13+ / iOS)
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  debugPrint('🔔 Permiso notificaciones: ${settings.authorizationStatus}');

  // 2) Registrar handler de background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 3) Listener en foreground (opcional, por ahora solo log)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('📩 Mensaje FCM en foreground: ${message.notification?.title}');
  });
}

/// Guardar el token FCM del dispositivo en Firestore
Future<void> _saveFcmTokenToFirestore() async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token == null) {
    debugPrint('⚠ No se pudo obtener FCM token');
    return;
  }

  debugPrint('📲 FCM Token: $token');

  await FirebaseFirestore.instance
      .collection('devices')
      .doc('doctor')
      .set({
    'token': token,
    'updatedAt': DateTime.now(),
  }, SetOptions(merge: true));
}

/// -------------------------
/// MAIN
/// -------------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _initFirebaseMessaging();
  await _saveFcmTokenToFirestore();

  runApp(const ClinicHealthApp());
}

class ClinicHealthApp extends StatelessWidget {
  const ClinicHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFE74C3C); // salmón/rojo

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClinicHealth',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const WelcomeScreen(),
      routes: {
        '/citas': (_) => const CitasPage(),
        '/appt/select-patient': (_) => const SelectPatientPage(),
        '/appt/select-date': (_) => const SelectDatePage(),
        '/appt/select-slot': (_) => const SelectSlotPage(),
        '/appt/review': (_) => const ReviewConfirmPage(),
        '/consulta/new': (_) => const NewConsultaPage(),
      },
    );
  }
}
