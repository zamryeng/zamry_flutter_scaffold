import '../../../core/domain/failure.dart';
import '../../../core/presentation/presentation.dart';
import '../data/models/country_model.dart';
import '../data/onboarding_repository.dart';

class OnboardingVm extends AppViewModel {
  final OnboardingRepository _repository;

  OnboardingVm({required OnboardingRepository repository}) : _repository = repository;

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

    final response = await _repository.getCountries();
    if (response.isSuccessful) {
      _countries = response.data!;
      countryController.options = _countries;
      _countriesLoaded = true;
      setState(VmState.none);
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
