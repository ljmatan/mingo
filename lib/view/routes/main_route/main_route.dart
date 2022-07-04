import 'package:flutter/material.dart';
import 'package:mingo/view/dialogs/error_report/error_report_dialog.dart';
import 'package:mingo/view/routes/main_route/bloc/page_controller.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/dashboard_page.dart';
import 'package:mingo/view/routes/main_route/pages/about/about_page.dart';
import 'package:mingo/view/routes/main_route/pages/privacy_policy/privacy_policy_page.dart';
import 'package:mingo/view/routes/main_route/pages/providers_search/providers_search_page.dart';

import 'elements/navigation_bar/navigation_bar.dart';
import 'pages/guide/guide_page.dart';

class MainRoute extends StatelessWidget {
  const MainRoute({super.key});

  Widget get _currentView {
    switch (MainRoutePageController.currentPage) {
      case 0:
        return const DashboardPage();
      case 1:
        return const ProvidersSearchPage();
      case 2:
        return const GuidePage();
      case 3:
        return const AboutPage();
      case 4:
        return const PrivacyPolicyPage();
      default:
        throw 'Not implemented';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MinGONavigationBar(),
          Expanded(
            child: StreamBuilder(
              stream: MainRoutePageController.stream,
              builder: (context, _) {
                return _currentView;
              },
            ),
          ),
        ],
      ),
      endDrawer: MediaQuery.of(context).size.width < 1000
          ? Drawer(
              backgroundColor: Theme.of(context).primaryColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < MinGONavigationBar.pageLabels.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: TextButton(
                        child: Builder(
                          builder: (context) {
                            return StreamBuilder(
                              stream: MainRoutePageController.stream,
                              initialData: MainRoutePageController.currentPage,
                              builder: (context, page) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Text(
                                    MinGONavigationBar.pageLabels.elementAt(i),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 18,
                                      decoration: page.data == i ? TextDecoration.underline : null,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        onPressed: () {
                          if (i == 5) {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              useSafeArea: false,
                              barrierColor: Colors.transparent,
                              builder: (context) => const ErrorReportDialog(),
                            );
                          } else {
                            Navigator.pop(context);
                            MainRoutePageController.navigateTo(i);
                          }
                        },
                      ),
                    ),
                ],
              ),
            )
          : null,
    );
  }
}
