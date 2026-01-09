import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    _routeNext();
  }

  Future<void> _routeNext() async {
    // Give a short splash feel (no long wait)
    _timer = Timer(const Duration(milliseconds: 1100), () async {
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final onboardingDone = prefs.getBool('onboarding_done') ?? false;

      final user = FirebaseAuth.instance.currentUser;

      // ✅ Routing rules:
      // - If onboarding not done -> onboarding
      // - If onboarding done and user logged in -> home
      // - else -> login
      if (!onboardingDone) {
        context.go('/onboarding');
      } else if (user != null) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO (no tinting)
                Image.asset(
                  "assets/images/logo.png",
                  height: 120,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 18),

                // TITLE (uses theme colors properly)
                Text(
                  "Ka-Loumo",
                  style: text.displaySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                ),

                const SizedBox(height: 18),

                // Loading Bar
                SizedBox(
                  width: 150,
                  child: LinearProgressIndicator(
                    backgroundColor: colors.onBackground
                        .withOpacity(isDark ? 0.12 : 0.10),
                    color: colors.primary,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
