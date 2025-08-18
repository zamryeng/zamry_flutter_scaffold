import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/presentation.dart';
import '../../domain/onboarding_vm.dart';

class PermissionsDisclosurePage extends StatelessWidget {
  const PermissionsDisclosurePage({super.key, required this.onContinue, required this.onBack});

  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.colors.backgroundColor,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 14),
          child: AppIconButton(
            onPressed: onBack,
            label: 'Back',
            child: const Icon(Icons.arrow_back),
          ),
        ),
        title: Text('Required Permissions', style: context.styles.heading20Semibold),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),

            // Permissions list
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AppViewSelector<OnboardingVm, bool>(
                      selector: (vm) => vm.smsPermissionGranted,
                      builder: (smsPermissionGranted, _) => _buildPermissionItem(
                        context: context,
                        icon: Icons.sms_outlined,
                        title: 'Enable SMS',
                        description:
                            'Required to read SMS messages for transaction confirmations and OTP verification.',
                        isEnabled: smsPermissionGranted,
                        onTap: context.read<OnboardingVm>().requestSmsPermission,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppViewSelector<OnboardingVm, bool>(
                      selector: (vm) => vm.callPermissionGranted,
                      builder: (callPermissionGranted, _) => _buildPermissionItem(
                        context: context,
                        icon: Icons.call_outlined,
                        title: 'Enable Call',
                        description:
                            'Required to make USSD calls to your network provider for financial services.',
                        isEnabled: callPermissionGranted,
                        onTap: context.read<OnboardingVm>().requestCallPermission,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppViewSelector<OnboardingVm, bool>(
                      selector: (vm) => vm.accessibilityPermissionGranted,
                      builder: (accessibilityPermissionGranted, _) => _buildPermissionItem(
                        context: context,
                        icon: Icons.accessibility_outlined,
                        title: 'Enable Accessibility',
                        description:
                            'Required to automate USSD interactions and provide seamless user experience.',
                        isEnabled: accessibilityPermissionGranted,
                        onTap: context.read<OnboardingVm>().requestAccessibilityPermission,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Information note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.attitudeInfoLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.colors.attitudeInfoMain.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: context.colors.attitudeInfoMain, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These permissions are essential for the app to function properly. You can manage these permissions in your device settings at any time.',
                      style: context.styles.body14Regular.copyWith(
                        color: context.colors.attitudeInfoMain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Continue button
            AppViewSelector<OnboardingVm, bool>(
              selector: (vm) => vm.allPermissionsGranted,
              builder: (allPermissionsGranted, _) => AppButton.primary(
                label: 'Continue',
                enabled: allPermissionsGranted,
                onPressed: onContinue,
                view: 'PermissionsDisclosurePage',
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required bool isEnabled,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Material(
        color: context.colors.grey100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.colors.grey300),
        ),

        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: context.colors.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.styles.body16SemiBold),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: context.styles.body14Regular.copyWith(
                        color: context.colors.grey700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isEnabled ? context.colors.attitudeSuccessMain : context.colors.grey400,
                ),
                child: Icon(Icons.check, size: 16, color: context.colors.textAltColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
