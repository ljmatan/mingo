import 'package:flutter/foundation.dart';
import 'package:mingo/models/app_data.dart';
import 'package:mingo/models/penalised_provider.dart';
import 'package:mingo/models/price_trend.dart';
import 'package:mingo/services/location/location.dart';
import 'package:mingo/utils/station/station_util.dart';
import 'package:latlong2/latlong.dart';
import 'package:mingo/view/shared/bloc/map_markers_controller.dart';
import 'package:mingo/view/theme.dart';

class _FilterConfig {
  int? fuelTypeId = 1, distanceId;
  bool electricFriendly = false;

  _FilterConfig();
}

abstract class MinGOData {
  static late AppDataModel instance;
  static _FilterConfig filterConfig = _FilterConfig();

  static set input(AppDataModel value) {
    value.stations.removeWhere(
      (e) {
        final lat = double.tryParse(e.lat ?? '');
        final lng = double.tryParse(e.lng ?? '');
        if (lat == null || lng == null) return true;
        if (lat < 40 || lat > 50) return true;
        if (lng < 10 || lng > 20) return true;
        return false;
      },
    );
    value.providers.removeWhere((p) => value.stations.where((s) => s.providerId == p.id).isEmpty);
    for (var station in value.stations) {
      station.priceList.sort(
        (a, b) => value.fuels
            .firstWhere((e) => e.id == a.fuelId)
            .fuelKindId!
            .compareTo(value.fuels.firstWhere((e) => e.id == b.fuelId).fuelKindId!),
      );
    }
    value.places.sort((a, b) => a.name.compareTo(b.name));
    value.fuelTypes.removeWhere((e) => e.fuelKindId > 4);
    instance = value;
  }

  static late List<Station> stationsInRadius;
  static late List<Station> stations;

  static late List<Station> orderedStations;

  static List<Station> _getOrderedStations(Map<String, dynamic> data) {
    debugPrint('Ordering stations');
    int? fuelTypeId = data['fuelTypeId'];
    debugPrint('fuelTypeId $fuelTypeId ${fuelTypeId.runtimeType}');
    if (fuelTypeId == null) {
      return <Station>[];
    } else if (fuelTypeId == 3) {
      fuelTypeId = 9;
    } else if (fuelTypeId == 4) {
      fuelTypeId = 10;
    }

    final stations = List<Station>.from(data['stations']);
    debugPrint('stations ${stations.runtimeType}');
    final fuels = List<Fuel>.from(data['fuels']);
    debugPrint('fuelss ${fuels.runtimeType}');

    final orderedList = <Map>[];

    for (var station in stations) {
      if (!StationUtil.isOpen(station)) continue;
      late Iterable<Price> prices;
      if (fuelTypeId == 1) {
        prices = station.priceList.where(
          (price) => fuels
              .where(
                (fuel) =>
                    fuel.id == price.fuelId && fuel.fuelKindId == 1 ||
                    fuel.id == price.fuelId && fuel.fuelKindId == 2 ||
                    fuel.id == price.fuelId && fuel.fuelKindId == 5 ||
                    fuel.id == price.fuelId && fuel.fuelKindId == 6,
              )
              .isNotEmpty,
        );
      } else if (fuelTypeId == 2) {
        prices = station.priceList.where(
          (price) => fuels
              .where(
                (fuel) =>
                    fuel.id == price.fuelId && fuel.fuelKindId == 7 ||
                    fuel.id == price.fuelId && fuel.fuelKindId == 8 ||
                    fuel.id == price.fuelId && fuel.fuelKindId == 11 ||
                    fuel.id == price.fuelId && fuel.fuelKindId == 13,
              )
              .isNotEmpty,
        );
      } else {
        prices = station.priceList.where(
          (price) => fuels.where((fuel) => fuel.id == price.fuelId && fuel.fuelKindId == fuelTypeId).isNotEmpty,
        );
      }
      if (prices.isEmpty) continue;
      var lowestPrice = double.infinity;
      for (var price in prices) {
        if (price.price! < lowestPrice) lowestPrice = price.price!;
      }
      final Map stationMap = {
        'price': lowestPrice,
        'station': station,
      };
      if (orderedList.isEmpty) {
        orderedList.add(stationMap);
      } else {
        final int newIndex = orderedList.indexWhere((e) => e['price'] > lowestPrice);
        if (newIndex != -1) {
          orderedList.insert(newIndex, stationMap);
        } else {
          orderedList.add(stationMap);
        }
      }
    }

    final serialised = <Station>[for (var stationMap in orderedList) stationMap['station']];

    return serialised;
  }

