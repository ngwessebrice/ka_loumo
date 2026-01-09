import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';



class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    final isDark = theme.brightness == Brightness.dark;

    final titleColor = colors.onBackground;
    final descColor = colors.onBackground.withOpacity(isDark ? 0.72 : 0.65);
    final dotInactive = colors.onBackground.withOpacity(isDark ? 0.25 : 0.20);

    final pages = [
      {
        "title": l10n.onboardingWelcomeTitle,
        "desc": l10n.onboardingWelcomeDesc,
        "img": "assets/images/logo.png",
      },
      {
        "title": l10n.onboardingBuySellTitle,
        "desc": l10n.onboardingBuySellDesc,
        "img": "assets/images/logo.png",
      },
      {
        "title": l10n.onboardingChatTitle,
        "desc": l10n.onboardingChatDesc,
        "img": "assets/images/logo.png",
      },
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 170,
                          width: 170,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadow.withOpacity(isDark ? 0.35 : 0.20),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            pages[i]["img"]!,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          pages[i]["title"]!,
                          textAlign: TextAlign.center,
                          style: text.headlineMedium?.copyWith(
                            color: titleColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          pages[i]["desc"]!,
                          textAlign: TextAlign.center,
                          style: text.bodyLarge?.copyWith(
                            color: descColor,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                    (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  height: 10,
                  width: _page == i ? 26 : 10,
                  decoration: BoxDecoration(
                    color: _page == i ? colors.primary : dotInactive,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_page == pages.length - 1) {
                      await _finishOnboarding();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _page == pages.length - 1 ? l10n.btnGetStarted : l10n.btnNext,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                l10n.btnSkip,
                style: TextStyle(
                  color: colors.onBackground.withOpacity(0.65),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
