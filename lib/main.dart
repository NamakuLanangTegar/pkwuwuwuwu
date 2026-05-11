import 'package:flutter/material.dart';
import 'package:vtr/core/app_theme.dart';
import 'package:vtr/screens/splash_screen.dart';

void main() {
  runApp(const VateroTravelApp());
}

class VateroTravelApp extends StatelessWidget {
  const VateroTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VATERO TRAVEL',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}