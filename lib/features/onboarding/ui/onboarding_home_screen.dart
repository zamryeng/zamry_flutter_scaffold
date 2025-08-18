import 'package:flutter/material.dart';

import '../../../core/presentation/presentation.dart';

class OnboardingHomeScreen extends StatelessWidget {
  const OnboardingHomeScreen({super.key, required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

              // Main heading text
              Text(
                'Welcome to Zamry\n\n Your USSD Utility for\nfinancial services',
                textAlign: TextAlign.center,
                style: context.styles.heading20Bold.copyWith(
                  fontSize: 28,
                  height: 1.2,
                  color: context.colors.textColor,
                ),
              ),

              const Spacer(flex: 3),

              // Get Started button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AppButton.primary(
                  label: 'Get Started',
                  onPressed: onGetStarted,
                  view: 'OnboardingHomeScreen',
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
