import 'package:flutter/material.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/models/app_data.dart';
import 'package:mingo/utils/station/station_util.dart';
import 'package:mingo/view/routes/provider_details/provider_details_route.dart';
import 'package:mingo/view/shared/widgets/fuel_preview/fuel_preview.dart';
import 'package:mingo/view/shared/widgets/provider_info/provider_info.dart';

class DashboardPageSearchFieldStationPreview extends StatefulWidget {
  final Station station;

  const DashboardPageSearchFieldStationPreview(this.station, {super.key});

  @override
  State<DashboardPageSearchFieldStationPreview> createState() => _DashboardPageSearchFieldStationPreviewState();
}

class _DashboardPageSearchFieldStationPreviewState extends State<DashboardPageSearchFieldStationPreview> {
  late List<Price> prices;

  @override
  void initState() {
    super.initState();
    prices = widget.station.priceList
        .where(
          (p) =>
              MinGOData.instance.fuels.firstWhere((f) => f.id == p.fuelId).fuelKindId == 9 && MinGOData.filterConfig.fuelTypeId == 3 ||
              MinGOData.instance.fuels.firstWhere((f) => f.id == p.fuelId).fuelKindId == 10 && MinGOData.filterConfig.fuelTypeId == 4 ||
              MinGOData.instance.fuels.firstWhere((f) => f.id == p.fuelId).fuelKindId == 1 && MinGOData.filterConfig.fuelTypeId == 1 ||
              MinGOData.instance.fuels.firstWhere((f) => f.id == p.fuelId).fuelKindId == 2 && MinGOData.filterConfig.fuelTypeId == 1 ||
              MinGOData.instance.fuels.firstWhere((f) => f.id == p.fuelId).fuelKindId == 7 && MinGOData.filterConfig.fuelTypeId == 2 ||
              MinGOData.instance.fuels.firstWhere((f) => f.id == p.fuelId).fuelKindId == 8 && MinGOData.filterConfig.fuelTypeId == 2,
        )
        .toList();
    prices.sort((a, b) => a.price!.compareTo(b.price!));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
        child: InkWell(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: (MediaQuery.of(context).size.width < 1000
                      ? MediaQuery.of(context).size.height / 2
                      : MediaQuery.of(context).size.height > 1000
                          ? 800
                          : 600) /
                  2,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xffE7E7E7),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.station.place,
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                widget.station.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: MediaQuery.of(context).size.width < 1000 || MediaQuery.of(context).size.width > 1200 ? null : 1,
                              ),
                              ProviderInfo(
                                widget.station,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: StationUtil.timeColor(widget.station),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  child: Text(
                                    StationUtil.isOpen(widget.station) ? 'Otvoreno' : 'Zatvoreno',
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 16, bottom: 6),
                                child: Text(
                                  'Radno vrijeme',
                                  style: TextStyle(
                                    color: Color(0xffC6C8CC),
                                  ),
                                ),
                              ),
                              Text(
                                StationUtil.formattedTime(widget.station),
                                style: const TextStyle(
                                  color: Color(0xffC6C8CC),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 72,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (int j = 0; j < prices.length; j++)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Padding(
                                padding: j == 0 ? const EdgeInsets.only(right: 4) : const EdgeInsets.only(left: 4),
                                child: FuelPreview(
                                  prices[j],
                                  minAxisSize: true,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => ProviderDetailsRoute(widget.station),
            ),
          ),
        ),
      ),
    );
  }
}