  static Future<List<Station>> _computeOrderedStations(Map<String, dynamic> data) async {
    debugPrint('Computing ordered stations');
    data['fuelTypeId'] = filterConfig.fuelTypeId;
    debugPrint('data[\'fuelTypeId\'] ${data['fuelTypeId']} ${data['fuelTypeId'].runtimeType}');
    orderedStations = !kIsWeb ? _getOrderedStations(data) : await compute(_getOrderedStations, data);
    debugPrint('Ordered stations ${orderedStations.length}');
    return orderedStations;
  }

  static Set<Set<int>> _filterStationIdsByFuelKind(Map<String, dynamic> data) {
    final stations = List<Station>.from(data['stations']);
    final fuels = List<Fuel>.from(data['fuels']);
    return {
      for (var fuelKindId in <int>{1, 2, 9, 10})
        Set<int>.from(
          stations
              .where(
                (station) => station.priceList
                    .where(
                      (price) =>
                          fuelKindId == 1 && fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 1 ||
                          fuelKindId == 1 && fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 2 ||
                          fuelKindId == 1 && fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 5 ||
                          fuelKindId == 1 && fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 6 ||
                          fuelKindId == 2 && fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 7 ||
                          fuelKindId == 2 && fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 8 ||
                          fuelKindId == 2 && fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 11 ||
                          fuelKindId == 2 && fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == 13 ||
                          fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == fuelKindId,
                    )
                    .isNotEmpty,
              )
              .map((e) => e.id),
        ),
    };
  }

  static late Set<Set<int>> _fuelTypesByStation;
  static Future<void> getFuelTypesByStation() async {
    debugPrint('Processing app data');
    final data = {
      'stations': MinGOData.instance.stations,
      'fuels': MinGOData.instance.fuels,
    };
    debugPrint('data ${data.runtimeType}');
    _fuelTypesByStation = kIsWeb ? _filterStationIdsByFuelKind(data) : await compute(_filterStationIdsByFuelKind, data);
    debugPrint('_fuelTypesByStation $_fuelTypesByStation ${_fuelTypesByStation.runtimeType}');
  }

  static bool isFuelKind(Station station) {
    final fuelTypeId = filterConfig.fuelTypeId != null ? filterConfig.fuelTypeId! - 1 : null;
    return filterConfig.fuelTypeId == null || _fuelTypesByStation.elementAt(fuelTypeId!).contains(station.id);
  }

  static bool isElectricFriendly(Station station) {
    return !filterConfig.electricFriendly || station.options.where((e) => e.optionId == 20).isNotEmpty;
  }

  static double? get selectedDistance {
    switch (filterConfig.distanceId) {
      case 0:
        return 2.5;
      case 1:
        return 5;
      case 2:
        return 7.5;
      case 3:
        return 12.5;
      case 4:
        return 25;
      default:
        return null;
    }
  }

  static bool isWithinRadius(Station station, [bool openStations = false]) {
    return selectedDistance == null && !openStations ||
        LocationServices.getDistance(
              double.parse(station.lat!),
              double.parse(station.lng!),
              MinGOData.mapFocusLocation.latitude,
              MinGOData.mapFocusLocation.longitude,
            ) <
            (openStations ? (MinGOTheme.screenWidth < 1000 ? 5 : 10) : ((selectedDistance != null ? selectedDistance! : null) ?? 50));
  }

  static List<Station> _getStationsInRadius(List<Station> stations) {
    return stations.where((e) => isWithinRadius(e)).toList();
  }

  static List<Station> get getOpenStations => orderedStations.where((e) => StationUtil.isOpen(e) && e.priceList.length > 2).toList();
  static late List<Station> openStations;

  static Future<List<Station>> getStationsInRadius() async {
    stationsInRadius = kIsWeb ? _getStationsInRadius(instance.stations) : await compute(_getStationsInRadius, instance.stations);
    await _computeOrderedStations({
      'stations': stationsInRadius,
      'fuels': instance.fuels,
    });
    return stationsInRadius;
  }

  static void setFuelKind(int? fuelKindId, [bool rebuild = true]) {
    filterConfig.fuelTypeId = fuelKindId;
    if (rebuild) updateFilteredMarkers();
  }

  static void setEVFriendly(bool value, [bool rebuild = true]) {
    filterConfig.electricFriendly = value;
    if (rebuild) updateFilteredMarkers();
  }

  static void setDistance(int? distanceId, [bool rebuild = true]) {
    filterConfig.distanceId = distanceId;
    if (rebuild) updateFilteredMarkers();
  }

