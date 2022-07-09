import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/models/price_trend.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/elements/search_field/search_field.dart';
import 'package:mingo/view/shared/widgets/title/title.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class _PriceInfo extends StatefulWidget {
  final int index;

  const _PriceInfo(this.index);

  @override
  State<_PriceInfo> createState() => _PriceInfoState();
}

class _PriceInfoState extends State<_PriceInfo> {
  late double priceInHrk, priceInEur;

  @override
  void initState() {
    super.initState();
    priceInHrk = MinGOData.priceTrends
        .where(
          (e) => e.fuelId == FuelTrendsChartSection.fuelIds.elementAt(widget.index),
        )
        .last
        .price;
    priceInEur = priceInHrk / 7.5345;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Color(
                  int.parse(
                    FuelTrendsChartSection.chartColors.elementAt(widget.index).hexString.replaceAll('#', '0xff'),
                  ),
                ),
              ),
              child: const SizedBox(width: 14, height: 14),
            ),
          ),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: DashboardPageSearchField.fuelKinds[widget.index],
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.grey),
                  ),
                  TextSpan(
                    text: (DateTime.now().year > 2023
                            ? priceInEur.toStringAsFixed(2) +
                                ' EUR / L' +
                                (DateTime.now().year < 2023 || DateTime.now().year == 2023 && DateTime.now().month < 6 ? '  •  ' : '')
                            : '') +
                        (DateTime.now().year < 2023 || DateTime.now().year == 2023 && DateTime.now().month < 6
                            ? '  ' + priceInHrk.toString() + ' HRK / L'
                            : '') +
                        (DateTime.now().year < 2023 ? '  •  ' + priceInEur.toStringAsFixed(2) + ' EUR / L' : ''),
                    style: Theme.of(context).textTheme.bodyText2!,
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalizedDateTimeFactory extends charts.LocalDateTimeFactory {
  final Locale locale;

  _LocalizedDateTimeFactory({required this.locale});

  @override
  DateFormat createDateFormat(String? pattern) {
    return DateFormat(pattern, locale.languageCode);
  }
}

class FuelTrendsChartSection extends StatelessWidget {
  final List<charts.Series<PriceTrendModel, DateTime>>? seriesList;

  const FuelTrendsChartSection({
    super.key,
    this.seriesList,
  });

  static const fuelIds = {1, 2, 3, 4};

  static final List<charts.Color> chartColors = [
    charts.MaterialPalette.blue.shadeDefault,
    charts.MaterialPalette.yellow.shadeDefault,
    charts.MaterialPalette.red.shadeDefault,
    charts.MaterialPalette.green.shadeDefault,
    charts.MaterialPalette.purple.shadeDefault,
    charts.MaterialPalette.pink.shadeDefault.lighter,
    charts.MaterialPalette.deepOrange.shadeDefault,
    charts.MaterialPalette.lime.shadeDefault,
    charts.MaterialPalette.teal.shadeDefault,
    charts.MaterialPalette.cyan.shadeDefault,
    charts.MaterialPalette.indigo.shadeDefault,
  ];

  static final List<charts.Series<PriceTrendModel, DateTime>> _seriesList = [
    for (int i = 0; i < fuelIds.length; i++)
      charts.Series<PriceTrendModel, DateTime>(
        id: 'Trends',
        colorFn: (_, __) => chartColors[i],
        domainFn: (PriceTrendModel gas, _) => gas.lastUpdated,
        measureFn: (PriceTrendModel gas, _) => gas.price,
        data: MinGOData.priceTrends
            .where(
              (e) => e.fuelId == fuelIds.elementAt(i),
            )
            .toList(),
      ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Padding(
        padding:
            MediaQuery.of(context).size.width < 1000 ? const EdgeInsets.symmetric(vertical: 30) : const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MinGOTitle(
              label: MediaQuery.of(context).size.width < 1000 ? 'Grafikon\nprosječnih cijena' : 'Grafikon prosječnih cijena',
              subtitle: 'Usporedite cijene goriva kroz vrijeme',
              iconFilename: 'vectors/dashboard/chart_upwards_trend_illustration.svg',
              brightness: Brightness.dark,
            ),
            Padding(
              padding: MediaQuery.of(context).size.width < 1000
                  ? const EdgeInsets.fromLTRB(16, 20, 16, 0)
                  : EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 8, 40, MediaQuery.of(context).size.width / 8, 0),
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: MediaQuery.of(context).size.width < 1000 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 26),
                      child: LimitedBox(
                        maxHeight: MediaQuery.of(context).size.width < 600
                            ? 300
                            : MediaQuery.of(context).size.height < 800
                                ? 400
                                : MediaQuery.of(context).size.height < 1000
                                    ? 700
                                    : 800,
                        child: IgnorePointer(
                          child: charts.TimeSeriesChart(
                            seriesList ?? _seriesList,
                            dateTimeFactory: _LocalizedDateTimeFactory(
                              locale: Localizations.localeOf(context),
                            ),
                            animate: false,
                          ),
                        ),
                      ),
                    ),
                    for (int i = 0; i < 4; i++) _PriceInfo(i),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
