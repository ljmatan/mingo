import 'package:flutter/material.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/models/app_data.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/bloc/open_stations_controller.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/elements/large_station_preview/large_station_preview.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/elements/search_field/elements/station_preview/station_preview.dart';
import 'package:mingo/view/shared/basic/action_button.dart';
import 'package:mingo/view/shared/widgets/title/title.dart';

class DashboardPageOpenStations extends StatefulWidget {
  final bool searchView;

  const DashboardPageOpenStations({
    super.key,
    this.searchView = false,
  });

  @override
  State<DashboardPageOpenStations> createState() => _DashboardPageOpenStationsState();
}

class _DashboardPageOpenStationsState extends State<DashboardPageOpenStations> {
  int _page = 1;
  int get length => _page * 3;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width < 1000
        ? StreamBuilder<List<Station>>(
            stream: DashboardPageOpenStationsController.stream,
            initialData: MinGOData.orderedStations,
            builder: (context, openStations) {
              if ((openStations.data!.length < length ? openStations.data!.length : length) > 0) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(color: Colors.white),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: MinGOTitle(
                          label: 'Otvorene postaje',
                          subtitle: 'Pronađite najpovoljniju benzinsku postaju',
                          iconFilename: 'vectors/dashboard/gas_tank_illustration.svg',
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Color(0xffF9F9F9),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            for (int i = 0; i < (openStations.data!.length < length ? openStations.data!.length : length); i++)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.width < 1000 ? double.infinity : MediaQuery.of(context).size.height / 3,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  child: DashboardPageLargeStationPreview(
                                    openStations.data![i],
                                    key: UniqueKey(),
                                  ),
                                ),
                              ),
                            if (_page * 3 < openStations.data!.length)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                child: Center(
                                  child: MinGOActionButton(
                                    label: 'Prikaži više',
                                    icon: Icons.chevron_right,
                                    onTap: () {
                                      if (mounted) setState(() => _page++);
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          )
        : widget.searchView
            ? StreamBuilder<List<Station>>(
                stream: DashboardPageOpenStationsController.stream,
                initialData: MinGOData.orderedStations,
                builder: (context, openStations) {
                  if (openStations.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(left: 14),
                      child: Text('Nema pronađenih postaja'),
                    );
                  }
                  return Expanded(
                    child: Column(
                      children: [
                        for (int i = 0;
                            i <
                                (openStations.data!.length < (MediaQuery.of(context).size.width < 1200 ? 2 : 3)
                                    ? openStations.data!.length
                                    : (MediaQuery.of(context).size.width < 1200 ? 2 : 3));
                            i++)
                          DashboardPageSearchFieldStationPreview(openStations.data![i]),
                      ],
                    ),
                  );
                },
              )
            : DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xffF9F9F9),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: StreamBuilder<List<Station>>(
                    stream: DashboardPageOpenStationsController.stream,
                    initialData: MinGOData.orderedStations,
                    builder: (context, openStations) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              for (int i = 0; i < (openStations.data!.length < length ? openStations.data!.length : length); i++)
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: DashboardPageLargeStationPreview(
                                    MinGOData.orderedStations[i],
                                  ),
                                ),
                            ],
                          ),
                          if (_page * 3 < openStations.data!.length - 3)
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Center(
                                child: MinGOActionButton(
                                  label: 'Prikaži više',
                                  icon: Icons.chevron_right,
                                  minWidth: true,
                                  onTap: () {
                                    if (mounted) setState(() => _page++);
                                  },
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              );
  }
}
