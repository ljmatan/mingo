import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

abstract class DeviceInfo {
  static DeviceInfoPlugin instance = DeviceInfoPlugin();

  static int? androidApiVersion;

  static Future<void> init() async {
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        final androidDeviceInfo = await instance.androidInfo;
        androidApiVersion = androidDeviceInfo.version.sdkInt;
      }
    }
  }
}