  static List<Station> _getFilteredStations() {
    return stationsInRadius
        .where(
          (e) =>
              isFuelKind(e) &&
              isElectricFriendly(e) &&
              isWithinRadius(e) &&
              isFilteredFuelType(e) &&
              isFilteredOption(e) &&
              isFilteredWorkDay(MinGOData.filteredWorkDays, MinGOData.filteredWorkDaysTimes, e) &&
              isFilteredProvider(e),
        )
        .toList();
  }

  static final filteredFuelTypes = <Map<String, dynamic>>[];
  static bool isFilteredFuelType(Station station) {
    if (filteredFuelTypes.isEmpty) return true;
    return station.priceList.any(
      (price) {
        return filteredFuelTypes.where(
          (e) {
            return e['id'] == 1 &&
                    (1 ==
                            instance.fuels.firstWhere(
                              (f) {
                                return f.id == price.fuelId;
                              },
                            ).fuelKindId ||
                        2 ==
                            instance.fuels.firstWhere(
                              (f) {
                                return f.id == price.fuelId;
                              },
                            ).fuelKindId ||
                        5 ==
                            instance.fuels.firstWhere(
                              (f) {
                                return f.id == price.fuelId;
                              },
                            ).fuelKindId ||
                        6 ==
                            instance.fuels.firstWhere(
                              (f) {
                                return f.id == price.fuelId;
                              },
                            ).fuelKindId) ||
                e['id'] == 2 &&
                    (7 ==
                            instance.fuels.firstWhere(
                              (f) {
                                return f.id == price.fuelId;
                              },
                            ).fuelKindId ||
                        8 ==
                            instance.fuels.firstWhere(
                              (f) {
                                return f.id == price.fuelId;
                              },
                            ).fuelKindId ||
                        11 ==
                            instance.fuels.firstWhere(
                              (f) {
                                return f.id == price.fuelId;
                              },
                            ).fuelKindId ||
                        13 ==
                            instance.fuels.firstWhere(
                              (f) {
                                return f.id == price.fuelId;
                              },
                            ).fuelKindId) ||
                e['id'] == 3 &&
                    (9 ==
                        instance.fuels.firstWhere(
                          (f) {
                            return f.id == price.fuelId;
                          },
                        ).fuelKindId) ||
                e['id'] == 4 &&
                    (10 ==
                        instance.fuels.firstWhere(
                          (f) {
                            return f.id == price.fuelId;
                          },
                        ).fuelKindId);
          },
        ).isNotEmpty;
      },
    );
  }

  static final filteredOptions = <int>[];
  static bool isFilteredOption(Station station) =>
      filteredOptions.isEmpty || station.options.any((o) => filteredOptions.contains(o.optionId));

  static final filteredWorkDays = <int>{};
  static final filteredWorkDaysTimes = <String>{};
  static bool isFilteredWorkDay(Set<int> daysOfTheWeek, Set<String> times, Station station) {
    if (daysOfTheWeek.isEmpty && times.isEmpty) return true;

    if (daysOfTheWeek.isNotEmpty) {
      if ((daysOfTheWeek.contains(5) || daysOfTheWeek.contains(6)) &&
          station.workTimes.where((e) => e.dayTypeId == 2 || e.dayTypeId == 3).isEmpty) return false;

      if (daysOfTheWeek.where((e) => e < 5).isNotEmpty && station.workTimes.where((e) => e.dayTypeId == 1).isEmpty) return false;
    }

    if (times.length == 2) return true;

    if (times.isNotEmpty) {
      bool open(WorkTimes stationTimes) {
        double minsFraction(double mins) => mins * (1 / 60);
        final stationStart = stationTimes.opening;
        final stationEnd = stationTimes.close;
        final filteredSStart = stationStart.split(':');
        final filteredSEnd = stationEnd.split(':');
        final sStartHour = double.parse(filteredSStart.first);
        final sStartMin = double.parse(filteredSStart.last);
        final sEndHour = double.parse(filteredSEnd.first);
        final sEndMin = double.parse(filteredSEnd.last);
        final sStartTime = sStartHour + minsFraction(sStartMin);
        final sEndTime = sEndHour + minsFraction(sEndMin);
        for (var time in times) {
          final filtered = time.split(' - ');
          final filteredStart = filtered.first.split(':');
          final filteredEnd = filtered.last.split(':');
          final fStartHour = double.parse(filteredStart.first);
          final fStartMin = double.parse(filteredStart.last);
          final fEndHour = double.parse(filteredEnd.first);
          final fEndMin = double.parse(filteredEnd.last);
          final fStartTime = fStartHour + minsFraction(fStartMin);
          final fEndTime = fEndHour + minsFraction(fEndMin);
          if (sStartTime > fStartTime || sEndTime < fEndTime) return false;
        }
        return true;
      }

      if (daysOfTheWeek.isNotEmpty) {
        for (var day in daysOfTheWeek) {
          final WorkTimes stationTimes =
              station.workTimes.firstWhere((e) => day < 5 ? e.dayTypeId == 1 : e.dayTypeId == 2 || e.dayTypeId == 3);
          if (!open(stationTimes)) return false;
        }
      } else {
        final List<WorkTimes> stationTimes = station.workTimes.where((e) => e.dayTypeId == 1).toList();
        if (stationTimes.isEmpty || !open(stationTimes.first)) return false;
      }
    }

    return true;
  }

