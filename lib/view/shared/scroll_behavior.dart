import 'package:flutter/material.dart';

class OverscrollRemovedScrolLBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
