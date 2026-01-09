import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';

class UpgradeSuccessScreen extends StatelessWidget {
  final String? sessionId;
  const UpgradeSuccessScreen({super.key, this.sessionId});

  void _exit(BuildContext context) {
    final router = GoRouter.of(context);

    // If there is a previous page in the stack, pop.
    if (router.canPop()) {
      router.pop();
      return;
    }

    // ✅ If opened from deep link (no back stack), go to a safe in-app page.
    // Change this to YOUR real destination route:
    context.go('/profile');
    // e.g. '/home' or '/settings' or '/profile'
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.upgrade),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _exit(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle, size: 54, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              l10n.paymentSuccessTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.paymentSuccessBody,
              style: TextStyle(color: colors.onSurface.withOpacity(.7)),
            ),
            if (sessionId != null && sessionId!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                "Session: $sessionId",
                style: TextStyle(
                  color: colors.onSurface.withOpacity(.55),
                  fontSize: 12,
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _exit(context),
                child: Text(l10n.done),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
