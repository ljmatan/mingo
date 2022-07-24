import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mingo/services/location/location.dart';
import 'package:mingo/view/shared/widgets/map/leaflet_map.dart';

class DashboardPageMap extends StatefulWidget {
  final GlobalKey<LeafletMapState> mapKey;
  final Function(bool) enableScroll;
  final ScrollController scrollController;

  const DashboardPageMap({
    super.key,
    required this.mapKey,
    required this.enableScroll,
    required this.scrollController,
  });

  @override
  State<DashboardPageMap> createState() => _DashboardPageMapState();
}

class _DashboardPageMapState extends State<DashboardPageMap> {
  late GlobalKey<LeafletMapState> _mapKey;

  @override
  void initState() {
    super.initState();
    _mapKey = widget.mapKey;
  }

  bool _gpsLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * (3 / 5),
      height: MediaQuery.of(context).size.width < 1000
          ? MediaQuery.of(context).size.height / 2
          : MediaQuery.of(context).size.height > 1200
              ? 1000
              : 800,
      child: Stack(
        children: [
          Listener(
            child: kIsWeb
                ? MouseRegion(
                    child: LeafletMap(
                      key: _mapKey,
                      scrollController: widget.scrollController,
                    ),
                    onEnter: (_) => _mapKey.currentState!.enableInput(false),
                    onExit: (_) => _mapKey.currentState!.enableInput(true),
                    cursor: MouseCursor.uncontrolled,
                  )
                : LeafletMap(
                    key: _mapKey,
                    scrollController: widget.scrollController,
                  ),
            onPointerDown: (_) => widget.enableScroll(false),
            onPointerUp: (_) => widget.enableScroll(true),
          ),
          Positioned(
            right: 14,
            bottom: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < 3; i++)
                  MediaQuery.of(context).size.width < 1000 && !kIsWeb && i != 2
                      ? const SizedBox()
                      : Padding(
                          padding: i == 1 ? const EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
                          child: StatefulBuilder(
                            builder: (context, setState) {
                              return InkWell(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: i == 2 && _gpsLoading ? Theme.of(context).primaryColor : Colors.white,
                                    border: i == 0
                                        ? const Border(
                                            bottom: BorderSide(
                                              color: Color(0xffCCCCCC),
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width > 1000 ? 36 : 44,
                                    height: MediaQuery.of(context).size.width > 1000 ? 36 : 44,
                                    child: Center(
                                      child: Icon(
                                        i == 0
                                            ? Icons.add
                                            : i == 1
                                                ? Icons.remove
                                                : Icons.gps_fixed,
                                        color: i == 2 && _gpsLoading ? Colors.white : null,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  switch (i) {
                                    case 0:
                                    case 1:
                                      final newZoomValue = _mapKey.currentState!.mapController.zoom + (i == 0 ? .5 : -.5);
                                      if (newZoomValue > 9) {
                                        _mapKey.currentState!.mapController.move(
                                          _mapKey.currentState!.mapController.center,
                                          newZoomValue,
                                        );
                                      }
                                      break;
                                    case 2:
                                      if (!_gpsLoading) {
                                        try {
                                          setState(() => _gpsLoading = true);
                                          final position = await LocationServices.getCurrentLocation();
                                          _mapKey.currentState!.move(
                                            lat: position.latitude,
                                            lng: position.longitude,
                                          );
                                          setState(() => _gpsLoading = false);
                                        } catch (e) {
                                          setState(() => _gpsLoading = false);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('$e'),
                                            ),
                                          );
                                        }
                                      }
                                      break;
                                    default:
                                      throw 'Not implemented';
                                  }
                                },
                              );
                            },
                          ),
                        ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
