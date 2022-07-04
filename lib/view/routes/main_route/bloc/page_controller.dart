import 'dart:async';

abstract class MainRoutePageController {
  static final _instance = StreamController<int>.broadcast();

  static Stream<int> get stream => _instance.stream;

  static int currentPage = 0;

  static void navigateTo(int page) {
    if (page != currentPage) {
      _instance.add(page);
      currentPage = page;
    }
  }
}
