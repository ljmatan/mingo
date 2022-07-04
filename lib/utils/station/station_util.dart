import 'package:flutter/material.dart' show Color;
import 'package:mingo/models/app_data.dart';

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

abstract class StationUtil {
  static final DateTime today = DateTime.now();

  static final Set<String> _holidays = {
    '2021-01-01',
    '2021-01-06',
    '2021-04-04',
    '2021-04-05',
    '2021-05-01',
    '2021-06-03',
    '2021-06-22',
    '2021-08-05',
    '2021-08-15',
    '2021-11-01',
    '2021-11-18',
    '2021-12-25',
    '2021-12-26',
    '2022-01-01',
    '2022-01-06',
    '2022-04-17',
    '2022-04-18',
    '2022-05-01',
    '2022-05-30',
    '2022-06-16',
    '2022-06-22',
    '2022-08-05',
    '2022-08-15',
    '2022-11-01',
    '2022-11-18',
    '2022-12-25',
    '2022-12-26',
  };

  static int get dayType {
    if (today.weekday == 6) return 1;
    if (today.weekday == 7) return 2;

    for (var iso8601Date in _holidays) {
      final DateTime date = DateTime.parse(iso8601Date);
      if (today.isSameDate(date)) return 3;
    }

    return 0;
  }

  static bool isOpen(Station station) {
    try {
      return DateTime.now().hour >= int.parse(station.workTimes[dayType].opening.split(':').first) &&
          DateTime.now().hour <= int.parse(station.workTimes[dayType].close.split(':').first);
    } catch (e) {
      return DateTime.now().hour >= int.parse(station.workTimes[0].opening.split(':').first) &&
          DateTime.now().hour <= int.parse(station.workTimes[0].close.split(':').first);
    }
  }

  static String formattedTime(Station station) {
    final times = station.workTimes.length > dayType ? station.workTimes[dayType] : station.workTimes.first;

    return times.opening.substring(0, 5) + ' - ' + times.close.substring(0, 5);
  }

  static Color timeColor(Station station) {
    return isOpen(station) ? const Color(0xffB7FFEB) : const Color(0xffFFB3A9);
  }
}
