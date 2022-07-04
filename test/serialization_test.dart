// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show WidgetsFlutterBinding;
import 'package:mingo/api/client.dart';
import 'package:mingo/models/app_data.dart';
import 'package:mingo/services/storage/cache.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  test('Serialization test', () async {
    WidgetsFlutterBinding.ensureInitialized();

    SharedPreferences.setMockInitialValues({});

    await CacheManager.init();

    final response = await MinGOHttpClient.get(
      'https://mzoe-gor.hr/data.gz',
      decoded: false,
    );

    final extracted = GZipCodec().decode(response.bodyBytes);
    debugPrint('Data response extracted: ${extracted.length}');
    final utf8Decoded = utf8.decode(extracted, allowMalformed: true);
    debugPrint('Data response utf8 decoded');
    final jsonDecoded = jsonDecode(utf8Decoded);
    debugPrint('Data response JSON decoded');
    final data = AppDataModel.fromJson(jsonDecoded);
    debugPrint('Data response serialized');
  });
}
