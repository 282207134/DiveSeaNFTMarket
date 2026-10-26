import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/app_state.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({
    super.key,
    this.prompt = false,
    this.returnAfter = false,
  });
  final bool prompt, returnAfter;
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final address = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.prompt) {
      WidgetsBinding.instance.addPostFrameCallback((_) => connect('Metamask'));
    }
  }

  @override
  void dispose() {
    address.dispose();
    super.dispose();
  }

  Future<void> complete(String wallet) async {
    await AppScope.of(context).connectWallet(wallet);
    if (!mounted) return;
    if (widget.returnAfter) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/register');
    }
  }

  Future<void> connect(String wallet) async {
    final open = await showDialog<bool>(
      context: context,
      barrierColor: Colors.white.withValues(alpha: .1),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Connect your demo wallet\nto explore DiveSea.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No real funds or wallet access.',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  'Open',
                  height: 42,
                  onPressed: () => Navigator.pop(context, true),
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  'Cancel',
                  height: 42,
                  light: true,
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (open == true && mounted) await complete(wallet);
  }

  Future<void> enterAddress() async {
    final form = GlobalKey<FormState>();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ethereum address'),
        content: Form(
          key: form,
          child: TextFormField(
            controller: address,
            decoration: const InputDecoration(hintText: '0x…'),
            validator: (v) =>
                RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(v?.trim() ?? '')
                ? null
                : 'Enter a valid 42-character address',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(context, address.text.trim());
              }
            },
            child: const Text('Connect demo'),
          ),
        ],
      ),
    );
    if (value != null && mounted) await complete(value);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          child: SizedBox(
            height: box.maxHeight < 720 ? 720 : box.maxHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  BackCircle(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacementNamed(
                          context,
                          '/onboarding?step=3',
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Choose Wallet',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'By connecting your wallet, you agree to our\nprivacy terms and policies.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 72),
                  for (final entry in [
                    ('Metamask', 'metamask'),
                    ('Trust Wallet', 'trust-wallet'),
                    ('Enter ethereum address', ''),
                  ]) ...[
                    SizedBox(
                      height: 68,
                      child: SoftCard(
                        radius: 8,
                        child: InkWell(
                          onTap: () => entry.$2.isEmpty
                              ? enterAddress()
                              : connect(entry.$1),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: entry.$2.isEmpty
                                    ? const Icon(
                                        Icons.link,
                                        color: AppColors.muted,
                                      )
                                    : Art(entry.$2),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  entry.$1,
                                  style: const TextStyle(
                                    fontFamily: 'DMSans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                  const Spacer(),
                  if (!widget.returnAfter)
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/register',
                        ),
                        child: const Text('Continue exploring'),
                      ),
                    ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
