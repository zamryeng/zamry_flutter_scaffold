import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/presentation.dart';
import '../../../../core/presentation/ui_components/ui_components.dart';
import '../../data/models/country_model.dart';
import '../../domain/onboarding_vm.dart';

class SelectCountryPage extends StatelessWidget {
  const SelectCountryPage({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.colors.backgroundColor,
        elevation: 0,
        leading: AppBackButton(),
        title: Text('Select your Country', style: context.styles.heading20Semibold),
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
                const SizedBox(height: 32),

                // Country dropdown
                AppDropdownField<CountryModel>(
                  controller: context.read<OnboardingVm>().countryController,
                  label: 'Country',
                  hint: 'Select your country',
                  isRequired: true,
                  onChanged: (country) {
                    context.read<OnboardingVm>().onCountrySelected(country);
                  },
                  itemBuilder: (country) => Text(country.name, style: context.styles.body16Regular),
                ),

                const Spacer(),

                // Next button
                AppViewSelector<OnboardingVm, bool>(
                  selector: (vm) => vm.canProceedFromCountrySelection,
                  builder: (canProceed, child) => AppButton.primary(
                    label: 'Next',
                    onPressed: canProceed ? onNext : () {},
                    enabled: canProceed,
                    view: 'SelectCountryPage',
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
