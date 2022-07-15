import 'package:flutter/material.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/models/app_data.dart';
import 'package:mingo/utils/station/station_util.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/bloc/open_stations_controller.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/elements/search_field/elements/animated_dropdown/animated_dropdown.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/elements/search_field/elements/filter_view/filter_view.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/elements/search_field/elements/search_view/search_view.dart';
import 'package:mingo/view/routes/provider_details/provider_details_route.dart';
import 'package:mingo/view/shared/basic/action_button.dart';
import 'package:mingo/view/shared/widgets/fuel_preview/fuel_preview.dart';
import 'package:mingo/view/shared/widgets/map/leaflet_map.dart';
import 'package:mingo/view/shared/widgets/provider_info/provider_info.dart';

class DashboardPageSearchTextInputField extends StatelessWidget {
  final TextEditingController searchFieldController;
  final bool autofocus, enabled;
  final void Function()? onTap;

  const DashboardPageSearchTextInputField({
    super.key,
    required this.searchFieldController,
    this.autofocus = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: TextField(
        controller: searchFieldController,
        autofocus: autofocus,
        enabled: enabled,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          suffixIcon: const Icon(Icons.search),
          hintText: 'Upišite lokaciju...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide.none,
          ),
        ),
        onTap: onTap,
      ),
      onTap: enabled || onTap == null ? null : () => onTap!(),
    );
  }
}

class DashboardPageSearchField extends StatefulWidget {
  final GlobalKey<LeafletMapState> mapKey;
  final TextEditingController searchFieldController;
  final Function(bool) onSearchViewOpened, onFilterViewOpened;

  const DashboardPageSearchField({
    super.key,
    required this.mapKey,
    required this.searchFieldController,
    required this.onSearchViewOpened,
    required this.onFilterViewOpened,
  });

  static const filterButtonLabels = <String>{
    'Vrsta goriva',
    'Udaljenost',
    'Filter',
  };

  static const fuelKinds = <String>['Benzin', 'Dizel', 'Autoplin', 'Plinsko ulje'];
  static const distances = <String>['5 km', '10 km', '15 km', '25 km', '50 km'];

  @override
  State<DashboardPageSearchField> createState() => DashboardPageSearchFieldState();
}

class DashboardPageSearchFieldState extends State<DashboardPageSearchField> {
  static bool _searchView = false;
  static bool _filterView = false;

  void resetView() {
    if (_searchView) {
      _searchView = false;
      widget.onSearchViewOpened(false);
    }
    if (_filterView) {
      _filterView = false;
      widget.onFilterViewOpened(false);
    }
  }

