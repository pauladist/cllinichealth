import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/citas_page.dart';
import 'screens/appointment_new/select_patient_page.dart';
import 'screens/appointment_new/select_date_page.dart';
import 'screens/appointment_new/select_slot_page.dart';
import 'screens/appointment_new/review_confirm_page.dart';
import 'screens/consultas/new_consulta_page.dart';


import 'screens/welcome_screen.dart';

class AppAuth {
  static const user = 'admin@gmail.com';
  static const pass = 'dr123';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
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
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
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
