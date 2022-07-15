import 'package:flutter/material.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/models/app_data.dart';
import 'package:mingo/utils/station/station_util.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/bloc/open_stations_controller.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/elements/open_stations/open_stations.dart';
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
                      : Column(
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
                                                  MinGOData.setFuelKind(_selectedFuelKind == value ? null : value + 1);
                                                  MinGOData.mapReferencePoint = widget.mapKey.currentState!.mapController.center;
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
                                                  MinGOData.setDistance(MinGOData.filterConfig.distanceId == value ? null : value);
                                                  MinGOData.mapReferencePoint = widget.mapKey.currentState!.mapController.center;
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
                            const DashboardPageOpenStations(searchView: true),
                          ],
                        ),
            ),
          );
  }
}
