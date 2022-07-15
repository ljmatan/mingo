import 'package:flutter/material.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/models/app_data.dart';
import 'package:mingo/services/location/location.dart';
import 'package:mingo/view/routes/main_route/bloc/page_controller.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/bloc/open_stations_controller.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/elements/open_stations/open_stations.dart';
import 'package:mingo/view/shared/widgets/chart/chart_section.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/elements/large_station_preview/large_station_preview.dart';
import 'package:mingo/view/shared/basic/action_button.dart';
import 'package:mingo/view/shared/widgets/footer/footer.dart';
import 'package:mingo/view/shared/widgets/map/leaflet_map.dart';
import 'package:mingo/view/shared/widgets/title/title.dart';
import 'package:mingo/view/shared/widgets/newsletter_subscription/newsletter_subscription_field.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/elements/map/map.dart';
import 'package:latlong2/latlong.dart';

import 'elements/search_field/search_field.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  static GlobalKey<DashboardPageSearchFieldState>? searchFieldKey;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    DashboardPage.searchFieldKey = GlobalKey<DashboardPageSearchFieldState>();
  }

  final _mapKey = GlobalKey<LeafletMapState>();

  final _searchFieldController = TextEditingController();

  final _scrollController = ScrollController();
  bool _scrollEnabled = true;
  void _enableScroll(bool enabled) => setState(() => _scrollEnabled = enabled);

  bool _searchViewOpened = false;
  void _onSearchViewOpened(bool opened) async {
    setState(() => _searchViewOpened = opened);
    _scrollController.jumpTo(0);
  }

  bool _filterViewOpened = false;
  void _onFilterViewOpened(bool opened) async {
    setState(() => _filterViewOpened = opened);
    _scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          controller: _scrollController,
          physics: _scrollEnabled ? null : const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: MediaQuery.of(context).size.width < 1000
              ? [
                  DashboardPageSearchField(
                    key: MediaQuery.of(context).size.width >= 1000 ? DashboardPage.searchFieldKey : null,
                    mapKey: _mapKey,
                    searchFieldController: _searchFieldController,
                    onSearchViewOpened: _onSearchViewOpened,
                    onFilterViewOpened: _onFilterViewOpened,
                  ),
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Color(0xff16FFBD),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.ev_station),
                          ),
                          Expanded(
                            child: Text('Informacije punionica za električna vozila dolaze uskoro!'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DashboardPageMap(
                    mapKey: _mapKey,
                    enableScroll: _enableScroll,
                  ),
                  const DashboardPageOpenStations(),
                  const FuelTrendsChartSection(),
                  const NewsletterSubscriptionField(),
                  const Footer(),
                ]
              : [
                  Row(
                    children: [
                      DashboardPageSearchField(
                        key: DashboardPage.searchFieldKey,
                        mapKey: _mapKey,
                        searchFieldController: _searchFieldController,
                        onSearchViewOpened: _onSearchViewOpened,
                        onFilterViewOpened: _onFilterViewOpened,
                      ),
                      DashboardPageMap(
                        mapKey: _mapKey,
                        enableScroll: _enableScroll,
                      ),
                    ],
                  ),
                  if (MinGOData.openStations.length - 3 > 0)
                    const Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.white),
                        child: Padding(
                          padding: EdgeInsets.only(top: 90, bottom: 33),
                          child: MinGOTitle(
                            label: 'Otvorene postaje',
                            subtitle: 'Pronađite najpovoljniju benzinsku postaju',
                            iconFilename: 'vectors/dashboard/gas_tank_illustration.svg',
                          ),
                        ),
                      ),
                    ),
                  if (MinGOData.openStations.length - 3 > 0)
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Color(0xffF9F9F9),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: StreamBuilder<List<Station>>(
                          stream: DashboardPageOpenStationsController.stream,
                          initialData: MinGOData.openStations,
                          builder: (context, openStations) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (int i = 3;
                                        i <
                                            (MediaQuery.of(context).size.width > 1300
                                                ? ((MinGOData.openStations.length - 3) < 7 ? (MinGOData.openStations.length - 3) : 7)
                                                : ((MinGOData.openStations.length - 3) < 6 ? (MinGOData.openStations.length - 3) : 6));
                                        i++)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: DashboardPageLargeStationPreview(
                                          MinGOData.openStations[i],
                                        ),
                                      ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: Center(
                                    child: MinGOActionButton(
                                      label: 'Prikaži više',
                                      icon: Icons.chevron_right,
                                      minWidth: true,
                                      onTap: () => MainRoutePageController.navigateTo(1),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  const FuelTrendsChartSection(),
                  const NewsletterSubscriptionField(),
                  const Footer(),
                ],
        ),
        if ((_searchViewOpened || _filterViewOpened) && MediaQuery.of(context).size.width < 1000)
          DashboardPageSearchField(
            key: MediaQuery.of(context).size.width < 1000 ? DashboardPage.searchFieldKey : null,
            mapKey: _mapKey,
            searchFieldController: _searchFieldController,
            onSearchViewOpened: _onSearchViewOpened,
            onFilterViewOpened: _onFilterViewOpened,
          ),
      ],
    );
  }

  @override
  void dispose() {
    DashboardPage.searchFieldKey = null;
    _scrollController.dispose();
    _searchFieldController.dispose();
    MinGOData.mapReferencePoint = LatLng(
      LocationServices.locationData?.latitude ?? 45.8150,
      LocationServices.locationData?.latitude ?? 15.9819,
    );
    MinGOData.resetFilters();
    super.dispose();
  }
}
