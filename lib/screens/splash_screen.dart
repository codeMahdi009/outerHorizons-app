import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6)));
    _scaleAnim = Tween<double>(begin: 0.7, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();

    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 60));
      if (!mounted) return false;
      setState(() => _progress += 0.06);
      return _progress < 1.0;
    }).then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNav()));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepSpace,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppTheme.cosmicTeal.withAlpha(200),
                        AppTheme.nebulaPurple,
                        AppTheme.deepSpace,
                      ]),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.cosmicTeal.withAlpha(120),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.rocket_launch,
                        color: Colors.white, size: 60),
                  ),
                  const SizedBox(height: 28),
                  const Text('OUTER HORIZONS',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3)),
                  const SizedBox(height: 6),
                  const Text('Explore the cosmos',
                      style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.cosmicTeal,
                          letterSpacing: 2)),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _progress.clamp(0.0, 1.0),
                        backgroundColor: AppTheme.cardDark,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.cosmicTeal),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Loading... ${(_progress * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
