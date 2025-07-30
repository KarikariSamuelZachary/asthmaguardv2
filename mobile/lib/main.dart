import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:mobile/screens/auth/dashboard_screen.dart';
import 'package:mobile/screens/auth/forgotpassword_screen.dart';
import 'package:mobile/screens/auth/login_screen.dart';
import 'package:mobile/screens/auth/otp_verification_screen.dart';
import 'package:mobile/screens/auth/signup_page.dart';
import 'package:mobile/screens/auth/welcome_screen.dart';
import 'package:mobile/screens/health_report/health_report.dart';
import 'package:mobile/screens/health_tips/health_tips_screen.dart';
import 'package:mobile/screens/home/home_screen.dart';
import 'package:mobile/screens/pollution_tracker/pollution_tracker_screen.dart';
import 'package:mobile/screens/exercise_routines/exercise_routines.dart';
import 'package:mobile/screens/medication/medication_tracker_screen.dart';
import 'package:mobile/screens/auth/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/providers/emergency_contact_provider.dart';
import 'package:mobile/providers/medication_provider.dart';
import 'package:mobile/providers/symptom_log_provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/screens/onboarding/onboarding_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/alert_notification_service.dart';

Future<void> requestNotificationPermissionIfNeeded() async {
  if (Platform.isAndroid) {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }
}

final alertNotificationService = AlertNotificationService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  await alertNotificationService.init();
  await requestNotificationPermissionIfNeeded();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyContactProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => SymptomLogProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Add other providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: themeProvider.themeMode,
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/signup': (context) => const SignupScreen(),
            '/otp': (context) => const EmailVerificationScreen(),
            '/login': (context) => const LoginScreen(),
            '/welcome': (context) => const WelcomeScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/home': (context) => const HomeScreen(),
            '/pollution-tracker': (context) => const PollutionTrackerScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/health-report': (context) => const HealthReportScreen(),
            '/health-tips': (context) => const HealthTipsScreen(),
            '/exercise-routines': (context) => const ExerciseRoutines(),
            '/medication-tracker': (context) => const MedicationTrackerScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/profile': (context) => const ProfileScreen(),
          },
        );
      },
    );
  }
}