  int? get _selectedFuelKind {
    try {
      return MinGOData.filterConfig.fuelTypeId! - 1;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width < 1000
        ? _searchView
            ? DashboardPageSearchView(
                mapKey: widget.mapKey,
                searchFieldController: widget.searchFieldController,
                closeSearchView: () {
                  _searchView = false;
                  widget.onSearchViewOpened(false);
                },
              )
            : _filterView
                ? DashboardPageFilterView(
                    closeFilterView: () {
                      _filterView = false;
                      widget.onFilterViewOpened(false);
                    },
                  )
                : DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Color(0xff435467),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: DashboardPageSearchTextInputField(
                              searchFieldController: widget.searchFieldController,
                              enabled: false,
                              onTap: () {
                                _searchView = true;
                                widget.onSearchViewOpened(true);
                              },
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: DashboardPageAnimatedDropdown(
                                  label: DashboardPageSearchField.filterButtonLabels.elementAt(0),
                                  children: DashboardPageSearchField.fuelKinds,
                                  selectedIndex: () => _selectedFuelKind,
                                  onItemSelected: (value) {
                                    switch (value) {
                                      case 0:
                                      case 1:
                                      case 2:
                                      case 3:
                                        if (_selectedFuelKind != value) {
                                          MinGOData.mapReferencePoint = widget.mapKey.currentState!.mapController.center;
                                          MinGOData.setFuelKind(value + 1);
                                        } else {
                                          throw 'Already selected';
                                        }
                                        break;
                                      default:
                                        throw 'Not implemented';
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DashboardPageAnimatedDropdown(
                                  label: DashboardPageSearchField.filterButtonLabels.elementAt(1),
                                  children: DashboardPageSearchField.distances,
                                  selectedIndex: () => MinGOData.filterConfig.distanceId,
                                  onItemSelected: (value) {
                                    switch (value) {
                                      case 0:
                                      case 1:
                                      case 2:
                                      case 3:
                                      case 4:
                                        MinGOData.mapReferencePoint = widget.mapKey.currentState!.mapController.center;
                                        MinGOData.setDistance(MinGOData.filterConfig.distanceId == value ? null : value);
                                        break;
                                      default:
                                        throw 'Not implemented';
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: MinGOActionButton(
                                  label: DashboardPageSearchField.filterButtonLabels.elementAt(2) +
                                      (MinGOData.appliedFilters == null ? '' : ' (${MinGOData.appliedFilters})'),
                                  icon: Icons.percent,
                                  underlined: true,
                                  iconSize: 20,
                                  onTap: () {
                                    _filterView = true;
                                    widget.onFilterViewOpened(true);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
        : SizedBox(
            width: MediaQuery.of(context).size.width * (2 / 5),
            height: MediaQuery.of(context).size.width < 1000
                ? MediaQuery.of(context).size.height / 2
                : MediaQuery.of(context).size.height > 1000
                    ? 800
                    : 600,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xffF9F9F9),
              ),
              child: _searchView
                  ? DashboardPageSearchView(
                      mapKey: widget.mapKey,
                      searchFieldController: widget.searchFieldController,
                      closeSearchView: () {
                        _searchView = false;
                        widget.onSearchViewOpened(false);
                      },
                    )
                  : _filterView
                      ? DashboardPageFilterView(
                          closeFilterView: () {
                            _searchView = false;
                            widget.onFilterViewOpened(false);
                          },
                        )
                      : StreamBuilder<List<Station>>(
                          stream: DashboardPageOpenStationsController.stream,
                          initialData: MinGOData.openStations,
                          builder: (context, openStations) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DecoratedBox(
                                  decoration: const BoxDecoration(
                                    color: Color(0xff435467),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: DashboardPageSearchTextInputField(
                                            searchFieldController: widget.searchFieldController,
                                            enabled: false,
                                            onTap: () {
                                              _searchView = false;
                                              widget.onSearchViewOpened(true);
                                            },
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DashboardPageAnimatedDropdown(
                                                label: DashboardPageSearchField.filterButtonLabels.elementAt(0),
                                                children: DashboardPageSearchField.fuelKinds,
                                                selectedIndex: () => _selectedFuelKind,
                                                onItemSelected: (value) {
                                                  switch (value) {
                                                    case 0:
                                                    case 1:
                                                    case 2:
                                                    case 3:
                                                      MinGOData.mapReferencePoint = widget.mapKey.currentState!.mapController.center;
                                                      MinGOData.setFuelKind(_selectedFuelKind == value ? null : value + 1);
                                                      break;
                                                    default:
                                                      throw 'Not implemented';
                                                  }
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: DashboardPageAnimatedDropdown(
                                                label: DashboardPageSearchField.filterButtonLabels.elementAt(1),
                                                children: DashboardPageSearchField.distances,
                                                selectedIndex: () => MinGOData.filterConfig.distanceId,
                                                onItemSelected: (value) {
                                                  switch (value) {
                                                    case 0:
                                                    case 1:
                                                    case 2:
                                                    case 3:
                                                    case 4:
                                                      MinGOData.mapReferencePoint = widget.mapKey.currentState!.mapController.center;
                                                      MinGOData.setDistance(MinGOData.filterConfig.distanceId == value ? null : value);
                                                      break;
                                                    default:
                                                      throw 'Not implemented';
                                                  }
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: MinGOActionButton(
                                                label: DashboardPageSearchField.filterButtonLabels.elementAt(2) +
                                                    (MinGOData.appliedFilters == null ? '' : ' (${MinGOData.appliedFilters})'),
                                                icon: Icons.percent,
                                                iconSize: 20,
                                                onTap: () {
                                                  _filterView = false;
                                                  widget.onFilterViewOpened(true);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: Text(
                                    'Otvorene postaje',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                if (MinGOData.openStations.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 14),
                                    child: Text('Nema pronađenih postaja'),
                                  )
                                else
                                  for (int i = 0;
                                      i <
                                          (MediaQuery.of(context).size.height > 1000
                                              ? (MinGOData.openStations.length < 3 ? MinGOData.openStations.length : 3)
                                              : (MinGOData.openStations.length < 2 ? MinGOData.openStations.length : 2));
                                      i++)
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                                        child: InkWell(
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: const Color(0xffE7E7E7),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxHeight: (MediaQuery.of(context).size.width < 1000
                                                          ? MediaQuery.of(context).size.height / 2
                                                          : MediaQuery.of(context).size.height > 1000
                                                              ? 800
                                                              : 600) /
                                                      3,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                MinGOData.openStations[i].place,
                                                                style: const TextStyle(fontSize: 12),
                                                              ),
                                                              Text(
                                                                MinGOData.openStations[i].name,
                                                                style: const TextStyle(
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 18,
                                                                ),
                                                              ),
                                                              ProviderInfo(
                                                                MinGOData.openStations[i],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              DecoratedBox(
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(100),
                                                                  color: StationUtil.timeColor(MinGOData.openStations[i]),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                                                  child: Text(
                                                                    StationUtil.isOpen(MinGOData.openStations[i])
                                                                        ? 'Otvoreno'
                                                                        : 'Zatvoreno',
                                                                  ),
                                                                ),
                                                              ),
                                                              const Padding(
                                                                padding: EdgeInsets.only(top: 16, bottom: 6),
                                                                child: Text(
                                                                  'Radno vrijeme',
                                                                  style: TextStyle(
                                                                    color: Color(0xffC6C8CC),
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                StationUtil.formattedTime(MinGOData.openStations[i]),
                                                                style: const TextStyle(
                                                                  color: Color(0xffC6C8CC),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        for (int j = 0; j < 2; j++)
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  i == 0 ? const EdgeInsets.only(right: 4) : const EdgeInsets.only(left: 4),
                                                              child: FuelPreview(MinGOData.openStations[i].priceList[j]),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          onTap: () => Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (BuildContext context) => ProviderDetailsRoute(MinGOData.openStations[i]),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              ],
                            );
                          }),
            ),
          );
  }
}
