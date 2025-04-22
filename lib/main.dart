import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart'; // Don't forget this if using FlutterFire CLI
import 'providers/farm_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/market_provider.dart';
import 'providers/finance_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart'; // ✅ Needed for routes
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final storageService = StorageService();
  await storageService.init();
  final onboardingComplete = await storageService.isOnboardingComplete();

  runApp(MyApp(onboardingComplete: onboardingComplete, showLogin: true));
}

class MyApp extends StatelessWidget {
  final bool onboardingComplete;
  final bool showLogin;

  const MyApp({
    Key? key,
    required this.onboardingComplete,
    this.showLogin = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FarmProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
      ],
      child: MaterialApp(
        title: 'Filipino Farm Assistant',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: showLogin
            ? const LoginScreen()
            : (onboardingComplete ? const HomeScreen() : const OnboardingScreen()),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
        },
      ),
    );
  }
}
