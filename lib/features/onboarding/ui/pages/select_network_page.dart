import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/presentation.dart';
import '../../../../core/presentation/ui_components/ui_components.dart';
import '../../data/models/country_model.dart';
import '../../domain/onboarding_vm.dart';

class SelectNetworkPage extends StatelessWidget {
  const SelectNetworkPage({super.key, required this.onNext, required this.onBack});

  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.colors.backgroundColor,
        elevation: 0,
        leading: AppBackButton(),
        title: Text('Select your Network', style: context.styles.heading20Semibold),
        centerTitle: true,
      ),
      body: AppViewSelector<OnboardingVm, bool>(
        selector: (vm) => vm.isBusy,
        builder: (isBusy, child) {
          if (isBusy) {
            return const Center(child: AppLoadingIndicator());
          }
          return child!;
        },
        child: AppViewSelector<OnboardingVm, bool>(
          selector: (vm) => vm.hasEncounteredError,
          builder: (hasError, child) {
            if (hasError) {
              return Center(child: ErrorView(error: context.read<OnboardingVm>().lastFailure!));
            }
            return child!;
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Selected country info
                AppViewSelector<OnboardingVm, CountryModel>(
                  selector: (vm) => vm.selectedCountry!,
                  builder: (selectedCountry, child) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.grey100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.colors.grey300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: context.colors.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Selected Country: ${selectedCountry.name}',
                          style: context.styles.body14Medium.copyWith(
                            color: context.colors.grey800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Provider dropdown
                AppDropdownField<ProviderModel>(
                  controller: context.read<OnboardingVm>().providerController,
                  label: 'Network Provider',
                  hint: 'Select your network provider',
                  isRequired: true,
                  onChanged: (provider) {
                    context.read<OnboardingVm>().onProviderSelected(provider);
                  },
                  itemBuilder: (provider) =>
                      Text(provider.name, style: context.styles.body16Regular),
                ),

                const Spacer(),

                // Next button
                AppViewSelector<OnboardingVm, bool>(
                  selector: (vm) => vm.canProceedFromProviderSelection,
                  builder: (canProceed, child) => AppButton.primary(
                    label: 'Next',
                    onPressed: canProceed ? onNext : () {},
                    enabled: canProceed,
                    view: 'SelectNetworkPage',
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
