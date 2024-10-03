import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:teamproject_3/screens/login_screen.dart';
import 'package:teamproject_3/providers/financial_provider.dart';
import 'package:teamproject_3/screens/financial_overview_screen.dart';
import 'package:teamproject_3/providers/user_provider.dart';
import 'package:teamproject_3/screens/splash_screen.dart'; // Import splash screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FinanceManagerApp());
}

class FinanceManagerApp extends StatelessWidget {
  const FinanceManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinancialProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'แอปจัดการการเงิน',
        debugShowCheckedModeBanner: false,
        initialRoute: '/', // Start with splash screen
        routes: {
          '/': (context) => const SplashScreen(), // Show splash video first
          '/auth': (context) => const AuthCheck(), // Then check authentication
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}

// Authentication check after splash screen
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const FinancialOverviewScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
