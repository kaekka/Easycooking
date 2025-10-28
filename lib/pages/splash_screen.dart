import 'dart:async';
import 'package:flutter/material.dart';
import 'home_page.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _dotIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startDotAnimation();

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RecipeHomePage()),
      );
    });
  }

  void _startDotAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        _dotIndex = (_dotIndex + 1) % 3;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF164D37), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png', 
              width: 500,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _dotIndex == index
                        ? Colors.amberAccent
                        : Colors.white.withOpacity(0.3),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
