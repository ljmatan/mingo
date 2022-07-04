import 'dart:async';

import 'package:mingo/models/app_data.dart';

abstract class DashboardPageOpenStationsController {
  static final _controller = StreamController<List<Station>>.broadcast();

  static Stream<List<Station>> get stream => _controller.stream;

  static void update(List<Station> openStations) => _controller.add(openStations);
}
