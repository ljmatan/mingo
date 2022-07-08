import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/view/shared/basic/action_button.dart';
import 'package:mingo/view/theme.dart';

class _SelectableButton extends StatefulWidget {
  final bool initialValue;
  final String label;
  final Function onTap;

  const _SelectableButton({
    required this.initialValue,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SelectableButton> createState() => __SelectableButtonState();
}

class __SelectableButtonState extends State<_SelectableButton> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _value ? const Color(0xff00A1F1) : Theme.of(context).primaryColor,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 16,
                    color: _value ? const Color(0xff00A1F1) : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        widget.onTap();
        setState(() => _value = !_value);
      },
    );
  }
}

class DashboardPageFilterView extends StatefulWidget {
  final void Function() closeFilterView;

  const DashboardPageFilterView({
    super.key,
    required this.closeFilterView,
  });

  @override
  State<DashboardPageFilterView> createState() => _DashboardPageFilterViewState();
}

class _DashboardPageFilterViewState extends State<DashboardPageFilterView> {
  static const _filterLabels = <String>{
    'Vrste goriva',
    'Opcije postaje',
    'Radno vrijeme',
    'Obveznici',
  };

  static const _daysInWeek = <String>[
    'Ponedjeljak',
    'Utorak',
    'Srijeda',
    'Četvrtak',
    'Petak',
    'Subota',
    'Nedjelja',
  ];

  List _filterOptions(int filterPage) {
    switch (filterPage) {
      case 0:
        return MinGOData.instance.fuelTypes;
      case 1:
        return MinGOData.instance.options;
      case 2:
        return _daysInWeek;
      case 3:
        return MinGOData.instance.providers;
      default:
        throw 'Not implemented';
    }
  }

  final _filterViewController = StreamController<int>.broadcast();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xfff9f9f9),
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.height : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xff435467),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(left: 16, right: 10),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          Text(
                            'Nazad',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: widget.closeFilterView,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: SizedBox(
                      height: 64,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (int i = 0; i < 4; i++)
                            StreamBuilder(
                              stream: _filterViewController.stream,
                              initialData: 0,
                              builder: (context, selected) {
                                return InkWell(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: selected.data! == i ? MinGOTheme.buttonGradient : null,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: SvgPicture.asset(
                                              'assets/vectors/search_field_filters/$i.svg',
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            _filterLabels.elementAt(i),
                                            style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    _filterViewController.add(i);
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
            ),
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.white),
                child: StreamBuilder(
                  stream: _filterViewController.stream,
                  initialData: 0,
                  builder: (context, selected) {
                    return ListView(
                      padding: EdgeInsets.zero,
                      key: UniqueKey(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Text(
                            _filterLabels.elementAt(selected.data!),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        if (selected.data! != 2)
                          for (var value in _filterOptions(selected.data!))
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                              child: _SelectableButton(
                                initialValue: MinGOData.filteredFuelTypes.where((e) => e['name'] == value.name).isNotEmpty ||
                                    MinGOData.filteredOptions.contains(value.id) ||
                                    MinGOData.filteredProviders.contains(value.id),
                                label: value.name,
                                onTap: () {
                                  switch (selected.data) {
                                    case 0:
                                      if (MinGOData.filteredFuelTypes.where((e) => e['id'] == value.fuelKindId).isNotEmpty) {
                                        MinGOData.filteredFuelTypes.removeWhere((e) => e['id'] == value.fuelKindId);
                                      } else {
                                        MinGOData.filteredFuelTypes.add({
                                          'id': value.fuelKindId,
                                          'name': value.name,
                                        });
                                      }
                                      MinGOData.updateFilteredMarkers();
                                      break;
                                    case 1:
                                      if (MinGOData.filteredOptions.contains(value.id)) {
                                        MinGOData.filteredOptions.remove(value.id);
                                      } else {
                                        MinGOData.filteredOptions.add(value.id);
                                      }
                                      MinGOData.updateFilteredMarkers();
                                      break;
                                    case 3:
                                      if (MinGOData.filteredProviders.contains(value.id)) {
                                        MinGOData.filteredProviders.remove(value.id);
                                      } else {
                                        MinGOData.filteredProviders.add(value.id);
                                      }
                                      MinGOData.updateFilteredMarkers();
                                      break;
                                    default:
                                      throw 'An error occurred';
                                  }
                                },
                              ),
                            )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Text('Dan u tjednu'),
                                ),
                                for (int i = 0; i < 7; i++)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: _SelectableButton(
                                      initialValue: MinGOData.filteredWorkDays.contains(i),
                                      label: _filterOptions(selected.data!).elementAt(i),
                                      onTap: () {
                                        MinGOData.filteredWorkDays.contains(i)
                                            ? MinGOData.filteredWorkDays.remove(i)
                                            : MinGOData.filteredWorkDays.add(i);
                                        MinGOData.updateFilteredMarkers();
                                      },
                                    ),
                                  ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 6, bottom: 12),
                                  child: Text('Vrijeme'),
                                ),
                                _SelectableButton(
                                  initialValue: MinGOData.filteredWorkDaysTimes.contains('00:00 - 24:00'),
                                  label: '00:00 - 24:00',
                                  onTap: () {
                                    MinGOData.filteredWorkDaysTimes.contains('00:00 - 24:00')
                                        ? MinGOData.filteredWorkDaysTimes.remove('00:00 - 24:00')
                                        : MinGOData.filteredWorkDaysTimes.add('00:00 - 24:00');
                                    MinGOData.updateFilteredMarkers();
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6, bottom: 12),
                                  child: _SelectableButton(
                                    initialValue: MinGOData.filteredWorkDaysTimes.contains('06:00 - 22:00'),
                                    label: '06:00 - 22:00',
                                    onTap: () {
                                      MinGOData.filteredWorkDaysTimes.contains('06:00 - 22:00')
                                          ? MinGOData.filteredWorkDaysTimes.remove('06:00 - 22:00')
                                          : MinGOData.filteredWorkDaysTimes.add('06:00 - 22:00');
                                      MinGOData.updateFilteredMarkers();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xffF9F9F9),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
                child: Row(
                  children: [
                    Expanded(
                      child: MinGOActionButton(
                        label: 'Resetiraj filtere',
                        gradientBorder: true,
                        onTap: () {
                          MinGOData.resetFilters();
                          widget.closeFilterView();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MinGOActionButton(
                        label: 'Primijeni filtere',
                        onTap: () {
                          widget.closeFilterView();
                        },
                      ),
                    ),
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
    _filterViewController.close();
    super.dispose();
  }
}
