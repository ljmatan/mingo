import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class UrlLauncher {
  static Future<void> email(String email) async {
    try {
      final mailtoUrl = (email.startsWith('mailto') ? '' : 'mailto:') + email;
      if (!await launchUrl(
        Uri(
          scheme: 'mailto',
          path: email.replaceAll('mailto:', ''),
        ),
      )) throw 'Couldn\'t launch an email app: $mailtoUrl';
    } catch (e) {
      debugPrint('$e');
    }
  }

  static Future<void> call(String number) async {
    try {
      if (!await launchUrl(Uri.parse('tel:${number.trim()}'))) throw 'Couldn\'t make a call';
    } catch (e) {
      debugPrint('$e');
    }
  }

  static Future<void> url(String url) async {
    try {
      if (!await launchUrl(
        Uri.parse(url),
        mode: kIsWeb || url.contains('maps') ? LaunchMode.platformDefault : LaunchMode.externalApplication,
      )) {
        throw 'Couldn\'t launch the URL';
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  static Future<void> appStore([String? requestedUrl]) async {
    assert(!kIsWeb || requestedUrl != null);
    late String url;
    if (kIsWeb) {
      url = requestedUrl!;
    } else {
      url = Platform.isAndroid
          ? 'https://play.google.com/store/apps/details?id=mzoe.gor'
          : 'https://apps.apple.com/ca/app/tražilica-najjeftinijeg-goriva/id1556896069';
    }
    try {
      if (!await launchUrl(Uri.parse(url))) throw 'Couldn\'t open an app store';
    } catch (e) {
      debugPrint('$e');
    }
  }

  static Future<void> maps(
    String lat,
    String lng,
  ) async {
    await url(
      kIsWeb || Platform.isAndroid ? 'https://www.google.com/maps/search/?api=1&query=$lat,$lng' : 'https://maps.apple.com/?q=$lat,$lng',
    );
  }
}
