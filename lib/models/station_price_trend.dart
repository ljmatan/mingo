class StationPriceTrendModel {
  final DateTime lastUpdated;
  final int fuelId;
  final double price;

  StationPriceTrendModel({
    required this.lastUpdated,
    required this.fuelId,
    required this.price,
  });

  factory StationPriceTrendModel.fromJson(Map<String, dynamic> json) => StationPriceTrendModel(
        lastUpdated: DateTime.parse(json['dat_poc']),
        fuelId: json['gorivo_id'],
        price: json['cijena'] as double,
      );
}
