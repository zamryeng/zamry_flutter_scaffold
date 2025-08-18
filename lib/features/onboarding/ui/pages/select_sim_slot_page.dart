import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/presentation.dart';
import '../../domain/onboarding_vm.dart';

class SelectSimSlotPage extends StatelessWidget {
  const SelectSimSlotPage({super.key, required this.onNext, required this.onBack});

  final VoidCallback onNext;
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),

            // Title
            Text(
              'SIM Slot selection',
              style: context.styles.heading20Bold,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              'Your device has multiple SIM cards. Please select which SIM slot you want to use for USSD operations.',
              style: context.styles.body16Regular.copyWith(color: context.colors.grey700),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // SIM Slot options
            AppViewSelector<OnboardingVm, int>(
              selector: (vm) => vm.selectedSimSlot ?? 0,
              builder: (selectedSlot, child) => Column(
                children: [
                  _buildSimSlotOption(
                    context: context,
                    slotNumber: 1,
                    isSelected: selectedSlot == 1,
                    onTap: () => context.read<OnboardingVm>().selectSimSlot(1),
                  ),
                  const SizedBox(height: 16),
                  _buildSimSlotOption(
                    context: context,
                    slotNumber: 2,
                    isSelected: selectedSlot == 2,
                    onTap: () => context.read<OnboardingVm>().selectSimSlot(2),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Next button
            AppViewSelector<OnboardingVm, bool>(
              selector: (vm) => vm.canProceedFromSimSlotSelection,
              builder: (canProceed, child) => AppButton.primary(
                label: 'Next',
                onPressed: canProceed ? onNext : () {},
                enabled: canProceed,
                view: 'SelectSimSlotPage',
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSimSlotOption({
    required BuildContext context,
    required int slotNumber,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primaryColor.withValues(alpha: 0.1)
              : context.colors.grey100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.colors.primaryColor : context.colors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? context.colors.primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? context.colors.primaryColor : context.colors.grey600,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: context.colors.textAltColor)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SIM Slot $slotNumber', style: context.styles.body16SemiBold),
                  const SizedBox(height: 4),
                  Text(
                    'Use SIM card in slot $slotNumber for USSD operations',
                    style: context.styles.body14Regular.copyWith(color: context.colors.grey600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
