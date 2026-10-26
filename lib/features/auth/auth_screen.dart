import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/app_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.login = false, this.filled = false});
  final bool login, filled;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(
    text: widget.filled ? 'Joseph Ren' : '',
  );
  late final email = TextEditingController(
    text: widget.filled ? 'joseph.ren@mail.com' : '',
  );
  late final password = TextEditingController(
    text: widget.filled ? 'DiveSea2026!' : '',
  );
  bool obscure = true, busy = false;
  InputBorder? filledBorder(String value) => value.isEmpty
      ? null
      : OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.black),
        );
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await AppScope.of(context)
          .signIn(email.text, fullName: widget.login ? null : name.text);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    } catch (_) {
      if (mounted) {
        toast(context, 'Unable to save your account. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: widget.login ? 140 : 70),
                Text(
                  widget.login ? 'Login your\nAccount' : 'Create your\nAccount',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 36,
                    height: 1.25,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 42),
                if (!widget.login) ...[
                  TextFormField(
                    controller: name,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      enabledBorder: filledBorder(name.text),
                      hintText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline, size: 21),
                    ),
                    validator: (v) => (v?.trim().length ?? 0) >= 2
                        ? null
                        : 'Enter your full name',
                  ),
                  const SizedBox(height: 18),
                ],
                TextFormField(
                  controller: email,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    enabledBorder: filledBorder(email.text),
                    hintText: 'Enter Your Email',
                    prefixIcon: const Icon(Icons.mail_outline, size: 21),
                  ),
                  validator: emailValidator,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: password,
                  onChanged: (_) => setState(() {}),
                  obscureText: obscure,
                  onFieldSubmitted: (_) => submit(),
                  decoration: InputDecoration(
                    enabledBorder: filledBorder(password.text),
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 21),
                    suffixIcon: IconButton(
                      tooltip: obscure ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() => obscure = !obscure),
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                      ),
                    ),
                  ),
                  validator: (v) => (v?.length ?? 0) >= 8
                      ? null
                      : 'Use at least 8 characters',
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  busy
                      ? 'Please wait…'
                      : widget.login
                      ? 'Login'
                      : 'Register',
                  onPressed: busy ? null : submit,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.login
                          ? 'New to DiveSea?'
                          : 'Already have an account?',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        widget.login ? '/register' : '/login',
                      ),
                      child: Text(
                        widget.login ? 'Sign Up' : 'Sign In',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                const Center(
                  child: Text(
                    'Continue With Accounts',
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    for (final item in [
                      ('GOOGLE', const Color(0xFFF0D2CF)),
                      ('FACEBOOK', const Color(0xFFD2DAE8)),
                    ]) ...[
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: TextButton(
                            onPressed: () => toast(
                              context,
                              'Use the email form above to enter the demo.',
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: item.$2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Text(
                              item.$1,
                              style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (item.$1 == 'GOOGLE') const SizedBox(width: 14),
                    ],
                  ],
                ),
                const SizedBox(height: 25),
                const Center(
                  child: Text(
                    'Local demo · No real account is created',
                    style: TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
