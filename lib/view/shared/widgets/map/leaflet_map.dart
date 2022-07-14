import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/models/app_data.dart';
import 'package:mingo/services/location/location.dart';
import 'package:mingo/utils/station/station_util.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/bloc/open_stations_controller.dart';
import 'package:mingo/view/routes/provider_details/provider_details_route.dart';
import 'package:mingo/view/shared/basic/action_button.dart';
import 'package:mingo/view/shared/bloc/map_markers_controller.dart';
import 'package:mingo/view/shared/widgets/map/bloc/station_preview_controller.dart';
import 'package:mingo/view/shared/widgets/provider_info/provider_info.dart';
import 'package:mingo/view/shared/widgets/work_hours_indicator/work_hours_indicator.dart';

class _MapMarker extends StatelessWidget {
  final Station station;
  final int? index;
  final void Function()? onTap;

  const _MapMarker(
    this.station, {
    this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: index != null
              ? Colors.amber
              : StationUtil.isOpen(station)
                  ? const Color(0xff16FFBD)
                  : const Color(0xffFFB3A9),
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 3,
          ),
        ),
        child: SizedBox.fromSize(
          size: Size(
            MediaQuery.of(context).size.width < 1000 ? 40 : 30,
            MediaQuery.of(context).size.width < 1000 ? 40 : 30,
          ),
          child: index != null
              ? Center(
                  child: Text(
                    '${index! + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                )
              : null,
        ),
      ),
      onTap: onTap,
    );
  }
}

class LeafletMap extends StatefulWidget {
  final Station? station;
  final bool providersSearch;

  const LeafletMap({
    super.key,
    this.station,
    this.providersSearch = false,
  });

  @override
  State<LeafletMap> createState() => LeafletMapState();
}