  static final filteredProviders = <int>[];
  static bool isFilteredProvider(Station station) => filteredProviders.isEmpty || filteredProviders.contains(station.providerId);

  static void updateFilteredMarkers() {
    stations = _getFilteredStations();
    _computeOrderedStations({
      'stations': stations,
      'fuels': instance.fuels,
    }).whenComplete(() {
      MapMarkersController.update(stations);
    });
  }

  static LatLng mapFocusLocation = LatLng(45.8150, 15.9819);
  static set mapReferencePoint(LatLng value) {
    mapFocusLocation = value;
    getStationsInRadius().whenComplete(() {
      updateFilteredMarkers();
    });
  }

  static void resetFilters() {
    filterConfig.fuelTypeId = 1;
    filterConfig.electricFriendly = false;
    filterConfig.distanceId = null;
    filteredFuelTypes.clear();
    filteredOptions.clear();
    filteredWorkDays.clear();
    filteredWorkDaysTimes.clear();
    filteredProviders.clear();
    updateFilteredMarkers();
  }

  static final List<int> selectedProviders = [];

  static List<Station> get selectedProvidersStations => instance.stations.where((e) => selectedProviders.contains(e.providerId)).toList();

  static late List<PriceTrendModel> priceTrends;

  static int? get appliedFilters {
    final appliedLength = filteredFuelTypes.length + filteredOptions.length + filteredWorkDays.length + filteredProviders.length;
    if (appliedLength > 0) {
      return appliedLength;
    } else {
      return null;
    }
  }

