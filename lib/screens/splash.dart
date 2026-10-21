import 'package:flutter/material.dart';
import 'package:qavexyukonsolitairepro/core/app_state.dart';
import 'package:qavexyukonsolitairepro/core/themes.dart';
import 'package:qavexyukonsolitairepro/screens/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBuilder(
      builder: (context, s) {
        final t = QxThemes.byId(s.themeId, s.highContrast);
        return Scaffold(
          backgroundColor: t.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset('assets/images/icon.png',
                      width: 120, height: 120,
                      errorBuilder: (_, __, ___) => Icon(
                          Icons.sports,
                          size: 120,
                          color: t.primary)),
                ),
                const SizedBox(height: 24),
                Text('Qavex Yukon Solitaire Pro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: t.text)),
                const SizedBox(height: 8),
                Text('No stock, no mercy: the gold-rush solitaire.',
                    style: TextStyle(fontSize: 16, color: t.accent)),
                const SizedBox(height: 32),
                CircularProgressIndicator(color: t.primary),
              ],
            ),
          ),
        );
      },
    );
  }
}
