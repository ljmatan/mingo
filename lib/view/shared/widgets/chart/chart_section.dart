import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/models/price_trend.dart';
import 'package:mingo/services/app_tracking_transparency/att.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/elements/search_field/search_field.dart';
import 'package:mingo/view/shared/widgets/title/title.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class _PriceInfo extends StatefulWidget {
  final int index;

  const _PriceInfo(this.index, {super.key});

  @override
  State<_PriceInfo> createState() => _PriceInfoState();
}

class _PriceInfoState extends State<_PriceInfo> {
  late double priceInHrk, priceInEur;

  @override
  void initState() {
    super.initState();
    priceInHrk = FuelTrendsChartSection.selectedPrices.isNotEmpty
        ? FuelTrendsChartSection.selectedPrices[widget.index].price
        : MinGOData.priceTrends
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
                    FuelTrendsChartSection.chartColors
                        .elementAt(
                          FuelTrendsChartSection.selectedPrices.isEmpty
                              ? widget.index
                              : FuelTrendsChartSection.selectedPrices[widget.index].fuelId - 1,
                        )
                        .hexString
                        .replaceAll('#', '0xff'),
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
                    text: DashboardPageSearchField.fuelKinds[FuelTrendsChartSection.selectedPrices.isEmpty
                        ? widget.index
                        : FuelTrendsChartSection.selectedPrices[widget.index].fuelId - 1],
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.grey),
                  ),
                  TextSpan(
                    text: (DateTime.now().year > 2023
                            ? priceInEur.toStringAsFixed(2) +
                                ' EUR / L' +
                                (DateTime.now().year < 2023 || DateTime.now().year == 2023 && DateTime.now().month < 6 ? '  •  ' : '')
                            : '') +
                        (DateTime.now().year < 2023 || DateTime.now().year == 2023 && DateTime.now().month < 6
                            ? '  ' + priceInHrk.toStringAsFixed(2) + ' HRK / L'
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

class FuelTrendsChartSection extends StatefulWidget {
  final List<PriceTrendModel>? data;

  const FuelTrendsChartSection({
    super.key,
    this.data,
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

  static final List<PriceTrendModel> selectedPrices = [];

  @override
  State<FuelTrendsChartSection> createState() => _FuelTrendsChartSectionState();
}

class _FuelTrendsChartSectionState extends State<FuelTrendsChartSection> {
  late List<charts.Series<PriceTrendModel, DateTime>> _seriesList;

  final _filtered = <List<PriceTrendModel>>[];

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      for (var gasType in {1, 2, 3, 4}) {
        final trends = widget.data!.where((e) => e.fuelId == gasType);
        if (trends.isNotEmpty) _filtered.add(trends.toList());
      }
      _seriesList = <charts.Series<PriceTrendModel, DateTime>>[
        for (var i = 0; i < _filtered.length; i++)
          charts.Series<PriceTrendModel, DateTime>(
            id: 'Trends',
            colorFn: (_, __) => FuelTrendsChartSection.chartColors[_filtered[i].first.fuelId - 1],
            domainFn: (PriceTrendModel gas, _) => gas.lastUpdated,
            measureFn: (PriceTrendModel gas, _) => gas.price,
            data: _filtered[i],
          ),
      ];
      for (var trend in _filtered) {
        FuelTrendsChartSection.selectedPrices.add(trend.last);
      }
    } else {
      _seriesList = <charts.Series<PriceTrendModel, DateTime>>[
        for (int i = 0;
            i <
                ((FuelTrendsChartSection.selectedPrices.isNotEmpty ? FuelTrendsChartSection.selectedPrices : FuelTrendsChartSection.fuelIds)
                        as Iterable)
                    .length;
            i++)
          charts.Series<PriceTrendModel, DateTime>(
            id: 'Trends',
            colorFn: (_, __) => FuelTrendsChartSection.chartColors[i],
            domainFn: (PriceTrendModel gas, _) => gas.lastUpdated,
            measureFn: (PriceTrendModel gas, _) => gas.price,
            data: MinGOData.priceTrends
                .where(
                  (e) => e.fuelId == FuelTrendsChartSection.fuelIds.elementAt(i),
                )
                .toList(),
          ),
      ];
    }
  }

  final _selectedDateController = StreamController<DateTime?>.broadcast();

  @override
  Widget build(BuildContext context) {
    if (_seriesList.isEmpty) return const SizedBox();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Padding(
        padding: MediaQuery.of(context).size.width < 1000
            ? Att.accepted
                ? const EdgeInsets.symmetric(vertical: 30)
                : const EdgeInsets.only(top: 30, bottom: 10)
            : const EdgeInsets.symmetric(vertical: 60),
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
                      padding: MediaQuery.of(context).size.width < 1000
                          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 20)
                          : const EdgeInsets.symmetric(horizontal: 14, vertical: 26),
                      child: LimitedBox(
                        maxHeight: MediaQuery.of(context).size.width < 600
                            ? 300
                            : MediaQuery.of(context).size.height < 800
                                ? 400
                                : MediaQuery.of(context).size.height < 1000
                                    ? 700
                                    : 800,
                        child: charts.TimeSeriesChart(
                          _seriesList,
                          dateTimeFactory: _LocalizedDateTimeFactory(
                            locale: Localizations.localeOf(context),
                          ),
                          animate: false,
                          selectionModels: [
                            charts.SelectionModelConfig(
                              changedListener: (model) {
                                FuelTrendsChartSection.selectedPrices.clear();
                                for (var selection in model.selectedDatum) {
                                  if (FuelTrendsChartSection.selectedPrices.where((e) => e.fuelId == selection.datum.fuelId).isEmpty) {
                                    FuelTrendsChartSection.selectedPrices.add(selection.datum);
                                  }
                                }
                                FuelTrendsChartSection.selectedPrices.sort((a, b) => a.fuelId.compareTo(b.fuelId));
                                try {
                                  _selectedDateController.add(model.selectedDatum.first.datum.lastUpdated);
                                } catch (e) {
                                  _selectedDateController.add(null);
                                }
                                if (widget.data != null && FuelTrendsChartSection.selectedPrices.isEmpty) {
                                  for (var trend in _filtered) {
                                    FuelTrendsChartSection.selectedPrices.add(trend.last);
                                  }
                                }
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    StreamBuilder<DateTime?>(
                      stream: _selectedDateController.stream,
                      builder: (context, selectedDate) {
                        if (selectedDate.data == null) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: Text(
                            selectedDate.data!.day.toString() +
                                '.' +
                                selectedDate.data!.month.toString() +
                                '.' +
                                selectedDate.data!.year.toString() +
                                '.',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        );
                      },
                    ),
                    for (int i = 0;
                        i <
                            (FuelTrendsChartSection.selectedPrices.isEmpty
                                ? _seriesList.length
                                : FuelTrendsChartSection.selectedPrices.length);
                        i++)
                      _PriceInfo(
                        i,
                        key: UniqueKey(),
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

  @override
  void dispose() {
    FuelTrendsChartSection.selectedPrices.clear();
    _selectedDateController.close();
    super.dispose();
  }
}
