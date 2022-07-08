import 'package:flutter/foundation.dart';
import 'package:mingo/models/app_data.dart';
import 'package:mingo/models/price_trend.dart';
import 'package:mingo/services/location/location.dart';
import 'package:mingo/utils/station/station_util.dart';
import 'package:latlong2/latlong.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/bloc/open_stations_controller.dart';
import 'package:mingo/view/shared/bloc/map_markers_controller.dart';

class _FilterConfig {
  int? fuelTypeId = 1, distanceId;

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
    value.fuels.removeWhere((e) => e.name == null || e.providerId == null || e.fuelKindId == null);
    value.fuels.removeWhere((f) => value.stations.where((s) => s.priceList.where((p) => p.fuelId == f.id).isNotEmpty).isEmpty);
    value.providers.removeWhere((p) => value.stations.where((s) => s.providerId == p.id).isEmpty);
    instance = value;
  }

  static late List<Station> stationsInRadius;
  static late List<Station> stations;

  static late List<Station> orderedStations;

  static List<Station> _getOrderedStations(Map<String, dynamic> data) {
    debugPrint('Ordering stations');
    final fuelTypeId = data['fuelTypeId'] as int?;
    debugPrint('fuelTypeId $fuelTypeId ${fuelTypeId.runtimeType}');
    if (fuelTypeId == null) return <Station>[];

    final stations = List<Station>.from(data['stations']);
    debugPrint('stations $stations ${stations.runtimeType}');
    final fuels = List<Fuel>.from(data['fuels']);
    debugPrint('fuels $fuels ${fuels.runtimeType}');

    final orderedList = <Map>[];

    for (var station in stations) {
      final prices = station.priceList.where(
        (price) => fuels.where((fuel) => fuel.id == price.fuelId && fuel.fuelKindId == fuelTypeId).isNotEmpty,
      );
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
      for (var fuelKindId in <int>{1, 2, 3, 4})
        Set<int>.from(
          stations
              .where(
                (station) => station.priceList
                    .where((price) => fuels.firstWhere((fuel) => fuel.id == price.fuelId).fuelKindId == fuelKindId)
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
    debugPrint('data $data ${data.runtimeType}');
    _fuelTypesByStation = kIsWeb ? _filterStationIdsByFuelKind(data) : await compute(_filterStationIdsByFuelKind, data);
    debugPrint('_fuelTypesByStation $_fuelTypesByStation ${_fuelTypesByStation.runtimeType}');
  }

  static bool isFuelKind(Station station) {
    final fuelTypeId = filterConfig.fuelTypeId != null ? filterConfig.fuelTypeId! - 1 : null;
    return filterConfig.fuelTypeId == null || _fuelTypesByStation.elementAt(fuelTypeId!).contains(station.id);
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
            ((selectedDistance != null ? selectedDistance! : null) ?? 50);
  }

  static List<Station> _getStationsInRadius(List<Station> stations) {
    return stations.where((e) => isWithinRadius(e)).toList();
  }

  static List<Station> get getOpenStations =>
      stations.where((e) => StationUtil.isOpen(e) && isWithinRadius(e, true) && e.priceList.length > 2).toList();
  static late List<Station> openStations;

  static Future<List<Station>> getStationsInRadius() async {
    stationsInRadius = kIsWeb ? _getStationsInRadius(instance.stations) : await compute(_getStationsInRadius, instance.stations);
    await _computeOrderedStations({
      'stations': stationsInRadius,
      'fuels': instance.fuels,
    });
    return stationsInRadius;
  }

  static void setFuelKind(int? fuelKindId) {
    filterConfig.fuelTypeId = fuelKindId;
    updateFilteredMarkers();
  }

  static void setDistance(int? distanceId) {
    filterConfig.distanceId = distanceId;
    updateFilteredMarkers();
  }

  static List<Station> _getFilteredStations() {
    return stationsInRadius
        .where(
          (e) =>
              isFuelKind(e) &&
              isWithinRadius(e) &&
              isFilteredFuelType(e) &&
              isFilteredOption(e) &&
              isFilteredWorkDay(MinGOData.filteredWorkDays, MinGOData.filteredWorkDaysTimes, e) &&
              isFilteredProvider(e),
        )
        .toList();
  }

  static final filteredFuelTypes = <Map<String, dynamic>>[];
  static bool isFilteredFuelType(Station station) =>
      filteredFuelTypes.isEmpty ||
      station.priceList.any(
        (price) => filteredFuelTypes.where((e) => e['id'] == instance.fuels.firstWhere((f) => f.id == price.fuelId).fuelKindId).isNotEmpty,
      );

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
      openStations = getOpenStations;
      DashboardPageOpenStationsController.update(openStations);
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
    filterConfig.distanceId = null;
    filteredFuelTypes.clear();
    filteredOptions.clear();
    filteredWorkDays.clear();
    filteredProviders.clear();
    updateFilteredMarkers();
  }

  static final List<int> selectedProviders = [];

  static List<Station> get selectedProvidersStations => instance.stations.where((e) => selectedProviders.contains(e.providerId)).toList();

  static late List<PriceTrendModel> priceTrends;
}
