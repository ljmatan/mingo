import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mingo/services/storage/cache.dart';
import 'package:mingo/view/dialogs/login/login_dialog.dart';
import 'package:mingo/view/dialogs/register/register_dialog.dart';
import 'package:mingo/view/routes/main_route/bloc/page_controller.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/dashboard_page.dart';
import 'package:mingo/view/theme.dart';

class MinGONavigationBar extends StatefulWidget {
  const MinGONavigationBar({super.key});

  static Set<String> get pageLabels => {
        'Naslovnica',
        'Obveznici',
        'Upute',
        'O projektu',
        'Pravila privatnosti',
        if (CacheManager.instance.getString('token') != null) 'Prijava greške',
      };

  @override
  State<MinGONavigationBar> createState() => _MinGONavigationBarState();
}

class _MinGONavigationBarState extends State<MinGONavigationBar> {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: MediaQuery.of(context).size.width < 1000
          ? InkWell(
              child: Padding(
                padding: EdgeInsets.only(left: 16, top: MediaQuery.of(context).padding.top),
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/vectors/logo.svg',
                        height: 24,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (CacheManager.instance.getString('token') == null)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: InkWell(
                                child: SvgPicture.asset(
                                  'assets/vectors/nav_bar/person.svg',
                                  height: 30,
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    useSafeArea: false,
                                    barrierColor: Colors.transparent,
                                    builder: (context) => LoginDialog(
                                      rebuildNavigationBar: () => setState(() {}),
                                    ),
                                  );
                                },
                              ),
                            ),
                          IconButton(
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              Scaffold.of(context).openEndDrawer();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {
                FocusScope.of(context).unfocus();
                DashboardPage.searchFieldKey?.currentState?.resetView();
                Navigator.of(context).popUntil((route) => route.isFirst);
                MainRoutePageController.navigateTo(0);
              },
            )
          : Stack(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        child: SvgPicture.asset(
                          'assets/vectors/logo.svg',
                          height: 36,
                        ),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          DashboardPage.searchFieldKey?.currentState?.resetView();
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          MainRoutePageController.navigateTo(0);
                        },
                      ),
                      if (CacheManager.instance.getString('token') == null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int i = 0; i < 2; i++)
                              Padding(
                                padding: i == 0 ? EdgeInsets.zero : const EdgeInsets.only(left: 14),
                                child: InkWell(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      gradient: i == 0 ? null : MinGOTheme.buttonGradient,
                                      border: i == 0 ? Border.all(color: Colors.white) : null,
                                    ),
                                    child: SizedBox(
                                      height: 44,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 30),
                                        child: Center(
                                          child: Text(
                                            i == 0 ? 'Prijava' : 'Registracija',
                                            style: Theme.of(context).textTheme.bodyText1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: i == 0
                                      ? () {
                                          FocusScope.of(context).unfocus();
                                          showDialog(
                                            context: context,
                                            useSafeArea: false,
                                            barrierColor: Colors.transparent,
                                            builder: (context) => LoginDialog(
                                              rebuildNavigationBar: () => setState(() {}),
                                            ),
                                          );
                                        }
                                      : () {
                                          FocusScope.of(context).unfocus();
                                          showDialog(
                                            context: context,
                                            useSafeArea: false,
                                            barrierColor: Colors.transparent,
                                            builder: (context) => const RegisterDialog(),
                                          );
                                        },
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < MinGONavigationBar.pageLabels.length; i++)
                          StreamBuilder<int>(
                            stream: MainRoutePageController.stream,
                            initialData: MainRoutePageController.currentPage,
                            builder: (context, page) {
                              return InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    MinGONavigationBar.pageLabels.elementAt(i),
                                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                                          decoration: page.data == i ? TextDecoration.underline : null,
                                        ),
                                  ),
                                ),
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  MainRoutePageController.navigateTo(i);
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