class LeafletMapState extends State<LeafletMap> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final mapController = MapController();

  final _bounds = LatLngBounds(
    LatLng(42.366662, 13.370361),
    LatLng(46.694667, 19.511719),
  );

  AnimationController? _animationController;

  double? _lockedZoom;
  void enableInput(bool enabled) {
    if (kIsWeb && _animationController?.isAnimating != true) setState(() => _lockedZoom = enabled ? null : mapController.zoom);
  }

  Future<void> move({
    double? lat,
    double? lng,
    double? zoom,
    bool absoluteZoomValue = true,
    bool animated = true,
  }) async {
    assert(lat == null && lng == null || lat != null && lng != null);
    if (!animated && lat != null && lng != null) {
      mapController.move(LatLng(lat, lng), mapController.zoom);
      return;
    }
    if (zoom == null && lat == mapController.center.latitude && lng == mapController.center.longitude) return;
    double zoomValue = absoluteZoomValue ? (zoom ?? mapController.zoom) : mapController.zoom + (zoom ?? 0);
    if (zoomValue < 9 || zoomValue > 16) zoomValue = mapController.zoom;
    final zoomTween = Tween<double>(
      begin: mapController.zoom,
      end: zoomValue,
    );
    final latTween = Tween<double>(
      begin: mapController.center.latitude,
      end: (lat != null && lng != null && !_bounds.contains(LatLng(lat, lng)) ? null : lat) ?? mapController.center.latitude,
    );
    final lngTween = Tween<double>(
      begin: mapController.center.longitude,
      end: (lat != null && lng != null && !_bounds.contains(LatLng(lat, lng)) ? null : lng) ?? mapController.center.longitude,
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    Animation<double> animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.fastOutSlowIn,
    );
    _animationController!.addListener(() {
      mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        enableInput(false);
        _animationController!.dispose();
      }
    });
    enableInput(true);
    _animationController!.forward();
  }

  List<Station>? get _orderedStations {
    try {
      final ordered = MinGOData.orderedStations
          .where(
            (station) =>
                mapController.bounds?.contains(
                  LatLng(
                    double.parse(station.lat!),
                    double.parse(station.lng!),
                  ),
                ) ==
                true,
          )
          .toList();
      MinGOData.orderedStations = ordered;
      DashboardPageOpenStationsController.update(ordered);
      return ordered.sublist(0, ordered.length < 4 ? ordered.length : 4);
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.station == null && !widget.providersSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return IgnorePointer(
      ignoring: widget.station != null,
      child: Stack(
        children: [
          StreamBuilder(
            stream: MapMarkersController.stream,
            initialData: MinGOData.stations,
            builder: (context, stations) {
              return FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  controller: mapController,
                  zoom: widget.station != null ? 16 : 11.5,
                  minZoom: _lockedZoom,
                  maxZoom: _lockedZoom,
                  center: widget.station != null
                      ? LatLng(
                          double.parse(widget.station!.lat!),
                          double.parse(widget.station!.lng!),
                        )
                      : LatLng(
                          LocationServices.locationData?.latitude ?? MinGOData.mapFocusLocation.latitude,
                          LocationServices.locationData?.longitude ?? MinGOData.mapFocusLocation.longitude,
                        ),
                  onPositionChanged: (position, _) {
                    if (widget.station == null &&
                        !widget.providersSearch &&
                        position.center != null &&
                        LocationServices.getDistance(
                              position.center!.latitude,
                              position.center!.longitude,
                              MinGOData.mapFocusLocation.latitude,
                              MinGOData.mapFocusLocation.longitude,
                            ) >
                            (MinGOData.selectedDistance ?? (MediaQuery.of(context).size.width < 1000 ? 5 : 10))) {
                      MinGOData.mapReferencePoint = position.center!;
                    }
                  },
                  plugins: [
                    MarkerClusterPlugin(),
                  ],
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate: 'https://mapa.hyper.hr/tile/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayerOptions(
                    // MarkerClusterLayerOptions(
                    // TODO: Add marker clusters
                    // builder: (context, markers) {
                    //   return DecoratedBox(
                    //     decoration: const BoxDecoration(
                    //       shape: BoxShape.circle,
                    //       color: Colors.white,
                    //       boxShadow: [
                    //         BoxShadow(
                    //           offset: Offset(0, 2),
                    //           blurRadius: 4,
                    //           color: Colors.black12,
                    //         ),
                    //       ],
                    //     ),
                    //     child: SizedBox(
                    //       width: 44,
                    //       height: 44,
                    //       child: Center(
                    //         child: Text(
                    //           markers.length.toString(),
                    //         ),
                    //       ),
                    //     ),
                    //   );
                    // },
                    markers: widget.station != null
                        ? [
                            Marker(
                              point: LatLng(double.parse(widget.station!.lat!), double.parse(widget.station!.lng!)),
                              builder: (context) => _MapMarker(widget.station!),
                            ),
                          ]
                        : [
                            for (var station in widget.providersSearch ? MinGOData.selectedProvidersStations : stations.data!)
                              Marker(
                                point: LatLng(double.parse(station.lat!), double.parse(station.lng!)),
                                builder: (context) => _MapMarker(
                                  station,
                                  onTap: () async {
                                    await move(
                                      lat: double.parse(station.lat!),
                                      lng: double.parse(station.lng!),
                                      zoom: 14,
                                    );
                                    StationPreviewController.display(station);
                                  },
                                ),
                              ),
                            if (!widget.providersSearch && _orderedStations?.isNotEmpty == true)
                              for (int i = 0; i < _orderedStations!.length; i++)
                                Marker(
                                  point: LatLng(
                                    double.parse(_orderedStations!.elementAt(i).lat!),
                                    double.parse(_orderedStations!.elementAt(i).lng!),
                                  ),
                                  builder: (context) => _MapMarker(
                                    MinGOData.orderedStations[i],
                                    index: i,
                                    onTap: () async {
                                      await move(
                                        lat: double.parse(_orderedStations!.elementAt(i).lat!),
                                        lng: double.parse(_orderedStations!.elementAt(i).lng!),
                                        zoom: 14,
                                      );
                                      StationPreviewController.display(
                                        _orderedStations!.elementAt(i),
                                      );
                                    },
                                  ),
                                ),
                            if (LocationServices.locationData != null)
                              Marker(
                                point: LatLng(
                                  LocationServices.locationData!.latitude,
                                  LocationServices.locationData!.longitude,
                                ),
                                anchorPos: AnchorPos.align(AnchorAlign.top),
                                builder: (context) => const Icon(
                                  Icons.location_pin,
                                  color: Color(0xffFF6B57),
                                  size: 48,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(-1.5, -1.5),
                                      color: Colors.white,
                                    ),
                                    Shadow(
                                      offset: Offset(1.5, -1.5),
                                      color: Colors.white,
                                    ),
                                    Shadow(
                                      offset: Offset(1.5, 1.5),
                                      color: Colors.white,
                                    ),
                                    Shadow(
                                      offset: Offset(-1.5, 1.5),
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                  ),
                ],
              );
            },
          ),
          Positioned.fill(
            child: StreamBuilder(
              stream: StationPreviewController.stream,
              builder: (context, station) {
                if (station.data == null) return const SizedBox();
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
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
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              station.data!.place,
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              station.data!.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      WorkHoursIndicator(station.data!),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ProviderInfo(station.data!),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 14),
                                    child: Center(
                                      child: MinGOActionButton(
                                        label: 'Detalji',
                                        icon: Icons.chevron_right,
                                        minWidth: true,
                                        gradientBorder: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            StationPreviewController.display(null);
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) => ProviderDetailsRoute(station.data!),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  onTap: () => StationPreviewController.display(null),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
