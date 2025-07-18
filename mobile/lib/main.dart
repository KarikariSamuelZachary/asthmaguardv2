import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'package:mobile/screens/onboarding/onboarding_screen1.dart';
import 'package:mobile/screens/onboarding/onboarding_screen2.dart';
import 'screens/profile/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyContactProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => SymptomLogProvider()),
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
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/splash', // Set splash as the default screen
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/signup': (context) => const SignupScreen(),
        '/otp': (context) => const OtpVerificationScreen(),
        '/login': (context) => const LoginScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/home': (context) => const HomeScreen(),
        '/pollution-tracker': (context) => const PollutionTrackerScreen(),
        '/forgot-password': (context) =>
            const ForgotPasswordScreen(), // Add route for forgot password
        '/health-report': (context) =>
            const HealthReportScreen(), // Corrected to HealthReportScreen
        '/health-tips': (context) =>
            const HealthTipsScreen(), // Add HealthTipsScreen route
        '/exercise-routines': (context) => const ExerciseRoutines(),
        '/medication-tracker': (context) => const MedicationTrackerScreen(),
        '/onboarding1': (context) => const OnboardingScreen1(),
        '/onboarding2': (context) => const OnboardingScreen2(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
