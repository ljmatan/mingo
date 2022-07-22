class PenalisedProviderModel {
  final int providerId;
  final DateTime lastUpdated;

  PenalisedProviderModel({
    required this.providerId,
    required this.lastUpdated,
  });

  factory PenalisedProviderModel.fromJson(Map<String, dynamic> json) {
    return PenalisedProviderModel(
      providerId: json['stationId'],
      lastUpdated: DateTime.parse(json['lastUpdated']).subtract(const Duration(days: 10)),
    );
  }
}
