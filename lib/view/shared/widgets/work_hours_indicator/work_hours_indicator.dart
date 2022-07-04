import 'package:flutter/material.dart';
import 'package:mingo/models/app_data.dart';
import 'package:mingo/utils/station/station_util.dart';

class WorkHoursIndicator extends StatelessWidget {
  final Station station;

  const WorkHoursIndicator(this.station, {super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: StationUtil.timeColor(station),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 5),
        child: Text(
          StationUtil.isOpen(station) ? 'Otvoreno' : 'Zatvoreno',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
