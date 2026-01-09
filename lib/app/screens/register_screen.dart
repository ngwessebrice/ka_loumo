import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ka_loumo/core/services/auth_service.dart';

import '../../l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _auth = AuthService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passController = TextEditingController();
  final confirmController = TextEditingController();

  bool isPasswordHidden = true;
  bool isConfirmHidden = true;
  bool isLoading = false;

  void _msg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  // ================================
  //        CREATE USER DOC
  // ================================
  Future<void> _createUserDocument({
    required User user,
    required String name,
    required String phone,
    required String email,
  }) async {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).set(
      {
        "uid": user.uid,
        "name": name,
        "email": email,
        "phone": phone,
        "photoUrl": "",
        "bio": "",
        "location": "",
        "rating": 0.0,
        "ratingCount": 0,
        "plan": "free", // free | pro
        "activeListings": 0,
        "listingLimit": 3,
        "isPremium": false,
        "trialUsed": false,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      },
      SetOptions(merge: false),
    );
  }

  // ================================
  //             REGISTER
  // ================================
  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final pass = passController.text.trim();
    final confirm = confirmController.text.trim();

    if (name.isEmpty) return _msg(l10n.msgFullNameRequired);
    if (phone.isEmpty) return _msg(l10n.msgPhoneRequired);
    if (!phone.startsWith("+224")) return _msg(l10n.msgPhoneMustStart224);
    if (pass.isEmpty || confirm.isEmpty) return _msg(l10n.msgPasswordRequired);
    if (pass != confirm) return _msg(l10n.msgPasswordsDoNotMatch);

    final safeEmail =
    email.isEmpty ? "${phone.replaceAll('+', '')}@kaloumo.com" : email;

    setState(() => isLoading = true);

    try {
      // ✅ Step 1: Create Auth user (may succeed even if later steps fail)
      final user = await _auth.registerWithEmail(
        name: name,
        email: safeEmail,
        password: pass,
        phone: phone,
      );

      if (user == null) {
        _msg(l10n.msgRegistrationFailed);
        return;
      }

      // ✅ Optional: ensure latest user state
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser ?? user;

      // ✅ Step 2: Create Firestore profile doc (this is where rules often fail)
      await _createUserDocument(
        user: refreshedUser,
        name: name,
        phone: phone,
        email: safeEmail,
      );

      if (!mounted) return;
      _msg(l10n.msgAccountCreated);
      context.go('/home');
    } on FirebaseAuthException catch (e) {
      // Auth errors (email already used, weak password, invalid email, etc.)
      debugPrint("Auth error: ${e.code} ${e.message}");
      _msg(e.message ?? l10n.msgRegistrationFailed);
    } on FirebaseException catch (e) {
      // Firestore / network / permission-denied etc.
      debugPrint("Firebase error: ${e.code} ${e.message}");

      // Most common: permission-denied (Firestore rules)
      if (e.code == 'permission-denied') {
        _msg("Account created, but profile save blocked (rules).");
      } else {
        _msg("Account created, but profile save failed: ${e.code}");
      }

      // ✅ You can still let them in, since Auth is created
      if (mounted) context.go('/home');
    } catch (e) {
      debugPrint("Register unknown error: $e");
      _msg(l10n.msgRegistrationFailed);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================================
  //               UI
  // ================================
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(
                l10n.registerTitle,
                style: text.headlineSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.registerSubtitle,
                style: text.bodyMedium?.copyWith(
                  color: colors.onSurface.withOpacity(.7),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _textInput(
                      controller: nameController,
                      label: l10n.registerFullName,
                      icon: Icons.person,
                      colors: colors,
                    ),
                    const SizedBox(height: 16),
                    _textInput(
                      controller: emailController,
                      label: l10n.registerEmailOptional,
                      icon: Icons.email_outlined,
                      colors: colors,
                      keyboard: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _textInput(
                      controller: phoneController,
                      label: l10n.registerPhone224,
                      icon: Icons.phone,
                      colors: colors,
                      keyboard: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _passwordInput(
                      controller: passController,
                      label: l10n.registerPassword,
                      obscure: isPasswordHidden,
                      toggle: () => setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      }),
                      colors: colors,
                    ),
                    const SizedBox(height: 16),
                    _passwordInput(
                      controller: confirmController,
                      label: l10n.registerConfirmPassword,
                      obscure: isConfirmHidden,
                      toggle: () => setState(() {
                        isConfirmHidden = !isConfirmHidden;
                      }),
                      colors: colors,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onPrimary,
                          ),
                        )
                            : Text(
                          l10n.registerCreateAccountBtn,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  Text(
                    l10n.registerAlreadyHaveAccount,
                    style: TextStyle(color: colors.onSurface.withOpacity(.7)),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      l10n.login,
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================
  //          WIDGET HELPERS
  // ================================
  Widget _textInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colors,
    TextInputType? keyboard,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: TextStyle(color: colors.onSurface),
      decoration: _decor(label, icon, colors),
    );
  }

  Widget _passwordInput({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
    required ColorScheme colors,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: colors.onSurface),
      decoration: _decor(
        label,
        Icons.lock_outline,
        colors,
        isPassword: true,
        toggle: toggle,
        obscure: obscure,
      ),
    );
  }

  InputDecoration _decor(
      String label,
      IconData icon,
      ColorScheme colors, {
        bool isPassword = false,
        VoidCallback? toggle,
        bool obscure = false,
      }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colors.onSurface.withOpacity(.6)),
      prefixIcon: Icon(icon, color: colors.primary),
      suffixIcon: isPassword
          ? IconButton(
        onPressed: toggle,
        icon: Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
          color: colors.onSurface.withOpacity(.6),
        ),
      )
          : null,
      filled: true,
      fillColor: colors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.outline.withOpacity(.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
    );
  }
}
