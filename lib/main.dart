import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:water_tracking_app/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aqua Tracking App',
      theme: ThemeData(
        // Use colorScheme for modern Flutter theming
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF928FFF), // Your primary color
          primary: const Color(0xFF928FFF),
          secondary: const Color(0xFFD5D4FF),
          outline: Colors.white.withValues(alpha: 0.7),
        ),
        
        // You can also define other colors
        scaffoldBackgroundColor: const Color(0xFFD5D4FF),

        // This makes sure other UI elements follow the theme
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}