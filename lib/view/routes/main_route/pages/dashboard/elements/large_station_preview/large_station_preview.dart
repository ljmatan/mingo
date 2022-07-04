import 'package:flutter/material.dart';
import 'package:mingo/models/app_data.dart';
import 'package:mingo/view/routes/provider_details/provider_details_route.dart';
import 'package:mingo/view/shared/basic/action_button.dart';
import 'package:mingo/view/shared/widgets/fuel_preview/fuel_preview.dart';
import 'package:mingo/view/shared/widgets/provider_info/provider_info.dart';
import 'package:mingo/view/shared/widgets/work_hours_indicator/work_hours_indicator.dart';

class DashboardPageLargeStationPreview extends StatelessWidget {
  final Station station;

  const DashboardPageLargeStationPreview(this.station, {super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width < 1000
            ? double.infinity
            : MediaQuery.of(context).size.width <= 1300
                ? MediaQuery.of(context).size.width / 4
                : MediaQuery.of(context).size.width / 5,
      ),
      child: InkWell(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xffE7E7E7),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            station.place,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            station.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    WorkHoursIndicator(station),
                  ],
                ),
                const SizedBox(height: 10),
                ProviderInfo(station),
                for (int i = 0; i < 2; i++)
                  Padding(
                    padding: i == 0 ? const EdgeInsets.only(top: 12) : const EdgeInsets.only(top: 6),
                    child: FuelPreview(station.priceList[i]),
                  ),
                if (MediaQuery.of(context).size.width < 1000)
                  const Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: MinGOActionButton(
                        label: 'Detalji',
                        icon: Icons.chevron_right,
                        minWidth: true,
                        gradientBorder: true,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => ProviderDetailsRoute(station),
          ),
        ),
      ),
    );
  }
}
