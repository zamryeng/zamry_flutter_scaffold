class CountryModel {
  final String id;
  final String name;
  final String code;
  final List<ProviderModel> providers;

  const CountryModel({
    required this.id,
    required this.name,
    required this.code,
    required this.providers,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}

class ProviderModel {
  final String id;
  final String name;
  final String type; // e.g., 'bank', 'mobile_money'
  final String countryId;

  const ProviderModel({
    required this.id,
    required this.name,
    required this.type,
    required this.countryId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}
