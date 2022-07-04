import 'dart:async';

import 'package:mingo/models/app_data.dart';

abstract class StationPreviewController {
  static final _controller = StreamController<Station?>.broadcast();

  static Stream<Station?> get stream => _controller.stream;

  static void display(Station? station) => _controller.add(station);
}
