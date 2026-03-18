import 'dart:async';

import 'package:flutter/material.dart';

import '../../auth/presentation/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadApp();
  }

  Future<void> _loadApp() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF8C00),
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.7, end: 1.0),
          duration: const Duration(milliseconds: 850),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Image.asset(
            'assets/images/image_loader.png',
            width: 180,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
