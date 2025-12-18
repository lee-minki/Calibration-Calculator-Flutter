import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AdService().initialize();
  runApp(const CalibrationCalculatorApp());
}

class CalibrationCalculatorApp extends StatelessWidget {
  const CalibrationCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calibration Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00D4FF),
          secondary: const Color(0xFF7C3AED),
          surface: const Color(0xFF12121A),
        ),
        fontFamily: 'JetBrainsMono',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
