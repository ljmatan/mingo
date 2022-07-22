import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mingo/api/client.dart';
import 'package:mingo/api/data.dart';
import 'package:mingo/api/price_trends.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/services/app_tracking_transparency/att.dart';
import 'package:mingo/services/device_info/device_info.dart';
import 'package:mingo/services/navigator/navigator.dart';
import 'package:mingo/services/storage/cache.dart';
import 'package:mingo/view/routes/main_route/main_route.dart';
import 'package:mingo/view/shared/navigator_builder.dart';
import 'package:mingo/view/theme.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'utils/web/configure_nonweb.dart' if (dart.library.html) 'utils/web/configure_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    DartPluginRegistrant.ensureInitialized();
    if (kDebugMode) {
      MinGOHttpClient.networkInspector?.setNavigatorKey(AppNavigator.key);
    }
  } else {
    configureApp();
  }

  await CacheManager.init();

  if (!kIsWeb) {
    HttpOverrides.global = InvalidSslOverride();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  try {
    await DeviceInfo.init();
  } catch (e) {
    debugPrint('$e');
  }

  await Att.init();

  runApp(const MinGO());
}

class MinGO extends StatelessWidget {
  const MinGO({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'minGO',
      navigatorKey: AppNavigator.key,
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('hr', 'HR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: MinGOTheme.data,
      builder: (context, child) => NavigatorBuilder(child!),
      home: const MinGOSplash(),
    );
  }
}

class MinGOSplash extends StatefulWidget {
  const MinGOSplash({super.key});

  @override
  State<MinGOSplash> createState() => _MinGOSplashState();
}

class _MinGOSplashState extends State<MinGOSplash> {
  static Future _getAppData() async {
    return await Future.wait([
      AppDataApi.getAll().then((value) async {
        MinGOData.priceTrends = await PriceTrendsApi.getAll();
        debugPrint('Price trends received');
        await MinGOData.getFuelTypesByStation();
        debugPrint('App data set');
        MinGOData.stations = await MinGOData.getStationsInRadius();
        MinGOData.updateFilteredMarkers();
        MinGOData.openStations = MinGOData.getOpenStations;
        debugPrint('Stations filtered');
      }),
      // PriceTrendsApi.getLatestPricingUpdates(),
    ]);
  }

  Key _futureKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xff242C35),
      ),
      child: FutureBuilder(
        key: _futureKey,
        future: _getAppData(),
        builder: (context, appData) {
          if (appData.connectionState != ConnectionState.done || appData.hasError) {
            if (kDebugMode && appData.hasError) throw appData.error!;
            return Center(
              child: appData.hasError
                  ? Material(
                      color: Colors.transparent,
                      child: SizedBox.expand(
                        child: Stack(
                          children: [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 10),
                                child: Text(
                                  appData.error.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 30,
                              child: Center(
                                child: TextButton(
                                  child: const Text(
                                    'Pokušaj ponovno',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 18,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  onPressed: () => setState(() => _futureKey = UniqueKey()),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const CircularProgressIndicator(
                      color: Colors.white,
                    ),
            );
          }
          return const MainRoute();
        },
      ),
    );
  }
}
