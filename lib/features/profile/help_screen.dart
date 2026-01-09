import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // =========================
  // YOUR REAL SUPPORT DETAILS
  // =========================
  static const String supportPhone = "+14189997418";
  static const String supportEmail = "bricengwesse35@gmail.com";

  // WhatsApp requires digits only (no +)
  static const String whatsappDigits = "14189997418";

  Future<void> _launch(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!ok && context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unableToOpenAction)),
      );
    }
  }

  void _openWhatsApp(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final message = Uri.encodeComponent(l10n.helpWhatsappMessage);
    final uri = Uri.parse("https://wa.me/$whatsappDigits?text=$message");
    _launch(context, uri);
  }

  void _callSupport(BuildContext context) {
    final uri = Uri(scheme: "tel", path: supportPhone);
    _launch(context, uri);
  }

  void _emailSupport(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final subject = Uri.encodeComponent(l10n.helpEmailSubject);
    final body = Uri.encodeComponent(l10n.helpEmailBody);

    final uri = Uri.parse("mailto:$supportEmail?subject=$subject&body=$body");
    _launch(context, uri);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0.3,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.help,
          style: text.titleLarge?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.helpNeedHelpTitle,
              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.helpNeedHelpSubtitle,
              style: text.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(.7),
              ),
            ),
            const SizedBox(height: 30),

            _HelpTile(
              icon: Icons.chat,
              title: l10n.whatsapp,
              subtitle: supportPhone,
              onTap: () => _openWhatsApp(context),
            ),

            _HelpTile(
              icon: Icons.phone,
              title: l10n.call,
              subtitle: supportPhone,
              onTap: () => _callSupport(context),
            ),

            _HelpTile(
              icon: Icons.email,
              title: l10n.email,
              subtitle: supportEmail,
              onTap: () => _emailSupport(context),
            ),

            const Spacer(),

            Center(
              child: Text(
                l10n.helpFooter,
                style: text.bodySmall?.copyWith(
                  color: colors.onSurface.withOpacity(.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================
// HELP TILE
// ============================
class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: colors.primary),
        title: Text(
          title,
          style: text.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: text.bodyMedium?.copyWith(
            color: colors.onSurface.withOpacity(.6),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: colors.onSurface.withOpacity(.4),
        ),
        onTap: onTap,
      ),
    );
  }
}
