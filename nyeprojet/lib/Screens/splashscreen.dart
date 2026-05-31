import 'dart:async';
import 'package:flutter/material.dart';
import 'login.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  final String? token;
  const SplashScreen({super.key, this.token});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Attendre 6 secondes avant daller sur la page login
    Timer(const Duration(seconds: 6), () {
      if (widget.token != null && widget.token!.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => NyeHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Connexion()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔥 Logo animé (zoom doux)
            TweenAnimationBuilder(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0.6, end: 1.0),
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Image.asset(
                'lib/images/logo.jpeg',
                width: 600,
                height: 600,
              ),
            ),

            const SizedBox(height: 20),

            // loader simple
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
