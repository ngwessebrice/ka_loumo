import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';

class UpgradeCancelScreen extends StatelessWidget {
  const UpgradeCancelScreen({super.key});

  void _exit(BuildContext context) {
    final router = GoRouter.of(context);

    // If we have history, pop
    if (router.canPop()) {
      router.pop();
      return;
    }

    // ✅ If opened from deep link, go to profile (or home)
    context.go('/profile'); // change if your profile path differs
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
            Icon(Icons.info, size: 54, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              l10n.paymentCanceledTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.paymentCanceledBody,
              style: TextStyle(color: colors.onSurface.withOpacity(.7)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _exit(context),
                child: Text(l10n.back),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
