import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:water_tracking_app/pages/main_screen.dart';
import 'package:water_tracking_app/pages/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SipQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF928FFF),
          primary: const Color(0xFF928FFF),
          secondary: const Color(0xFFD5D4FF),
          outline: Colors.white.withValues(alpha: 0.7),
        ),
        scaffoldBackgroundColor: const Color(0xFFD5D4FF),
        useMaterial3: true,
      ),
      // Use routes for easier navigation switching
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}