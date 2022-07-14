import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mingo/services/url_launcher/launcher.dart';
import 'package:mingo/view/dialogs/contact/contact_dialog.dart';
import 'package:mingo/view/shared/basic/action_button.dart';
import 'package:mingo/view/theme.dart';

class Footer extends StatelessWidget {
  const Footer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        child: MediaQuery.of(context).size.width < 1000
            ? Column(
                children: [
                  SvgPicture.asset(
                    'assets/vectors/logo.svg',
                    height: 24,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Copyright © MZOE 2022',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  kIsWeb
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                child: SvgPicture.asset(
                                  'assets/vectors/footer/play_store.svg',
                                  height: 44,
                                ),
                                onTap: () async {
                                  await UrlLauncher.appStore('https://play.google.com/store/apps/details?id=mzoe.gor');
                                },
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                child: SvgPicture.asset(
                                  'assets/vectors/footer/app_store.svg',
                                  height: 44,
                                ),
                                onTap: () async {
                                  await UrlLauncher.appStore('https://apps.apple.com/ca/app/tražilica-najjeftinijeg-goriva/id1556896069');
                                },
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: SvgPicture.asset(
                        'assets/vectors/footer/ev_banner.svg',
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                  ),
                  MinGOActionButton(
                    label: 'Kontaktirajte nas',
                    icon: Icons.chevron_right,
                    minWidth: true,
                    onTap: () => showDialog(
                      context: context,
                      useSafeArea: false,
                      barrierColor: Colors.transparent,
                      builder: (context) => const ContactDialog(),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/vectors/logo.svg',
                            height: 24,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Text(
                              'Copyright © MZOE 2022',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (kIsWeb)
                        Padding(
                          padding: const EdgeInsets.only(left: 22, right: 14),
                          child: InkWell(
                            child: SvgPicture.asset(
                              'assets/vectors/footer/play_store.svg',
                              height: 44,
                            ),
                            onTap: () async {
                              await UrlLauncher.appStore('https://play.google.com/store/apps/details?id=mingo.hr');
                            },
                          ),
                        ),
                      if (kIsWeb)
                        InkWell(
                          child: SvgPicture.asset(
                            'assets/vectors/footer/app_store.svg',
                            height: 44,
                          ),
                          onTap: () async {
                            await UrlLauncher.appStore('https://apps.apple.com/ca/app/tražilica-najjeftinijeg-goriva/id1556896069');
                          },
                        ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: SvgPicture.asset(
                          'assets/vectors/footer/ev_banner.svg',
                          height: 60,
                        ),
                      ),
                      InkWell(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: MinGOTheme.buttonGradient,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              height: 48,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'Kontaktirajte nas    ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        onTap: () => showDialog(
                          context: context,
                          useSafeArea: false,
                          barrierColor: Colors.transparent,
                          builder: (context) => const ContactDialog(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
