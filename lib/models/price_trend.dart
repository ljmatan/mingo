class PriceTrendModel {
  final DateTime lastUpdated;
  int fuelId;
  double price;

  PriceTrendModel({
    required this.lastUpdated,
    required this.fuelId,
    required this.price,
  });

  factory PriceTrendModel.fromJson(Map<String, dynamic> json) => PriceTrendModel(
        lastUpdated: DateTime.parse(json['dat_poc']),
        fuelId: json['tip_goriva_id'] ?? json['gorivo_id'],
        price: (json['cijena'] ?? json['avg_cijena']).toDouble(),
      );
}
