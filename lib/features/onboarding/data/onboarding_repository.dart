import '../../../core/data/data.dart';
import 'models/country_model.dart';

class OnboardingRepository extends AppRepository {
  OnboardingRepository();

  /// Mock data for countries and their providers
  static final List<CountryModel> _mockCountries = [
    CountryModel(
      id: 'ng',
      name: 'Nigeria',
      code: 'NG',
      providers: [
        ProviderModel(id: 'opay_ng', name: 'Opay', type: 'mobile_money', countryId: 'ng'),
        ProviderModel(id: 'gtb_ng', name: 'Guaranty Trust Bank', type: 'bank', countryId: 'ng'),
      ],
    ),
    CountryModel(
      id: 'gh',
      name: 'Ghana',
      code: 'GH',
      providers: [
        ProviderModel(
          id: 'mtn_gh',
          name: 'MTN Mobile Money',
          type: 'mobile_money',
          countryId: 'gh',
        ),
        ProviderModel(
          id: 'vodafone_gh',
          name: 'Vodafone Cash',
          type: 'mobile_money',
          countryId: 'gh',
        ),
      ],
    ),
    CountryModel(
      id: 'ke',
      name: 'Kenya',
      code: 'KE',
      providers: [
        ProviderModel(
          id: 'mpesa_ke',
          name: 'Safaricom M-Pesa',
          type: 'mobile_money',
          countryId: 'ke',
        ),
      ],
    ),
    CountryModel(
      id: 'ug',
      name: 'Uganda',
      code: 'UG',
      providers: [
        ProviderModel(id: 'mtn_ug', name: 'MTN MoMo', type: 'mobile_money', countryId: 'ug'),
        ProviderModel(id: 'airtel_ug', name: 'Airtel Money', type: 'mobile_money', countryId: 'ug'),
      ],
    ),
  ];

  /// Get all available countries
  Future<DataResponse<List<CountryModel>>> getCountries() => runDataWithGuard(() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return DataResponse(data: _mockCountries);
  });

  /// Get providers for a specific country
  Future<DataResponse<List<ProviderModel>>> getProvidersForCountry(String countryId) =>
      runDataWithGuard(() async {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 300));

        final country = _mockCountries.firstWhere(
          (c) => c.id == countryId,
          orElse: () => throw Exception('Country not found'),
        );

        return DataResponse(data: country.providers);
      });

  /// Get a specific country by ID
  Future<DataResponse<CountryModel?>> getCountryById(String countryId) =>
      runDataWithGuard(() async {
        final country = _mockCountries.where((c) => c.id == countryId).firstOrNull;
        return DataResponse(data: country);
      });

  /// Get a specific provider by ID
  Future<DataResponse<ProviderModel?>> getProviderById(String providerId) =>
      runDataWithGuard(() async {
        for (final country in _mockCountries) {
          final provider = country.providers.where((p) => p.id == providerId).firstOrNull;
          if (provider != null) {
            return DataResponse(data: provider);
          }
        }
        return DataResponse(data: null);
      });
}
