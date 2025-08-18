import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/presentation.dart';
import '../../domain/onboarding_vm.dart';

class FetchingNetworkPackPage extends StatefulWidget {
  const FetchingNetworkPackPage({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<FetchingNetworkPackPage> createState() => _FetchingNetworkPackPageState();
}

class _FetchingNetworkPackPageState extends State<FetchingNetworkPackPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_startFetching);
  }

  Future<void> _startFetching() async {
    final vm = context.read<OnboardingVm>();
    await vm.fetchNetworkPack();

    // Auto-proceed after successful fetch
    if (vm.networkPackFetched && mounted) {
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

              // Loading animation
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
                        ? SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.colors.primaryColor,
                              ),
                            ),
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
                selector: (vm) => vm.networkPackFetched,
                builder: (fetched, child) => Text(
                  fetched ? 'Network Pack Ready!' : 'Fetching Network Pack',
                  style: context.styles.heading20Bold,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              AppViewSelector<OnboardingVm, bool>(
                selector: (vm) => vm.networkPackFetched,
                builder: (fetched, child) => Text(
                  fetched
                      ? 'Successfully configured your network settings.'
                      : 'Please wait while we configure your network settings...',
                  style: context.styles.body16Regular.copyWith(color: context.colors.grey700),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),

              // Provider info
              AppViewSelector<OnboardingVm, String>(
                selector: (vm) => vm.selectedProvider?.name ?? 'Network Provider',
                builder: (providerName, child) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.grey100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.colors.grey300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.network_cell, color: context.colors.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Configuring: $providerName',
                        style: context.styles.body14Medium.copyWith(color: context.colors.grey800),
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
                            'Failed to fetch network pack',
                            style: context.styles.body16Medium.copyWith(
                              color: context.colors.attitudeErrorMain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppButton.secondary(
                            label: 'Retry',
                            onPressed: _startFetching,
                            view: 'FetchingNetworkPackPage',
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
