class PriceTrendModel {
  final DateTime lastUpdated;
  final int fuelId;
  final double price;

  PriceTrendModel({
    required this.lastUpdated,
    required this.fuelId,
    required this.price,
  });

  factory PriceTrendModel.fromJson(Map<String, dynamic> json) => PriceTrendModel(
        lastUpdated: DateTime.parse(json['dat_poc']),
        fuelId: json['tip_goriva_id'],
        price: json['avg_cijena'].toDouble(),
      );
}
