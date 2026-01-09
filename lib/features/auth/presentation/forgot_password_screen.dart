import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),

                      /// ---- ICON ----
                      Center(
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: 100,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.85),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// ---- TITLE ----
                      Text(
                        "Forgot Password",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Enter your email and we'll send you a reset link.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),

                      const SizedBox(height: 40),

                      /// ---- EMAIL INPUT ----
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 25),

                      /// ---- RESET BUTTON ----
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() => isLoading = true);

                            // Simulated server delay
                            await Future.delayed(const Duration(milliseconds: 800));
                            setState(() => isLoading = false);

                            if (!mounted) return;

                            // Navigate to the Reset Success screen
                            context.go('/reset-success');
                          },
                          child: isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                              : const Text("Send Reset Link"),
                        ),
                      ),

                      const Spacer(),

                      /// ---- BACK TO LOGIN ----
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text("Back to Login"),
                      ),

                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
