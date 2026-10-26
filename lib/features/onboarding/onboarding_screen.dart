import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.step = 0});
  final int step;
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late int step = widget.step;
  static const titles = [
    'Discover Largest\nNFT Market',
    'Start Your Own\nNFT Gallery',
    'Explore The\nWorld Of Art',
    'Explore The\nWorld Of Art',
  ];
  static const images = [
    'sun-glass',
    'onboarding-2',
    'onboarding-3',
    'onboarding-4',
  ];
  Future<void> finish() async {
    await AppScope.of(context).finishOnboarding();
    if (mounted) Navigator.of(context).pushReplacementNamed('/wallet');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, box) {
          final height = box.maxHeight < 700 ? 700.0 : box.maxHeight;
          return SingleChildScrollView(
            child: SizedBox(
              height: height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: finish,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFE9E9E9),
                            foregroundColor: AppColors.muted,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text('SKIP'),
                        ),
                        Row(
                          children: List.generate(
                            4,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: i == step ? 24 : 12,
                              height: 4,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: i == step
                                    ? AppColors.ink
                                    : const Color(0xFFCCCCCC),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(
                      height: height * .407,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7090A4)
                                .withValues(alpha: .18),
                            blurRadius: 38,
                            offset: const Offset(0, 24),
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 230),
                        child: Art(
                          images[step],
                          key: ValueKey(step),
                          radius: 12,
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    Text(
                      titles[step],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: box.maxWidth < 350 ? 32 : 38,
                        fontWeight: FontWeight.w700,
                        height: 1.24,
                        letterSpacing: -.8,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'DiveSea is a great platform to discover\nthe largest NFTs and extraordinary art.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF777E90),
                        height: 1.7,
                      ),
                    ),
                    const Spacer(flex: 2),
                    if (step == 3)
                      PrimaryButton('Get Started', onPressed: finish)
                    else
                      Container(
                        width: 154,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCFCFD),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .10),
                              blurRadius: 32,
                              offset: const Offset(0, 24),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              tooltip: 'Previous',
                              onPressed: step == 0
                                  ? null
                                  : () => setState(() => step--),
                              icon: const Icon(Icons.arrow_back, size: 20),
                            ),
                            Container(
                              height: 24,
                              width: 2,
                              color: AppColors.line,
                            ),
                            IconButton(
                              tooltip: 'Next',
                              onPressed: () => setState(() => step++),
                              icon: const Icon(Icons.arrow_forward, size: 20),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 40),
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
