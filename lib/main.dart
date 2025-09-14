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
        primarySwatch: Colors.cyan,
        iconTheme: IconThemeData(
          color: Colors.grey[800],
          size: 30,
        ),
      ),
      home: const HomePage(),
    );
  }
}