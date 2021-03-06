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
            MediaQuery.of(context).size.width < 1000 ? 44 : 30,
            MediaQuery.of(context).size.width < 1000 ? 44 : 30,
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
  final ScrollController? scrollController;

  const LeafletMap({
    super.key,
    this.station,
    this.providersSearch = false,
    this.scrollController,
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
    bool markerTap = false,
  }) async {
    assert(lat == null && lng == null || lat != null && lng != null);
    if (kIsWeb) {
      if (lat != null && lng != null) {
        mapController.move(LatLng(lat, lng), mapController.zoom);
        enableInput(false);
        return;
      }
      if (zoom == null && lat == mapController.center.latitude && lng == mapController.center.longitude) return;
      double zoomValue = absoluteZoomValue ? (zoom ?? mapController.zoom) : mapController.zoom + (zoom ?? 0);
      if (zoomValue < 9 || zoomValue > 20) zoomValue = mapController.zoom;
      mapController.move(
        LatLng(
          mapController.center.latitude,
          mapController.center.longitude,
        ),
        zoomValue,
      );
      enableInput(false);
    } else {
      if (!animated && lat != null && lng != null) {
        mapController.move(LatLng(lat, lng), mapController.zoom);
        return;
      }
      if (zoom == null && lat == mapController.center.latitude && lng == mapController.center.longitude) return;
      double zoomValue = absoluteZoomValue ? (zoom ?? mapController.zoom) : mapController.zoom + (zoom ?? 0);
      if (zoomValue < 9 || zoomValue > 20) zoomValue = mapController.zoom;
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
          if (markerTap) {
            MapMarkersController.update(MinGOData.stations);
            MinGOData.mapReferencePoint = mapController.center;
          }
        }
      });
      enableInput(true);
      _animationController!.forward();
    }
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
      return ordered.sublist(0, ordered.length < 4 ? ordered.length : 4).toList();
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  final _widgetKey = GlobalKey();

  Future<void> _onMarkerTap(Station station) async {
    if (widget.scrollController != null && widget.scrollController!.offset > 200) {
      await widget.scrollController
          ?.animateTo(
            0,
            duration: Duration(milliseconds: widget.scrollController!.offset.toInt()),
            curve: Curves.linearToEaseOut,
          )
          .whenComplete(() async => await Future.delayed(const Duration(milliseconds: 1)));
    }
    final renderBox = _widgetKey.currentContext!.findRenderObject() as RenderBox;
    final widgetOffset = renderBox.localToGlobal(Offset.zero);
    final topPadding = MediaQuery.of(context).padding.top;
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Listener(
          child: Material(
            color: Colors.transparent,
            child: Transform.translate(
              offset: Offset(
                MediaQuery.of(context).size.width < 1000 ? widgetOffset.dx : MediaQuery.of(context).size.width * (2 / 5),
                widgetOffset.dy - topPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: renderBox.size.width,
                    height: renderBox.size.height,
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
                                                station.place,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Text(
                                                station.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        WorkHoursIndicator(station),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ProviderInfo(
                                      station,
                                      popup: true,
                                    ),
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
                              Navigator.popUntil(context, (route) => route.isFirst);
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) => ProviderDetailsRoute(station),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          onPointerDown: (_) => Navigator.popUntil(context, (route) => route.isFirst),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return IgnorePointer(
      ignoring: widget.station != null,
      child: Listener(
        child: StreamBuilder<List<Station>>(
          stream: MapMarkersController.stream,
          initialData: MinGOData.stations,
          builder: (context, stations) {
            final orderedStations = _orderedStations;
            return FlutterMap(
              key: _widgetKey,
              mapController: mapController,
              options: MapOptions(
                controller: mapController,
                zoom: widget.station != null ? 16 : 11.5,
                minZoom: _lockedZoom ?? (widget.providersSearch ? null : 9),
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
                interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                onPositionChanged: (position, _) {
                  final distanceFromLastRecorded = LocationServices.getDistance(
                    position.center!.latitude,
                    position.center!.longitude,
                    MinGOData.mapFocusLocation.latitude,
                    MinGOData.mapFocusLocation.longitude,
                  );
                  if (widget.station == null &&
                      !widget.providersSearch &&
                      position.center != null &&
                      distanceFromLastRecorded > (MinGOData.selectedDistance ?? (MediaQuery.of(context).size.width < 1000 ? 5 : 10))) {
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
                  markers: widget.station != null
                      ? [
                          Marker(
                            point: LatLng(double.parse(widget.station!.lat!), double.parse(widget.station!.lng!)),
                            builder: (context) => _MapMarker(widget.station!),
                            rotate: true,
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
                                    markerTap: true,
                                  );
                                  _onMarkerTap(station);
                                },
                              ),
                              rotate: true,
                            ),
                          ...[
                            if (!widget.providersSearch && orderedStations?.isNotEmpty == true)
                              for (int i = 0; i < orderedStations!.length; i++)
                                Marker(
                                  point: LatLng(
                                    double.parse(orderedStations.elementAt(i).lat!),
                                    double.parse(orderedStations.elementAt(i).lng!),
                                  ),
                                  builder: (context) => _MapMarker(
                                    orderedStations.elementAt(i),
                                    index: i,
                                    onTap: () async {
                                      await move(
                                        lat: double.parse(orderedStations.elementAt(i).lat!),
                                        lng: double.parse(orderedStations.elementAt(i).lng!),
                                        zoom: 14,
                                        markerTap: true,
                                      );
                                      _onMarkerTap(_orderedStations!.elementAt(i));
                                    },
                                  ),
                                  rotate: true,
                                ),
                          ].reversed,
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
                              rotate: true,
                            ),
                        ],
                ),
              ],
            );
          },
        ),
        onPointerUp: (_) {
          MapMarkersController.update(MinGOData.stations);
          MinGOData.mapReferencePoint = mapController.center;
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
