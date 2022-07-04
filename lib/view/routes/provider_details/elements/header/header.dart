import 'package:flutter/material.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/models/app_data.dart';
import 'package:mingo/services/url_launcher/launcher.dart';
import 'package:mingo/view/shared/basic/action_button.dart';
import 'package:mingo/view/shared/widgets/provider_info/provider_info.dart';
import 'package:mingo/view/shared/widgets/work_hours_indicator/work_hours_indicator.dart';
import 'package:share_plus/share_plus.dart';

class ProviderDetailsPageHeader extends StatefulWidget {
  final Station station;

  const ProviderDetailsPageHeader(this.station, {super.key});

  @override
  State<ProviderDetailsPageHeader> createState() => _ProviderDetailsPageHeaderState();
}

class _ProviderDetailsPageHeaderState extends State<ProviderDetailsPageHeader> {
  String? _brandLogoUrl;

  @override
  void initState() {
    super.initState();
    try {
      _brandLogoUrl = MinGOData.instance.providers.firstWhere((e) => e.id == widget.station.providerId).logo;
    } catch (e) {
      // Do nothing
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width < 1000
        ? DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xff435467),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
                  child: Column(
                    children: [
                      Text(
                        widget.station.place,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          fontSize: 40,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          widget.station.address,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 40,
                          ),
                        ),
                      ),
                      WorkHoursIndicator(widget.station),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .67),
                          child: ProviderInfo(widget.station),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < 2; i++)
                            Padding(
                              padding: i == 0 ? const EdgeInsets.only(right: 5) : const EdgeInsets.only(left: 5),
                              child: MinGOActionButton(
                                label: i == 0 ? 'Odvedi me' : 'Podijeli',
                                icon: Icons.chevron_right,
                                minWidth: true,
                                gradientBorder: i == 1,
                                contentBlocking: false,
                                onTap: () async {
                                  i == 0
                                      ? await UrlLauncher.maps(widget.station.lat!, widget.station.lng!)
                                      : await Share.share('Provjerite trenutne cijene goriva putem min-go.hr stranice.');
                                },
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_brandLogoUrl != null)
                  DecoratedBox(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 4,
                        vertical: 16,
                      ),
                      child: Center(
                        child: Image.network(
                          'https://webservis.mzoe-gor.hr/img/' + _brandLogoUrl!,
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          )
        : DecoratedBox(
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Color(0xff435467),
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 460,
                      child: Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < 2; i++)
                              Expanded(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: i == 0
                                              ? [
                                                  Text(
                                                    widget.station.name,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w300,
                                                      color: Colors.white,
                                                      fontSize: 40,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 14),
                                                    child: Text(
                                                      widget.station.address,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.white,
                                                        fontSize: 40,
                                                      ),
                                                    ),
                                                  ),
                                                  WorkHoursIndicator(widget.station),
                                                ]
                                              : [
                                                  ProviderInfo(widget.station),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      for (int i = 0; i < 2; i++)
                                                        Padding(
                                                          padding: i == 0
                                                              ? const EdgeInsets.only(top: 6, right: 7)
                                                              : const EdgeInsets.only(top: 6, left: 7),
                                                          child: MinGOActionButton(
                                                            label: i == 0 ? 'Odvedi me' : 'Podijeli',
                                                            icon: Icons.chevron_right,
                                                            gradientBorder: i == 1,
                                                            contentBlocking: false,
                                                            onTap: () async {
                                                              i == 0
                                                                  ? await UrlLauncher.maps(widget.station.lat!, widget.station.lng!)
                                                                  : await Share.share(
                                                                      'Provjerite trenutne cijene goriva putem min-go.hr stranice.',
                                                                    );
                                                            },
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_brandLogoUrl != null)
                  SizedBox(
                    width: MediaQuery.of(context).size.width * (2 / 5),
                    height: 460,
                    child: Center(
                      child: Image.network(
                        'https://webservis.mzoe-gor.hr/img/' + _brandLogoUrl!,
                        width: MediaQuery.of(context).size.width * .8,
                        height: 200,
                      ),
                    ),
                  ),
              ],
            ),
          );
  }
}
