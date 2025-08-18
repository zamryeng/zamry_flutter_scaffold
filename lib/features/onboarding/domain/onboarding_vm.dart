import 'package:collection/collection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ussd/ussd.dart';

import '../../../core/domain/failure.dart';
import '../../../core/presentation/presentation.dart';
import '../../../services/app_lifecycle_service/app_lifecycle_service.dart';
import '../../../services/build_info_service/build_info_service.dart';
import '../data/models/country_model.dart';
import '../data/onboarding_repository.dart';

class OnboardingVm extends AppViewModel {
  final OnboardingRepository _repository;
  final BuildInfoService _buildInfoService;
  final AppLifecycleService _lifecycleService;

  OnboardingVm({
    required OnboardingRepository repository,
    required BuildInfoService buildInfoService,
    required AppLifecycleService lifecycleService,
  }) : _repository = repository,
       _buildInfoService = buildInfoService,
       _lifecycleService = lifecycleService;

  // Controllers for dropdowns
  final countryController = DropdownValueController<CountryModel>();
  final providerController = DropdownValueController<ProviderModel>();

  // State management
  List<CountryModel> _countries = [];
  List<ProviderModel> _providers = [];
  bool _countriesLoaded = false;
  bool _providersLoaded = false;
  bool _networkPackFetched = false;
  bool _phoneNumberFetched = false;

  // Additional data
  int? _selectedSimSlot;
  String? _fetchedPhoneNumber;

  // Permissions
  bool _smsPermissionGranted = false;
  bool _callPermissionGranted = false;
  bool _accessibilityPermissionGranted = false;

  // Getters
  List<CountryModel> get countries => _countries;

  List<ProviderModel> get providers => _providers;

  bool get countriesLoaded => _countriesLoaded;

  bool get providersLoaded => _providersLoaded;

  bool get networkPackFetched => _networkPackFetched;

  bool get phoneNumberFetched => _phoneNumberFetched;

  CountryModel? get selectedCountry => countryController.value;

  ProviderModel? get selectedProvider => providerController.value;

  int? get selectedSimSlot => _selectedSimSlot;

  String? get fetchedPhoneNumber => _fetchedPhoneNumber;

  bool get smsPermissionGranted => _smsPermissionGranted;

  bool get callPermissionGranted => _callPermissionGranted;

  bool get accessibilityPermissionGranted => _accessibilityPermissionGranted;

  bool get allPermissionsGranted =>
      _smsPermissionGranted && _callPermissionGranted && _accessibilityPermissionGranted;

  bool get canProceedFromCountrySelection => selectedCountry != null;

  bool get canProceedFromProviderSelection => selectedProvider != null;

  bool get canProceedFromSimSlotSelection => _selectedSimSlot != null;

  @override
  void dispose() {
    countryController.dispose();
    providerController.dispose();
    super.dispose();
  }

  /// Initialize the view model by loading countries
  Future<void> initialize() async {
    if (_countriesLoaded) return;

    setState(VmState.busy);

    final (response, localeInfo) = await (
      _repository.getCountries(),
      _buildInfoService.localeInfo,
    ).wait;

    if (response.isSuccessful) {
      _countries = response.data!;
      countryController.options = _countries;
      _countriesLoaded = true;
      final country = _countries.firstWhereOrNull(
        (c) => c.code.toLowerCase() == localeInfo.countryCode.toLowerCase(),
      );
      setState(VmState.none);

      onCountrySelected(country);
    } else {
      handleErrorAndSetVmState(response.error!);
    }
  }

  /// Load providers for the selected country
  Future<void> loadProvidersForSelectedCountry() async {
    final country = selectedCountry;
    if (country == null) return;

    setState(VmState.busy);

    final response = await _repository.getProvidersForCountry(country.id);
    if (response.isSuccessful) {
      _providers = response.data!;
      providerController.options = _providers;
      providerController.clear(); // Clear previous selection
      _providersLoaded = true;
      setState(VmState.none);
    } else {
      handleErrorAndSetVmState(response.error!);
    }
  }

