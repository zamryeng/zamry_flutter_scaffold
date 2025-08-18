import 'package:flutter/material.dart';

import '../../../core/presentation/presentation.dart';
import '../../../core/service_locator/service_locator.dart';
import '../domain/onboarding_vm.dart';
import 'pages/pages.dart';

extension type const OnboardingPage(String value) {
  static const OnboardingPage countrySelection = OnboardingPage('country_selection');
  static const OnboardingPage networkSelection = OnboardingPage('network_selection');
  static const OnboardingPage simSlotSelection = OnboardingPage('sim_slot_selection');
  static const OnboardingPage termsOfService = OnboardingPage('terms_of_service');
  static const OnboardingPage permissionsDisclosure = OnboardingPage('permissions_disclosure');
  static const OnboardingPage fetchingNetworkPack = OnboardingPage('fetching_network_pack');
  static const OnboardingPage fetchingPhoneNumber = OnboardingPage('fetching_phone_number');
  static const OnboardingPage settingsSummary = OnboardingPage('settings_summary');

  static OnboardingPage fromString(String value) {
    return switch (value) {
      'country_selection' => countrySelection,
      'network_selection' => networkSelection,
      'sim_slot_selection' => simSlotSelection,
      'terms_of_service' => termsOfService,
      'permissions_disclosure' => permissionsDisclosure,
      'fetching_network_pack' => fetchingNetworkPack,
      'fetching_phone_number' => fetchingPhoneNumber,
      'settings_summary' => settingsSummary,
      _ => countrySelection,
    };
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.page,
    required this.onForward,
    required this.onComplete,
  });

  final OnboardingPage page;
  final void Function(OnboardingPage page) onForward;
  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingVm _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ServiceLocator.get<OnboardingVm>();
    _initializeViewModel();
  }

  Future<void> _initializeViewModel() async {
    await _viewModel.initialize();
  }

  void _handleCountryNext() {
    widget.onForward(OnboardingPage.networkSelection);
  }

  void _handleNetworkNext() {
    // For now, always go to SIM slot selection
    // In a real app, this would check device capabilities
    widget.onForward(OnboardingPage.simSlotSelection);
  }

  void _handleSimSlotNext() {
    widget.onForward(OnboardingPage.termsOfService);
  }

  void _handleTermsAgree() {
    widget.onForward(OnboardingPage.permissionsDisclosure);
  }

  void _handleTermsCancel() {
    widget.onForward(OnboardingPage.networkSelection);
  }

  void _handlePermissionsContinue() {
    widget.onForward(OnboardingPage.fetchingNetworkPack);
  }

  void _handleNetworkPackComplete() {
    widget.onForward(OnboardingPage.fetchingPhoneNumber);
  }

  void _handlePhoneNumberComplete() {
    widget.onForward(OnboardingPage.settingsSummary);
  }

  void _handleSettingsComplete() {
    widget.onComplete();
  }

  void _handleBack() {
    switch (widget.page) {
      case OnboardingPage.networkSelection:
        widget.onForward(OnboardingPage.countrySelection);
        break;
      case OnboardingPage.simSlotSelection:
        widget.onForward(OnboardingPage.networkSelection);
        break;
      case OnboardingPage.termsOfService:
        widget.onForward(OnboardingPage.networkSelection);
        break;
      case OnboardingPage.permissionsDisclosure:
        widget.onForward(OnboardingPage.termsOfService);
        break;
      default:
        widget.onForward(OnboardingPage.countrySelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.page == OnboardingPage.countrySelection,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: AppView<OnboardingVm>(
        model: _viewModel,
        builder: (vm, context) {
          return switch (widget.page) {
            OnboardingPage.countrySelection => SelectCountryPage(onNext: _handleCountryNext),
            OnboardingPage.networkSelection => SelectNetworkPage(
              onNext: _handleNetworkNext,
              onBack: _handleBack,
            ),
            OnboardingPage.simSlotSelection => SelectSimSlotPage(
              onNext: _handleSimSlotNext,
              onBack: _handleBack,
            ),
            OnboardingPage.termsOfService => TermsOfServicePage(
              onAgree: _handleTermsAgree,
              onCancel: _handleTermsCancel,
            ),
            OnboardingPage.permissionsDisclosure => PermissionsDisclosurePage(
              onContinue: _handlePermissionsContinue,
              onBack: _handleBack,
            ),
            OnboardingPage.fetchingNetworkPack => FetchingNetworkPackPage(
              onComplete: _handleNetworkPackComplete,
            ),
            OnboardingPage.fetchingPhoneNumber => FetchingPhoneNumberPage(
              onComplete: _handlePhoneNumberComplete,
            ),
            OnboardingPage.settingsSummary => SettingsSummaryPage(
              onComplete: _handleSettingsComplete,
            ),
            _ => throw UnimplementedError(),
          };
        },
      ),
    );
  }
}