  static final List<PenalisedProviderModel> penalisedProviders = [
    {'lastUpdated': '2022-06-23T00:00:00.000', 'stationId': 1242},
    {'lastUpdated': '2022-06-21T00:00:00.000', 'stationId': 1358},
    {'lastUpdated': '2022-06-21T00:00:00.000', 'stationId': 1359},
    {'lastUpdated': '2022-06-08T00:00:00.000', 'stationId': 1255},
    {'lastUpdated': '2022-06-23T00:00:00.000', 'stationId': 1260},
    {'lastUpdated': '2020-10-02T00:00:00.000', 'stationId': 61},
    {'lastUpdated': '2017-10-30T00:00:00.000', 'stationId': 707},
    {'lastUpdated': '2022-06-14T00:00:00.000', 'stationId': 1369},
    {'lastUpdated': '2022-06-21T00:00:00.000', 'stationId': 803},
    {'lastUpdated': '2022-06-21T00:00:00.000', 'stationId': 802},
    {'lastUpdated': '2016-11-08T00:00:00.000', 'stationId': 811},
    {'lastUpdated': '2020-04-28T00:00:00.000', 'stationId': 886},
    {'lastUpdated': '2020-04-07T00:00:00.000', 'stationId': 945},
    {'lastUpdated': '2016-07-19T00:00:00.000', 'stationId': 1005},
    {'lastUpdated': '2022-05-30T00:00:00.000', 'stationId': 1010},
    {'lastUpdated': '2022-06-08T00:00:00.000', 'stationId': 1015},
    {'lastUpdated': '2020-04-14T00:00:00.000', 'stationId': 1098},
    {'lastUpdated': '2022-06-08T00:00:00.000', 'stationId': 1173},
    {'lastUpdated': '2022-06-08T00:00:00.000', 'stationId': 1175},
    {'lastUpdated': '2016-11-08T00:00:00.000', 'stationId': 810},
    {'lastUpdated': '2022-06-21T00:00:00.000', 'stationId': 816},
    {'lastUpdated': '2022-06-21T00:00:00.000', 'stationId': 817},
    {'lastUpdated': '2022-06-21T00:00:00.000', 'stationId': 822},
    {'lastUpdated': '2019-04-15T00:00:00.000', 'stationId': 828},
    {'lastUpdated': '2022-01-19T00:00:00.000', 'stationId': 830},
    {'lastUpdated': '2022-06-21T00:00:00.000', 'stationId': 835},
    {'lastUpdated': '2022-06-21T00:00:00.000', 'stationId': 840},
    {'lastUpdated': '2021-06-29T00:00:00.000', 'stationId': 842},
    {'lastUpdated': '2017-05-02T00:00:00.000', 'stationId': 862},
    {'lastUpdated': '2016-03-15T00:00:00.000', 'stationId': 863},
    {'lastUpdated': '2022-03-14T00:00:00.000', 'stationId': 865},
    {'lastUpdated': '2022-05-17T00:00:00.000', 'stationId': 866},
    {'lastUpdated': '2022-06-09T00:00:00.000', 'stationId': 871},
    {'lastUpdated': '2022-06-09T00:00:00.000', 'stationId': 875},
    {'lastUpdated': '2016-08-31T00:00:00.000', 'stationId': 889},
    {'lastUpdated': '2022-06-21T00:00:00.000', 'stationId': 903},
    {'lastUpdated': '2017-03-21T00:00:00.000', 'stationId': 907},
    {'lastUpdated': '2022-06-21T00:00:00.000', 'stationId': 908},
    {'lastUpdated': '2020-06-30T00:00:00.000', 'stationId': 934},
    {'lastUpdated': '2022-06-08T00:00:00.000', 'stationId': 939},
    {'lastUpdated': '2021-06-01T00:00:00.000', 'stationId': 940},
    {'lastUpdated': '2022-06-21T00:00:00.000', 'stationId': 900},
    {'lastUpdated': '2022-06-08T00:00:00.000', 'stationId': 910},
    {'lastUpdated': '2021-09-28T00:00:00.000', 'stationId': 966},
    {'lastUpdated': '2022-06-08T00:00:00.000', 'stationId': 973},
    {'lastUpdated': '2022-06-08T00:00:00.000', 'stationId': 974},
    {'lastUpdated': '2022-03-27T00:00:00.000', 'stationId': 976},
    {'lastUpdated': '2019-07-18T00:00:00.000', 'stationId': 984},
    {'lastUpdated': '2022-03-22T00:00:00.000', 'stationId': 990},
    {'lastUpdated': '2015-02-27T00:00:00.000', 'stationId': 1004},
    {'lastUpdated': '2020-04-14T00:00:00.000', 'stationId': 1013},
    {'lastUpdated': '2019-10-01T00:00:00.000', 'stationId': 1023},
    {'lastUpdated': '2022-06-09T00:00:00.000', 'stationId': 1035},
    {'lastUpdated': '2022-06-09T00:00:00.000', 'stationId': 1047},
    {'lastUpdated': '2022-06-09T00:00:00.000', 'stationId': 1059},
    {'lastUpdated': '2022-06-21T00:00:00.000', 'stationId': 1061},
    {'lastUpdated': '2022-06-21T00:00:00.000', 'stationId': 1120},
    {'lastUpdated': '2022-06-09T00:00:00.000', 'stationId': 1075},
    {'lastUpdated': '2021-06-01T00:00:00.000', 'stationId': 1082},
    {'lastUpdated': '2022-06-09T00:00:00.000', 'stationId': 1085},
    {'lastUpdated': '2022-06-21T00:00:00.000', 'stationId': 1048},
    {'lastUpdated': '2022-06-08T00:00:00.000', 'stationId': 1145},
    {'lastUpdated': '2022-06-09T00:00:00.000', 'stationId': 1153},
    {'lastUpdated': '2022-06-21T00:00:00.000', 'stationId': 1146},
    {'lastUpdated': '2022-06-21T00:00:00.000', 'stationId': 1116},
    {'lastUpdated': '2022-06-16T00:00:00.000', 'stationId': 1118},
    {'lastUpdated': '2022-06-09T00:00:00.000', 'stationId': 1160},
    {'lastUpdated': '2022-06-08T00:00:00.000', 'stationId': 1174},
    {'lastUpdated': '2022-06-08T00:00:00.000', 'stationId': 1176},
    {'lastUpdated': '2022-06-08T00:00:00.000', 'stationId': 1180}
  ].map((e) => PenalisedProviderModel.fromJson(e)).toList();
}
