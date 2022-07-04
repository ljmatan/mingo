import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/models/price_trend.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/elements/search_field/search_field.dart';
import 'package:mingo/view/shared/widgets/title/title.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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

  static const _fuelIds = {1, 2, 3, 4};

  static final List<charts.Color> _colors = [
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
    for (int i = 0; i < _fuelIds.length; i++)
      charts.Series<PriceTrendModel, DateTime>(
        id: 'Trends',
        colorFn: (_, __) => _colors[i],
        domainFn: (PriceTrendModel gas, _) => gas.lastUpdated,
        measureFn: (PriceTrendModel gas, _) => gas.price,
        data: MinGOData.priceTrends
            .where(
              (e) => e.fuelId == _fuelIds.elementAt(i),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    if (MediaQuery.of(context).size.width < 1000)
                      for (int i = 0; i < 4; i++)
                        Padding(
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
                                        _colors.elementAt(i).hexString.replaceAll('#', '0xff'),
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
                                        text: DashboardPageSearchField.fuelKinds[i],
                                        style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.grey),
                                      ),
                                      TextSpan(
                                        text: '  ' +
                                            MinGOData.priceTrends
                                                .where(
                                                  (e) => e.fuelId == _fuelIds.elementAt(i),
                                                )
                                                .last
                                                .price
                                                .toString() +
                                            ' HRK / L',
                                        style: Theme.of(context).textTheme.bodyText2!,
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < 4; i++)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: Color(
                                              int.parse(
                                                _colors.elementAt(i).hexString.replaceAll('#', '0xff'),
                                              ),
                                            ),
                                          ),
                                          child: const SizedBox(width: 14, height: 14),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          DashboardPageSearchField.fuelKinds[i],
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      MinGOData.priceTrends
                                              .where(
                                                (e) => e.fuelId == _fuelIds.elementAt(i),
                                              )
                                              .last
                                              .price
                                              .toString() +
                                          ' HRK / L',
                                      style: const TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
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
