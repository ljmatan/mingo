class PenalisedProviderModel {
  final int providerId;
  final DateTime lastUpdated;

  PenalisedProviderModel({
    required this.providerId,
    required this.lastUpdated,
  });

  factory PenalisedProviderModel.fromJson(Map<String, dynamic> json) {
    return PenalisedProviderModel(
      providerId: json['providerId'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}
