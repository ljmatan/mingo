import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/elements/search_field/search_field.dart';
import 'package:mingo/view/shared/basic/action_button.dart';
import 'package:mingo/view/shared/widgets/map/leaflet_map.dart';

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

class DashboardPageSearchView extends StatefulWidget {
  final GlobalKey<LeafletMapState> mapKey;
  final TextEditingController searchFieldController;
  final void Function() closeSearchView;

  const DashboardPageSearchView({
    super.key,
    required this.mapKey,
    required this.searchFieldController,
    required this.closeSearchView,
  });

  @override
  State<DashboardPageSearchView> createState() => _DashboardPageSearchViewState();
}

class _DashboardPageSearchViewState extends State<DashboardPageSearchView> {
  final _searchTermConroller = StreamController<String>.broadcast();

  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    widget.searchFieldController.addListener(() {
      if (_searchTerm != widget.searchFieldController.text) {
        _searchTerm = widget.searchFieldController.text;
        _searchTermConroller.add(_searchTerm);
      }
    });
  }

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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: MediaQuery.of(context).size.width > 1000 ? 16 : 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DashboardPageSearchTextInputField(
                      searchFieldController: widget.searchFieldController,
                      autofocus: true,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.white),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Text(
                        'Sela, gradovi i naselja',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    StreamBuilder(
                      stream: _searchTermConroller.stream,
                      initialData: widget.searchFieldController.text,
                      builder: (context, searchTerm) {
                        final places = searchTerm.data!.isEmpty
                            ? MinGOData.instance.places
                            : MinGOData.instance.places
                                .where(
                                  (e) =>
                                      e.name.split(' ').where((e) => e.toLowerCase().startsWith(searchTerm.data!.toLowerCase())).isNotEmpty,
                                )
                                .toList();
                        if (places.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text('Nema rezultata pretrage'),
                          );
                        }
                        if (searchTerm.data!.isEmpty) places.shuffle();
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var place in places.sublist(0, places.length > 100 ? 100 : places.length))
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                                child: _SelectableButton(
                                  initialValue: false,
                                  label: place.name,
                                  onTap: () async {
                                    widget.searchFieldController.text = place.name;
                                    await widget.mapKey.currentState!.move(
                                      lat: double.parse(place.lat!),
                                      lng: double.parse(place.lng!),
                                      animated: false,
                                    );
                                    widget.closeSearchView();
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xffF9F9F9),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
                child: MinGOActionButton(
                  label: 'Nazad',
                  onTap: () {
                    widget.closeSearchView();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
