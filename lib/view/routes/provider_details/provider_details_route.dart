import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mingo/api/price_trends.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/models/app_data.dart';
import 'package:mingo/view/routes/provider_details/elements/header/header.dart';
import 'package:mingo/view/routes/provider_details/elements/price_section/price_section.dart';
import 'package:mingo/view/shared/widgets/chart/chart_section.dart';
import 'package:mingo/view/shared/widgets/footer/footer.dart';
import 'package:mingo/view/shared/widgets/map/leaflet_map.dart';
import 'package:mingo/view/shared/widgets/newsletter_subscription/newsletter_subscription_field.dart';
import 'package:mingo/view/shared/widgets/title/title.dart';

class ProviderDetailsRoute extends StatefulWidget {
  final Station station;

  const ProviderDetailsRoute(
    this.station, {
    super.key,
  });

  @override
  State<ProviderDetailsRoute> createState() => _ProviderDetailsRouteState();
}

class _ProviderDetailsRouteState extends State<ProviderDetailsRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          InkWell(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: SizedBox(
                  height: MediaQuery.of(context).size.width < 1000 ? kToolbarHeight : null,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Padding(
                        padding: MediaQuery.of(context).size.width < 1000 ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 16),
                        child: SvgPicture.asset(
                          'assets/vectors/logo.svg',
                          height: MediaQuery.of(context).size.width < 1000 ? 24 : 36,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: MediaQuery.of(context).size.width < 1000
                  ? [
                      ProviderDetailsPageHeader(widget.station),
                      ProvidersPagePriceSection(widget.station),
                      if (widget.station.options.isNotEmpty)
                        DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.white),
                          child: SizedBox(
                            height: 400,
                            child: Stack(
                              children: [
                                Center(
                                  child: SvgPicture.asset(
                                    'assets/vectors/provider_page/location_pin_bg.svg',
                                    height: 300,
                                  ),
                                ),
                                Center(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .8),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(bottom: 24),
                                          child: MinGOTitle(
                                            label: 'Opcije postaje',
                                            subtitle: '',
                                            iconFilename: 'vectors/provider_page/location_pin.svg',
                                          ),
                                        ),
                                        Text(
                                          widget.station.options
                                              .map((e) => MinGOData.instance.options.singleWhere((o) => o.id == e.optionId).name)
                                              .join('\n'),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            height: 1.7,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                        child: LeafletMap(
                          station: widget.station,
                        ),
                      ),
                      const FuelTrendsChartSection(),
                      const NewsletterSubscriptionField(),
                      const Footer(),
                    ]
                  : [
                      ProviderDetailsPageHeader(widget.station),
                      ProvidersPagePriceSection(widget.station),
                      DecoratedBox(
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Row(
                          children: [
                            if (widget.station.options.isNotEmpty)
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .45,
                                height: 600,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: MediaQuery.of(context).size.width * .025,
                                      top: 0,
                                      bottom: 0,
                                      child: SvgPicture.asset(
                                        'assets/vectors/provider_page/location_pin_bg.svg',
                                        height: 470,
                                      ),
                                    ),
                                    Center(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .38),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(bottom: 24),
                                              child: MinGOTitle(
                                                label: 'Opcije postaje',
                                                subtitle: '',
                                                iconFilename: 'vectors/provider_page/location_pin.svg',
                                              ),
                                            ),
                                            Text(
                                              widget.station.options
                                                  .map((e) => MinGOData.instance.options.singleWhere((o) => o.id == e.optionId).name)
                                                  .join('\n'),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                height: 1.7,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 600,
                                child: LeafletMap(
                                  station: widget.station,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder(
                        future: PriceTrendsApi.getStationTrends(''),
                        builder: (context, stationPrices) {
                          if (stationPrices.data == null) return const FuelTrendsChartSection();
                          return const FuelTrendsChartSection();
                        },
                      ),
                      const NewsletterSubscriptionField(),
                      const Footer(),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
