import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mingo/models/app_data.dart';
import 'package:mingo/services/location/location.dart';
import 'package:mingo/utils/station/station_util.dart';

class ProviderInfo extends StatelessWidget {
  final Station station;

  const ProviderInfo(this.station, {super.key});

  static Set<String> get _iconIllustrations => <String>{
        'location_pin',
        if (LocationServices.locationData != null) 'location_group',
        'clock',
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                        ? station.address
                        : i == 1 && LocationServices.locationData != null
                            ? LocationServices.getDistance(
                                  LocationServices.locationData!.latitude,
                                  LocationServices.locationData!.longitude,
                                  double.parse(station.lat!),
                                  double.parse(station.lng!),
                                ).toStringAsFixed(1) +
                                'km'
                            : 'Radno vrijeme: ${StationUtil.formattedTime(station)}',
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
