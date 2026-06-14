import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/auth/login_screen.dart';
import 'app_theme.dart';
import 'firebase_options.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale Indonesia untuk intl
  await initializeDateFormatting('id', null);

  // Inisialisasi Firebase menggunakan konfigurasi hasil flutterfire configure
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirestoreService.initialize();

  // Status bar transparan
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const CleanGoApp());
}

class CleanGoApp extends StatelessWidget {
  const CleanGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CleanGo Staff',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bgPage,
        fontFamily: 'Inter',
      ),
      home: const LoginScreen(),
    );
  }
}
