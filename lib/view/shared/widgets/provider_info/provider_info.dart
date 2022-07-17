import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/models/app_data.dart';
import 'package:mingo/services/location/location.dart';
import 'package:mingo/utils/station/station_util.dart';

class ProviderInfo extends StatefulWidget {
  final Station station;
  final bool popup;

  const ProviderInfo(
    this.station, {
    super.key,
    this.popup = false,
  });

  @override
  State<ProviderInfo> createState() => _ProviderInfoState();
}

class _ProviderInfoState extends State<ProviderInfo> {
  Price? _lowestPrice;
  String? _lowestPricedFuelName;

  @override
  void initState() {
    super.initState();
    if (widget.popup) {
      final prices = widget.station.priceList
          .where(
            (p) =>
                MinGOData.instance.fuels.firstWhere((f) => f.id == p.fuelId).fuelKindId == 9 && MinGOData.filterConfig.fuelTypeId == 3 ||
                MinGOData.instance.fuels.firstWhere((f) => f.id == p.fuelId).fuelKindId == 10 && MinGOData.filterConfig.fuelTypeId == 4 ||
                MinGOData.instance.fuels.firstWhere((f) => f.id == p.fuelId).fuelKindId == 1 && MinGOData.filterConfig.fuelTypeId == 1 ||
                MinGOData.instance.fuels.firstWhere((f) => f.id == p.fuelId).fuelKindId == 2 && MinGOData.filterConfig.fuelTypeId == 1 ||
                MinGOData.instance.fuels.firstWhere((f) => f.id == p.fuelId).fuelKindId == 7 && MinGOData.filterConfig.fuelTypeId == 2 ||
                MinGOData.instance.fuels.firstWhere((f) => f.id == p.fuelId).fuelKindId == 8 && MinGOData.filterConfig.fuelTypeId == 2,
          )
          .toList();
      prices.sort((a, b) => a.price!.compareTo(b.price!));
      _lowestPrice = prices[0];
      _lowestPricedFuelName = MinGOData.instance.fuels.firstWhere((e) => e.id == _lowestPrice!.fuelId).name;
    }
  }

  Set<String> get _iconIllustrations => <String>{
        'location_pin',
        if (LocationServices.locationData != null) 'location_group',
        'clock',
        if (widget.popup) 'payments',
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (MinGOData.penalisedProviders.where((e) => e.providerId == widget.station.id).isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.fiber_manual_record,
                    color: Color(0xffF75C4B),
                    size: 16,
                  ),
                ),
                Flexible(
                  child: Text(
                    'Posljednji puta ažurirano ' +
                        MinGOData.penalisedProviders.firstWhere((e) => e.providerId == widget.station.id).lastUpdated.day.toString() +
                        '.' +
                        MinGOData.penalisedProviders.firstWhere((e) => e.providerId == widget.station.id).lastUpdated.month.toString() +
                        '.' +
                        MinGOData.penalisedProviders.firstWhere((e) => e.providerId == widget.station.id).lastUpdated.year.toString() +
                        '.',
                    style: const TextStyle(
                      color: Color(0xffF75C4B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        for (int i = 0; i < _iconIllustrations.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SvgPicture.asset(
                    'assets/vectors/provider_page/' + (_iconIllustrations.elementAt(i)) + '.svg',
                    color: const Color(0xffC6C8CC),
                    fit: BoxFit.contain,
                    width: 16,
                    height: 16,
                  ),
                ),
                Flexible(
                  child: Text(
                    i == 0
                        ? widget.station.address
                        : i == 1 && LocationServices.locationData != null
                            ? LocationServices.getDistance(
                                  LocationServices.locationData!.latitude,
                                  LocationServices.locationData!.longitude,
                                  double.parse(widget.station.lat!),
                                  double.parse(widget.station.lng!),
                                ).toStringAsFixed(1) +
                                'km'
                            : i == 1 && LocationServices.locationData == null || i == 2 && LocationServices.locationData != null
                                ? 'Radno vrijeme: ${StationUtil.formattedTime(widget.station)}'
                                : _lowestPricedFuelName! +
                                    '\n' +
                                    (DateTime.now().year > 2023
                                        ? (_lowestPrice!.price! / 7.5345).toStringAsFixed(2) +
                                            ' EUR / L' +
                                            (DateTime.now().year < 2023 || DateTime.now().year == 2023 && DateTime.now().month < 6
                                                ? '  •  '
                                                : '')
                                        : '') +
                                    (DateTime.now().year < 2023 || DateTime.now().year == 2023 && DateTime.now().month < 6
                                        ? _lowestPrice!.price!.toString() + ' HRK / L'
                                        : '') +
                                    (DateTime.now().year < 2023
                                        ? '  •  ' + (_lowestPrice!.price! / 7.5345).toStringAsFixed(2) + ' EUR / L'
                                        : ''),
                    style: const TextStyle(
                      color: Color(0xffC6C8CC),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
