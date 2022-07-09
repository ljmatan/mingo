import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/services/location/location.dart';
import 'package:mingo/utils/station/station_util.dart';
import 'package:mingo/view/shared/widgets/footer/footer.dart';
import 'package:mingo/view/shared/widgets/map/leaflet_map.dart';
import 'package:mingo/view/shared/widgets/newsletter_subscription/newsletter_subscription_field.dart';
import 'package:latlong2/latlong.dart';

class ProvidersSearchPage extends StatefulWidget {
  const ProvidersSearchPage({super.key});

  @override
  State<ProvidersSearchPage> createState() => _ProvidersSearchPageState();
}

class _ProvidersSearchPageState extends State<ProvidersSearchPage> with WidgetsBindingObserver {
  final _textInputController = TextEditingController();
  final _textInputFocusNode = FocusNode();

  final _resultsViewController = StreamController<bool>.broadcast();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _textInputController.addListener(() => _resultsViewController.add(_textInputFocusNode.hasFocus));
    _textInputFocusNode.addListener(() {
      Future.delayed(const Duration(milliseconds: 100), () {
        _resultsViewController.add(_textInputFocusNode.hasFocus);
      });
    });
  }

  final _mapKey = GlobalKey<LeafletMapState>();

  bool _gpsLoading = false;

  bool _keyboardDisplayed = false;
  // To avoid emulator issues, if and else if clauses had to be used,
  // as opposed to simply doing:
  // if (WidgetsBinding.instance.window.viewInsets.bottom == 0) {
  //   _textFieldNode.unfocus();
  // }
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final insets = WidgetsBinding.instance.window.viewInsets.bottom;
    if (_keyboardDisplayed && insets == 0) {
      _textInputFocusNode.unfocus();
      _keyboardDisplayed = false;
    } else if (!_keyboardDisplayed && insets > 0) {
      _keyboardDisplayed = true;
    }
  }

  bool _scrollEnabled = true;
  void _enableScroll(bool enabled) => setState(() => _scrollEnabled = enabled);

  void _fitProviderBounds() {
    if (MinGOData.selectedProvidersStations.isNotEmpty) {
      _mapKey.currentState!.fitBounds(
        StationUtil.boundsFromLatLngList(
          [
            for (var station in MinGOData.selectedProvidersStations)
              LatLng(
                double.parse(station.lng!),
                double.parse(station.lat!),
              ),
          ],
        ),
      );
    } else {
      _mapKey.currentState!.move(lat: 45.8150, lng: 15.9819);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width < 1000
        ? ListView(
            physics: _scrollEnabled ? null : const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .8,
                child: Stack(
                  children: [
                    SizedBox.expand(
                      child: Stack(
                        children: [
                          Listener(
                            child: kIsWeb
                                ? MouseRegion(
                                    child: LeafletMap(
                                      key: _mapKey,
                                      providersSearch: true,
                                    ),
                                    onEnter: (_) => _mapKey.currentState!.enableInput(false),
                                    onExit: (_) => _mapKey.currentState!.enableInput(true),
                                    cursor: MouseCursor.uncontrolled,
                                  )
                                : LeafletMap(
                                    key: _mapKey,
                                    providersSearch: true,
                                  ),
                            onPointerDown: (_) {
                              if (_textInputFocusNode.hasFocus) FocusScope.of(context).unfocus();
                              _enableScroll(false);
                            },
                            onPointerUp: (_) {
                              _enableScroll(true);
                            },
                          ),
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0; i < 3; i++)
                                  MediaQuery.of(context).size.width < 1000 && !kIsWeb && i != 2
                                      ? const SizedBox()
                                      : Padding(
                                          padding: i == 1 ? const EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
                                          child: StatefulBuilder(
                                            builder: (context, setState) {
                                              return InkWell(
                                                child: DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    color: i == 2 && _gpsLoading ? Theme.of(context).primaryColor : Colors.white,
                                                    border: i == 0
                                                        ? const Border(
                                                            bottom: BorderSide(
                                                              color: Color(0xffCCCCCC),
                                                            ),
                                                          )
                                                        : null,
                                                  ),
                                                  child: SizedBox(
                                                    width: MediaQuery.of(context).size.width > 1000 ? 36 : 44,
                                                    height: MediaQuery.of(context).size.width > 1000 ? 36 : 44,
                                                    child: Center(
                                                      child: Icon(
                                                        i == 0
                                                            ? Icons.add
                                                            : i == 1
                                                                ? Icons.remove
                                                                : Icons.gps_fixed,
                                                        color: i == 2 && _gpsLoading ? Colors.white : null,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onTap: () async {
                                                  switch (i) {
                                                    case 0:
                                                    case 1:
                                                      _mapKey.currentState!.move(
                                                        zoom: i == 0 ? .5 : -.5,
                                                        absoluteZoomValue: false,
                                                      );
                                                      break;
                                                    case 2:
                                                      if (!_gpsLoading) {
                                                        try {
                                                          setState(() => _gpsLoading = true);
                                                          final position = await LocationServices.getCurrentLocation();
                                                          _mapKey.currentState!.move(
                                                            lat: position.latitude,
                                                            lng: position.longitude,
                                                          );
                                                          setState(() => _gpsLoading = false);
                                                        } catch (e) {
                                                          setState(() => _gpsLoading = false);
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text('$e'),
                                                            ),
                                                          );
                                                        }
                                                      }
                                                      break;
                                                    default:
                                                      throw 'Not implemented';
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: 16,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Stack(
                              children: [
                                StreamBuilder(
                                  stream: _resultsViewController.stream,
                                  initialData: _textInputFocusNode.hasFocus,
                                  builder: (context, hasFocus) {
                                    final providers = _textInputController.text.isNotEmpty
                                        ? MinGOData.instance.providers.where(
                                            (e) =>
                                                _textInputController.text.trim().length > 3 &&
                                                    e.name.toLowerCase().contains(_textInputController.text.trim().toLowerCase()) ||
                                                e.name.toLowerCase().startsWith(_textInputController.text.trim().toLowerCase()) ||
                                                e.name
                                                    .split(' ')
                                                    .where(
                                                      (e) => e.toLowerCase().startsWith(_textInputController.text.trim().toLowerCase()),
                                                    )
                                                    .isNotEmpty,
                                          )
                                        : MinGOData.instance.providers;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 24),
                                      child: AnimatedSize(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.ease,
                                        child: hasFocus.data!
                                            ? DecoratedBox(
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.only(
                                                    bottomLeft: Radius.circular(10),
                                                    bottomRight: Radius.circular(10),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      offset: Offset(0, 4),
                                                      blurRadius: 4,
                                                      color: Colors.black26,
                                                    ),
                                                  ],
                                                ),
                                                child: ConstrainedBox(
                                                  constraints: const BoxConstraints(maxHeight: 200),
                                                  child: ListView(
                                                    padding: const EdgeInsets.only(top: 40, bottom: 8),
                                                    shrinkWrap: true,
                                                    children: [
                                                      if (providers.isEmpty)
                                                        const Padding(
                                                          padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                                                          child: Text('Nema rezultata za upisani pojam'),
                                                        ),
                                                      for (var provider in providers)
                                                        Padding(
                                                          padding: const EdgeInsets.fromLTRB(8, 0, 8, kIsWeb ? 8 : 0),
                                                          child: ActionChip(
                                                            label: Row(
                                                              children: [
                                                                Flexible(
                                                                  child: Text(provider.name),
                                                                ),
                                                              ],
                                                            ),
                                                            backgroundColor: MinGOData.selectedProviders.contains(provider.id)
                                                                ? const Color(0xff16FFBD)
                                                                : Colors.white,
                                                            onPressed: () {
                                                              MinGOData.selectedProviders.contains(provider.id)
                                                                  ? MinGOData.selectedProviders.remove(provider.id)
                                                                  : MinGOData.selectedProviders.add(provider.id);
                                                              setState(() {});
                                                              _fitProviderBounds();
                                                              _textInputFocusNode.requestFocus();
                                                            },
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : SizedBox(width: MediaQuery.of(context).size.width),
                                      ),
                                    );
                                  },
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: const [
                                      BoxShadow(
                                        offset: Offset(0, 4),
                                        blurRadius: 4,
                                        color: Colors.black26,
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _textInputController,
                                    focusNode: _textInputFocusNode,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'Pretražite obveznike',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(100),
                                        borderSide: BorderSide.none,
                                      ),
                                      suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (MinGOData.selectedProviders.isNotEmpty)
                                            IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () {
                                                MinGOData.selectedProviders.clear();
                                                setState(() {});
                                                _fitProviderBounds();
                                              },
                                            ),
                                          if (MinGOData.selectedProviders.isNotEmpty)
                                            const DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: Color(0xff949494),
                                              ),
                                              child: SizedBox(width: 1, height: 26),
                                            ),
                                          IconButton(
                                            icon: const Icon(Icons.arrow_drop_down),
                                            onPressed: () {
                                              _textInputFocusNode.requestFocus();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            children: [
                              for (var providerId in MinGOData.selectedProviders)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6, right: 6),
                                  child: ActionChip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(MinGOData.instance.providers.firstWhere((e) => e.id == providerId).name),
                                        const SizedBox(width: 16),
                                        const Icon(
                                          Icons.close,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xff16FFBD),
                                    onPressed: () {
                                      MinGOData.selectedProviders.remove(providerId);
                                      setState(() {});
                                      _fitProviderBounds();
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const NewsletterSubscriptionField(),
              const Footer(),
            ],
          )
        : Column(
            children: [
              Expanded(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/images/providers_search_page/0.jpg',
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  left: 16,
                                  top: 16,
                                  right: 10,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 6),
                                        child: Stack(
                                          children: [
                                            StreamBuilder(
                                              stream: _resultsViewController.stream,
                                              initialData: _textInputFocusNode.hasFocus,
                                              builder: (context, hasFocus) {
                                                final providers = _textInputController.text.isNotEmpty
                                                    ? MinGOData.instance.providers.where(
                                                        (e) => e.name
                                                            .split(' ')
                                                            .where(
                                                              (e) => e.toLowerCase().startsWith(_textInputController.text.toLowerCase()),
                                                            )
                                                            .isNotEmpty,
                                                      )
                                                    : MinGOData.instance.providers;
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 24),
                                                  child: AnimatedSize(
                                                    duration: const Duration(milliseconds: 300),
                                                    curve: Curves.ease,
                                                    child: hasFocus.data!
                                                        ? DecoratedBox(
                                                            decoration: const BoxDecoration(
                                                              color: Colors.white,
                                                              borderRadius: BorderRadius.only(
                                                                bottomLeft: Radius.circular(10),
                                                                bottomRight: Radius.circular(10),
                                                              ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  offset: Offset(0, 4),
                                                                  blurRadius: 4,
                                                                  color: Colors.black26,
                                                                ),
                                                              ],
                                                            ),
                                                            child: ConstrainedBox(
                                                              constraints: const BoxConstraints(maxHeight: 240),
                                                              child: ListView(
                                                                padding: const EdgeInsets.only(top: 40, bottom: 8),
                                                                shrinkWrap: true,
                                                                children: [
                                                                  if (providers.isEmpty)
                                                                    const Padding(
                                                                      padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                                                                      child: Text('Nema rezultata za upisani pojam'),
                                                                    ),
                                                                  for (var provider in providers)
                                                                    Padding(
                                                                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                                                      child: ActionChip(
                                                                        label: Row(
                                                                          children: [
                                                                            Text(provider.name),
                                                                          ],
                                                                        ),
                                                                        backgroundColor: MinGOData.selectedProviders.contains(provider.id)
                                                                            ? const Color(0xff16FFBD)
                                                                            : Colors.white,
                                                                        onPressed: () {
                                                                          MinGOData.selectedProviders.contains(provider.id)
                                                                              ? MinGOData.selectedProviders.remove(provider.id)
                                                                              : MinGOData.selectedProviders.add(provider.id);
                                                                          setState(() {});
                                                                          _fitProviderBounds();
                                                                          _textInputFocusNode.requestFocus();
                                                                        },
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : SizedBox(width: MediaQuery.of(context).size.width),
                                                  ),
                                                );
                                              },
                                            ),
                                            DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(100),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    offset: Offset(0, 4),
                                                    blurRadius: 4,
                                                    color: Colors.black26,
                                                  ),
                                                ],
                                              ),
                                              child: TextField(
                                                controller: _textInputController,
                                                focusNode: _textInputFocusNode,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  hintText: 'Pretražite obveznike',
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(100),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  suffixIcon: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      if (MinGOData.selectedProviders.isNotEmpty)
                                                        IconButton(
                                                          icon: const Icon(Icons.close),
                                                          onPressed: () {
                                                            MinGOData.selectedProviders.clear();
                                                            setState(() {});
                                                            _fitProviderBounds();
                                                          },
                                                        ),
                                                      if (MinGOData.selectedProviders.isNotEmpty)
                                                        const DecoratedBox(
                                                          decoration: BoxDecoration(
                                                            color: Color(0xff949494),
                                                          ),
                                                          child: SizedBox(width: 1, height: 26),
                                                        ),
                                                      IconButton(
                                                        icon: const Icon(Icons.arrow_drop_down),
                                                        onPressed: () {
                                                          _textInputFocusNode.requestFocus();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        children: [
                                          for (var providerId in MinGOData.selectedProviders)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6, right: 6),
                                              child: ActionChip(
                                                label: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(MinGOData.instance.providers.firstWhere((e) => e.id == providerId).name),
                                                    const SizedBox(width: 16),
                                                    const Icon(
                                                      Icons.close,
                                                      size: 20,
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor: const Color(0xff16FFBD),
                                                onPressed: () {
                                                  MinGOData.selectedProviders.remove(providerId);
                                                  setState(() {});
                                                  _fitProviderBounds();
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .55,
                          height: MediaQuery.of(context).size.height,
                          child: Stack(
                            children: [
                              Listener(
                                child: kIsWeb
                                    ? MouseRegion(
                                        child: LeafletMap(
                                          key: _mapKey,
                                          providersSearch: true,
                                        ),
                                        onEnter: (_) => _mapKey.currentState!.enableInput(false),
                                        onExit: (_) => _mapKey.currentState!.enableInput(true),
                                        cursor: MouseCursor.uncontrolled,
                                      )
                                    : LeafletMap(
                                        key: _mapKey,
                                        providersSearch: true,
                                      ),
                              ),
                              Positioned(
                                right: 14,
                                bottom: 14,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (int i = 0; i < 3; i++)
                                      MediaQuery.of(context).size.width < 1000 && !kIsWeb && i != 2
                                          ? const SizedBox()
                                          : Padding(
                                              padding: i == 1 ? const EdgeInsets.only(bottom: 8) : EdgeInsets.zero,
                                              child: StatefulBuilder(
                                                builder: (context, setState) {
                                                  return InkWell(
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        color: i == 2 && _gpsLoading ? Theme.of(context).primaryColor : Colors.white,
                                                        border: i == 0
                                                            ? const Border(
                                                                bottom: BorderSide(
                                                                  color: Color(0xffCCCCCC),
                                                                ),
                                                              )
                                                            : null,
                                                      ),
                                                      child: SizedBox(
                                                        width: MediaQuery.of(context).size.width > 1000 ? 36 : 44,
                                                        height: MediaQuery.of(context).size.width > 1000 ? 36 : 44,
                                                        child: Center(
                                                          child: Icon(
                                                            i == 0
                                                                ? Icons.add
                                                                : i == 1
                                                                    ? Icons.remove
                                                                    : Icons.gps_fixed,
                                                            color: i == 2 && _gpsLoading ? Colors.white : null,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () async {
                                                      switch (i) {
                                                        case 0:
                                                        case 1:
                                                          _mapKey.currentState!.move(
                                                            zoom: i == 0 ? .5 : -.5,
                                                            absoluteZoomValue: false,
                                                          );
                                                          break;
                                                        case 2:
                                                          if (!_gpsLoading) {
                                                            try {
                                                              setState(() => _gpsLoading = true);
                                                              final position = await LocationServices.getCurrentLocation();
                                                              _mapKey.currentState!.move(
                                                                lat: position.latitude,
                                                                lng: position.longitude,
                                                              );
                                                              setState(() => _gpsLoading = false);
                                                            } catch (e) {
                                                              setState(() => _gpsLoading = false);
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(
                                                                  content: Text('$e'),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                          break;
                                                        default:
                                                          throw 'Not implemented';
                                                      }
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                  ],
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
              const NewsletterSubscriptionField(),
              const Footer(),
            ],
          );
  }

  @override
  void dispose() {
    _textInputController.dispose();
    _textInputFocusNode.dispose();
    _resultsViewController.close();
    MinGOData.selectedProviders.clear();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
