import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/presentation.dart';
import '../../domain/onboarding_vm.dart';

class FetchingPhoneNumberPage extends StatefulWidget {
  const FetchingPhoneNumberPage({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<FetchingPhoneNumberPage> createState() => _FetchingPhoneNumberPageState();
}

class _FetchingPhoneNumberPageState extends State<FetchingPhoneNumberPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_startFetching);
  }

  Future<void> _startFetching() async {
    final vm = context.read<OnboardingVm>();
    await vm.fetchPhoneNumber();

    // Auto-proceed after successful fetch
    if (vm.phoneNumberFetched && mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Loading animation with phone icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: context.colors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppViewSelector<OnboardingVm, bool>(
                    selector: (vm) => vm.isBusy,
                    builder: (isBusy, child) => isBusy
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    context.colors.primaryColor,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.phone_android,
                                size: 40,
                                color: context.colors.primaryColor,
                              ),
                            ],
                          )
                        : Icon(
                            Icons.check_circle,
                            size: 60,
                            color: context.colors.attitudeSuccessMain,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Status text
              AppViewSelector<OnboardingVm, bool>(
                selector: (vm) => vm.phoneNumberFetched,
                builder: (fetched, child) => Text(
                  fetched ? 'Phone Number Retrieved!' : 'Fetching your phone number',
                  style: context.styles.heading20Bold,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              AppViewSelector<OnboardingVm, bool>(
                selector: (vm) => vm.phoneNumberFetched,
                builder: (fetched, child) => Text(
                  fetched
                      ? 'Successfully retrieved your phone number from the SIM card.'
                      : 'Please wait while we retrieve your phone number from the SIM card...',
                  style: context.styles.body16Regular.copyWith(color: context.colors.grey700),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),

              // Phone number display (when fetched)
              AppViewSelector<OnboardingVm, String>(
                selector: (vm) => vm.fetchedPhoneNumber ?? '',
                builder: (phoneNumber, child) => phoneNumber.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.attitudeSuccessLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: context.colors.attitudeSuccessMain.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, color: context.colors.attitudeSuccessMain, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              phoneNumber,
                              style: context.styles.body16SemiBold.copyWith(
                                color: context.colors.attitudeSuccessMain,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.grey100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: context.colors.grey300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sim_card, color: context.colors.primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Reading SIM card...',
                              style: context.styles.body14Medium.copyWith(
                                color: context.colors.grey800,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const Spacer(flex: 3),

              // Error handling
              AppViewSelector<OnboardingVm, bool>(
                selector: (vm) => vm.hasEncounteredError,
                builder: (hasError, child) => hasError
                    ? Column(
                        children: [
                          Text(
                            'Failed to retrieve phone number',
                            style: context.styles.body16Medium.copyWith(
                              color: context.colors.attitudeErrorMain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please ensure your SIM card is properly inserted',
                            style: context.styles.body14Regular.copyWith(
                              color: context.colors.grey600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          AppButton.secondary(
                            label: 'Retry',
                            onPressed: _startFetching,
                            view: 'FetchingPhoneNumberPage',
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
