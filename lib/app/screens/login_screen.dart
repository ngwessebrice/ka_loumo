import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ka_loumo/core/services/auth_service.dart';
import 'package:provider/provider.dart';

import '../../core/settings/theme_provider.dart';
import '../../core/settings/locale_provider.dart';
import '../../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool usePhoneLogin = true;
  bool isPasswordHidden = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _toggleLanguage() async {
    final localeProvider = context.read<LocaleProvider>();
    final code = localeProvider.locale?.languageCode;

    // Quick switch FR <-> EN (you can expand later)
    final next = code == 'fr' ? const Locale('en') : const Locale('fr');
    localeProvider.setLocale(next);
  }

  Future<void> _forgotPassword() async {
    final l10n = AppLocalizations.of(context)!;
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showMsg(l10n.enterEmailFirst);
      return;
    }

    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMsg(l10n.resetLinkSent(email));
    } on FirebaseAuthException catch (e) {
      _showMsg(e.message ?? l10n.resetFailed);
    } catch (_) {
      _showMsg(l10n.resetFailed);
    }
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _loginWithEmail() async {
    final l10n = AppLocalizations.of(context)!;

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showMsg(l10n.emailAndPasswordRequired);
      return;
    }

    setState(() => isLoading = true);
    try {
      await _auth.loginWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (!mounted) return;
      context.go('/home');
    } on FirebaseAuthException catch (e) {
      _showMsg(e.message ?? l10n.emailLoginFailed);
    } catch (e) {
      _showMsg("${l10n.emailLoginFailed}: $e");
    }
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _loginWithPhone() async {
    final l10n = AppLocalizations.of(context)!;

    if (phoneController.text.isEmpty) {
      _showMsg(l10n.phoneEnterNumber);
      return;
    }

    setState(() => isLoading = true);
    try {
      await _auth.sendOTP(
        phone: phoneController.text.trim(),
        onCodeSent: (verificationId) {
          if (!mounted) return;
          setState(() => isLoading = false);
          context.go('/otp', extra: {
            "vid": verificationId,
            "phone": phoneController.text.trim(),
          });
        },
        onError: (err) {
          _showMsg(err);
          if (mounted) setState(() => isLoading = false);
        },
      );
    } catch (e) {
      _showMsg(l10n.otpFailed);
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final localeCode = context.watch<LocaleProvider>().locale?.languageCode;
    final langLabel = localeCode == 'fr' ? 'FR' : 'EN';

    return Scaffold(
      backgroundColor: colors.background,

      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // ✅ Language toggle
          IconButton(
            tooltip: l10n.language,
            icon: Row(
              children: [
                Icon(Icons.language, color: colors.onBackground, size: 22),
                const SizedBox(width: 6),
                Text(
                  langLabel,
                  style: TextStyle(
                    color: colors.onBackground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            onPressed: _toggleLanguage,
          ),

          // ✅ Theme toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              final isDark = themeProvider.themeMode == ThemeMode.dark;
              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: colors.onBackground,
                  size: 26,
                ),
                onPressed: () {
                  themeProvider.setThemeMode(
                    isDark ? ThemeMode.light : ThemeMode.dark,
                  );
                },
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),

                Text(
                  "Ka-Loumo",
                  style: text.displayLarge?.copyWith(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  l10n.loginSubtitle,
                  style: text.bodyMedium?.copyWith(
                    color: colors.onBackground.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withOpacity(.4),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.welcomeBack,
                        style: text.titleLarge?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),
                      Text(
                        l10n.loginHint,
                        style: text.bodyMedium?.copyWith(
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            _toggleChip(
                              label: l10n.phone,
                              selected: usePhoneLogin,
                              onTap: () => setState(() => usePhoneLogin = true),
                            ),
                            _toggleChip(
                              label: l10n.email,
                              selected: !usePhoneLogin,
                              onTap: () => setState(() => usePhoneLogin = false),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      if (usePhoneLogin) ...[
                        _inputField(
                          label: l10n.phoneNumber,
                          controller: phoneController,
                          icon: Icons.phone,
                          keyboard: TextInputType.phone,
                          colors: colors,
                          text: text,
                        ),
                        const SizedBox(height: 20),
                        _mainButton(
                          label: l10n.sendOtp,
                          loading: isLoading,
                          onTap: _loginWithPhone,
                          colors: colors,
                        ),
                      ] else ...[
                        _inputField(
                          label: l10n.email,
                          controller: emailController,
                          icon: Icons.email_outlined,
                          keyboard: TextInputType.emailAddress,
                          colors: colors,
                          text: text,
                        ),
                        const SizedBox(height: 14),
                        _inputField(
                          label: l10n.password,
                          controller: passwordController,
                          icon: Icons.lock_outline,
                          obscure: isPasswordHidden,
                          colors: colors,
                          text: text,
                          onSuffixTap: () =>
                              setState(() => isPasswordHidden = !isPasswordHidden),
                          suffixIcon: isPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading ? null : _forgotPassword,
                            child: Text(
                              l10n.forgotPassword,
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _mainButton(
                          label: l10n.login,
                          loading: isLoading,
                          onTap: _loginWithEmail,
                          colors: colors,
                        ),
                      ],

                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 0,
                  children: [
                    Text(
                      l10n.noAccount,
                      style: text.bodyMedium?.copyWith(
                        color: colors.onBackground.withOpacity(0.7),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: Text(
                        l10n.register,
                        style: text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? colors.onPrimary
                    : colors.onSurface.withOpacity(.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required ColorScheme colors,
    required TextTheme text,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      style: text.bodyLarge?.copyWith(color: colors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.onSurface.withOpacity(.6)),
        prefixIcon: Icon(icon, color: colors.primary),
        suffixIcon: suffixIcon == null
            ? null
            : IconButton(
          icon: Icon(suffixIcon, color: colors.onSurface),
          onPressed: onSuffixTap,
        ),
        filled: true,
        fillColor: colors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 1.4),
        ),
      ),
    );
  }

  Widget _mainButton({
    required String label,
    required VoidCallback onTap,
    required ColorScheme colors,
    required bool loading,
  }) {
    return ElevatedButton(
      onPressed: loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: loading
          ? SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colors.onPrimary,
        ),
      )
          : Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
