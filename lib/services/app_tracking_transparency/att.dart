import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';

abstract class Att {
  static late TrackingStatus _status;

  static bool get accepted => kIsWeb || !Platform.isIOS || _status == TrackingStatus.authorized;

  static Future<void> init() async {
    try {
      _status = !kIsWeb && Platform.isIOS ? await AppTrackingTransparency.requestTrackingAuthorization() : TrackingStatus.authorized;
    } catch (e) {
      debugPrint('$e');
    }
  }
}
