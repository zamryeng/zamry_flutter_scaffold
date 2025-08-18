import 'package:flutter/material.dart';

import '../../../../core/presentation/presentation.dart';
import '../../domain/onboarding_vm.dart';

class SettingsSummaryPage extends StatelessWidget {
  const SettingsSummaryPage({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.colors.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // Success icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.colors.attitudeSuccessMain.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 50,
                  color: context.colors.attitudeSuccessMain,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Setup Complete!',
              style: context.styles.heading20Bold,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Your USSD utility is ready to use',
              style: context.styles.body16Regular.copyWith(color: context.colors.grey700),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Settings summary
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AppViewSelector<OnboardingVm, String>(
                      selector: (vm) => vm.selectedCountry?.name ?? 'Not selected',
                      builder: (countryName, child) => _buildSummaryItem(
                        context: context,
                        icon: Icons.location_on_outlined,
                        title: 'Country',
                        value: countryName,
                        iconColor: context.colors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppViewSelector<OnboardingVm, String>(
                      selector: (vm) => vm.selectedProvider?.name ?? 'Not selected',
                      builder: (providerName, child) => _buildSummaryItem(
                        context: context,
                        icon: Icons.network_cell,
                        title: 'Network',
                        value: providerName,
                        iconColor: context.colors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppViewSelector<OnboardingVm, String>(
                      selector: (vm) => vm.fetchedPhoneNumber ?? 'Not available',
                      builder: (phoneNumber, child) => _buildSummaryItem(
                        context: context,
                        icon: Icons.phone,
                        title: 'Phone Number',
                        value: phoneNumber,
                        iconColor: context.colors.attitudeSuccessMain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppViewSelector<OnboardingVm, String>(
                      selector: (vm) =>
                          vm.selectedSimSlot != null ? 'SIM Slot ${vm.selectedSimSlot}' : 'Default',
                      builder: (simSlotText, child) => _buildSummaryItem(
                        context: context,
                        icon: Icons.sim_card,
                        title: 'Slot #',
                        value: simSlotText,
                        iconColor: context.colors.attitudeWarningMain,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Complete button
            AppButton.primary(
              label: 'Get Started',
              onPressed: onComplete,
              view: 'SettingsSummaryPage',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.grey300),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.styles.body14Medium.copyWith(color: context.colors.grey600),
                ),
                const SizedBox(height: 4),
                Text(value, style: context.styles.body16SemiBold),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: context.colors.attitudeSuccessMain, size: 20),
        ],
      ),
    );
  }
}