  /// Handle country selection
  void onCountrySelected(CountryModel? country) {
    if (country == null) return;

    countryController.value = country;
    // Clear provider selection when country changes
    providerController.clear();
    _providers.clear();
    _providersLoaded = false;

    // Load providers for the new country
    loadProvidersForSelectedCountry();
    setState();
  }

  /// Handle provider selection
  void onProviderSelected(ProviderModel? provider) {
    if (provider == null) return;

    providerController.value = provider;
    setState();
  }

  /// Reset the onboarding state
  void reset() {
    countryController.clear();
    providerController.clear();
    _providers.clear();
    _providersLoaded = false;
    setState();
  }

  /// Handle SIM slot selection
  void selectSimSlot(int slot) {
    _selectedSimSlot = slot;
    setState();
  }

  /// Fetch network pack (simulated)
  Future<void> fetchNetworkPack() async {
    setState(VmState.busy);

    try {
      // Simulate network pack fetching
      await Future.delayed(const Duration(seconds: 2));
      _networkPackFetched = true;
      setState(VmState.none);
    } catch (e) {
      handleErrorAndSetVmState(ServerFailure(message: 'Failed to fetch network pack'));
    }
  }

  Future<void> requestSmsPermission() async {
    if (!_smsPermissionGranted) {
      final permission = await Permission.sms.request();
      _smsPermissionGranted = permission.isGranted;
      setState();
    }
  }

  Future<void> requestCallPermission() async {
    if (!_callPermissionGranted) {
      final permission = await Permission.phone.request();
      _callPermissionGranted = permission.isGranted;
      setState();
    }
  }

  void _accessibilityPermissionListener(bool isAppPaused) {
    if (!isAppPaused) {
      requestAccessibilityPermission();
    }
  }

  Future<void> requestAccessibilityPermission() async {
    if (!_accessibilityPermissionGranted) {
      try {
        final isSetup = await Ussd.instance.setup();
        _accessibilityPermissionGranted = isSetup;
        if (_accessibilityPermissionGranted) {
          _lifecycleService.removeListener(_accessibilityPermissionListener);
        }
        setState();
      } on AccessibilityPermissionRequiredException {
        await Ussd.instance.openAccessibilitySettings();

        _lifecycleService.addListener(_accessibilityPermissionListener);
        setState();
      } on UssdDialerException catch (e) {
        handleErrorAndSetVmState(ServerFailure(message: e.message));
      }
    }
  }

  /// Fetch phone number (simulated)
  Future<void> fetchPhoneNumber() async {
    setState(VmState.busy);

    try {
      // Simulate phone number fetching
      await Future.delayed(const Duration(seconds: 2));

      // Mock phone number based on selected country
      final countryCode = selectedCountry?.code ?? 'NG';
      switch (countryCode) {
        case 'NG':
          _fetchedPhoneNumber = '+234 801 234 5678';
          break;
        case 'GH':
          _fetchedPhoneNumber = '+233 24 123 4567';
          break;
        case 'KE':
          _fetchedPhoneNumber = '+254 712 345 678';
          break;
        case 'UG':
          _fetchedPhoneNumber = '+256 701 234 567';
          break;
        default:
          _fetchedPhoneNumber = '+000 000 000 000';
      }

      _phoneNumberFetched = true;
      setState(VmState.none);
    } catch (e) {
      handleErrorAndSetVmState(ServerFailure(message: 'Failed to fetch phone number'));
    }
  }

  /// Get the current onboarding data as a summary
  Map<String, dynamic> getOnboardingData() {
    return {
      'country': selectedCountry?.name,
      'countryCode': selectedCountry?.code,
      'provider': selectedProvider?.name,
      'providerType': selectedProvider?.type,
      'simSlot': _selectedSimSlot,
      'phoneNumber': _fetchedPhoneNumber,
    };
  }
}
