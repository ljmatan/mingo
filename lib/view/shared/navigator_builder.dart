import 'dart:io';

import 'package:device_preview/device_preview.dart' as devicePreview;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mingo/services/device_info/device_info.dart';
import 'package:mingo/view/shared/scroll_behavior.dart';

class NavigatorBuilder extends StatefulWidget {
  final Widget child;

  const NavigatorBuilder(this.child, {super.key});

  @override
  State<NavigatorBuilder> createState() => _NavigatorBuilderState();
}

class _NavigatorBuilderState extends State<NavigatorBuilder> {
  @override
  Widget build(BuildContext context) {
    return kProfileMode
        ? devicePreview.DevicePreview.appBuilder(
            context,
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: MediaQuery.of(context).size.width > 800
                    ? 1
                    : MediaQuery.of(context).size.width > 400
                        ? kIsWeb
                            ? .9
                            : .8
                        : MediaQuery.of(context).size.width < 300
                            ? .6
                            : .8,
              ),
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: Theme.of(context).appBarTheme.systemOverlayStyle!,
                child: !kIsWeb && Platform.isAndroid && (DeviceInfo.androidApiVersion == null || DeviceInfo.androidApiVersion! < 31)
                    ? ScrollConfiguration(
                        behavior: OverscrollRemovedScrolLBehavior(),
                        child: widget.child,
                      )
                    : widget.child,
              ),
            ),
          )
        : MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: MediaQuery.of(context).size.width > 800
                  ? 1
                  : MediaQuery.of(context).size.width > 400
                      ? kIsWeb
                          ? .9
                          : .8
                      : MediaQuery.of(context).size.width < 300
                          ? .6
                          : .8,
            ),
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: Theme.of(context).appBarTheme.systemOverlayStyle!,
              child: !kIsWeb && Platform.isAndroid && (DeviceInfo.androidApiVersion == null || DeviceInfo.androidApiVersion! < 31)
                  ? ScrollConfiguration(
                      behavior: OverscrollRemovedScrolLBehavior(),
                      child: widget.child,
                    )
                  : widget.child,
            ),
          );
  }
}
