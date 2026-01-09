import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/settings/theme_provider.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String privacyUrl =
      "https://docs.google.com/document/d/10s35F71PR1oHG8x5M0ckq1Gko-g4jbaNgi457yMQCBY/edit?usp=sharing";
  static const String termsUrl =
      "https://docs.google.com/document/d/1swpo9BTJY4rBGdf5ncF_N4VPUrRncjw9DwYVNqVCrSo/edit?usp=sharing";

  Future<void> _openUrl(BuildContext context, String url) async {
    final l10n = AppLocalizations.of(context)!;

    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unableToOpenLink)),
      );
    }
  }

  // ===========================
  // ✅ CHANGE PASSWORD (V1)
  // ===========================
  Future<void> _showChangePasswordDialog(BuildContext parentContext) async {
    final l10n = AppLocalizations.of(parentContext)!;

    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    await showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool saving = false;
        bool hide = true;

        Future<void> submit(void Function(void Function()) setDialogState) async {
          final current = currentCtrl.text.trim();
          final next = newCtrl.text.trim();
          final confirm = confirmCtrl.text.trim();

          if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
            ScaffoldMessenger.of(parentContext).showSnackBar(
              SnackBar(content: Text(l10n.fillAllFields)),
            );
            return;
          }
          if (next != confirm) {
            ScaffoldMessenger.of(parentContext).showSnackBar(
              SnackBar(content: Text(l10n.passwordsDoNotMatch)),
            );
            return;
          }
          if (next.length < 6) {
            ScaffoldMessenger.of(parentContext).showSnackBar(
              SnackBar(content: Text(l10n.passwordMin6)),
            );
            return;
          }

          setDialogState(() => saving = true);

          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) throw Exception(l10n.notLoggedIn);

            final email = user.email;
            if (email == null || email.isEmpty) {
              throw Exception(l10n.noEmailPasswordLogin);
            }

            final cred = EmailAuthProvider.credential(
              email: email,
              password: current,
            );

            await user.reauthenticateWithCredential(cred);
            await user.updatePassword(next);

            if (dialogContext.mounted) {
              Navigator.of(dialogContext, rootNavigator: true).pop();
            }

            if (parentContext.mounted) {
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(content: Text(l10n.passwordUpdated)),
              );
            }
          } on FirebaseAuthException catch (e) {
            if (parentContext.mounted) {
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(content: Text("${l10n.failed}: ${e.code}")),
              );
            }
          } catch (e) {
            if (parentContext.mounted) {
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(content: Text("${l10n.error}: $e")),
              );
            }
          } finally {
            if (dialogContext.mounted) {
              setDialogState(() => saving = false);
            }
          }
        }

        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog(
              title: Text(l10n.changePasswordTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentCtrl,
                    obscureText: hide,
                    decoration: InputDecoration(labelText: l10n.currentPassword),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: newCtrl,
                    obscureText: hide,
                    decoration: InputDecoration(labelText: l10n.newPassword),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: hide,
                    decoration: InputDecoration(labelText: l10n.confirmNewPassword),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: !hide,
                        onChanged: saving
                            ? null
                            : (v) => setDialogState(() => hide = !(v ?? false)),
                      ),
                      Text(l10n.showPasswords),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext, rootNavigator: true).pop(),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: saving ? null : () => submit(setDialogState),
                  child: saving
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(l10n.update),
                ),
              ],
            );
          },
        );
      },
    );

    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.3,
        title: Text(
          l10n.settingsTitle,
          style: text.titleLarge?.copyWith(color: colors.onBackground),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ===========================
          // GENERAL
          // ===========================
          Text(
            l10n.settingsGeneral,
            style: text.titleMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _SettingsTile(
            icon: Icons.language,
            title: l10n.settingsLanguageTitle,
            subtitle: l10n.settingsLanguageSubtitle,
            onTap: () => context.push('/language'),
          ),

          _SwitchTile(
            icon: Icons.dark_mode,
            title: l10n.settingsDarkMode,
            value: isDark,
            onChanged: (value) => themeProvider.toggleDark(value),
          ),

          const SizedBox(height: 20),

          // ===========================
          // ACCOUNT
          // ===========================
          Text(
            l10n.settingsAccount,
            style: text.titleMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _SettingsTile(
            icon: Icons.lock,
            title: l10n.changePasswordTitle,
            subtitle: l10n.settingsChangePasswordSubtitle,
            onTap: () => _showChangePasswordDialog(context),
          ),

          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyPolicyTitle,
            subtitle: l10n.privacyPolicySubtitle,
            onTap: () => _openUrl(context, privacyUrl),
          ),

          _SettingsTile(
            icon: Icons.article_outlined,
            title: l10n.termsTitle,
            subtitle: l10n.termsSubtitle,
            onTap: () => _openUrl(context, termsUrl),
          ),

          const SizedBox(height: 22),
        ],
      ),
    );
  }
}

// =====================================================================
// Settings Tile
// =====================================================================
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: colors.primary),
        title: Text(
          title,
          style: text.bodyLarge?.copyWith(color: colors.onSurface),
        ),
        subtitle: Text(
          subtitle,
          style: text.bodySmall?.copyWith(
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

// =====================================================================
// Switch Tile (Dark Mode Toggle)
// =====================================================================
class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final Function(bool) onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: colors.primary),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        activeColor: colors.primary,
      ),
    );
  }
}
