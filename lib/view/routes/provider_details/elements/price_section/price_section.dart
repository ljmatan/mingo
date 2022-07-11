import 'package:flutter/material.dart';
import 'package:mingo/models/app_data.dart';
import 'package:mingo/view/shared/widgets/fuel_preview/fuel_preview.dart';
import 'package:mingo/view/shared/widgets/title/title.dart';

class ProvidersPagePriceSection extends StatelessWidget {
  final Station station;

  const ProvidersPagePriceSection(this.station, {super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xff16FFBD),
      ),
      child: Padding(
        padding: MediaQuery.of(context).size.width < 1000
            ? const EdgeInsets.only(bottom: 24)
            : EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1 / 8), vertical: 50),
        child: Column(
          crossAxisAlignment: MediaQuery.of(context).size.width < 1000 ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: MediaQuery.of(context).size.width < 1000
                  ? const EdgeInsets.only(top: 24, bottom: 20)
                  : const EdgeInsets.symmetric(horizontal: 10),
              child: const MinGOTitle(
                label: 'Cijene goriva',
                subtitle: '',
                iconFilename: 'vectors/provider_page/pig_illustration.svg',
                lineColor: Colors.white,
              ),
            ),
            MediaQuery.of(context).size.width < 1000
                ? Column(
                    children: [
                      for (int i = 0; i < station.priceList.length; i++)
                        Padding(
                          padding: i == 0 ? const EdgeInsets.symmetric(horizontal: 20) : const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: FuelPreview(station.priceList[i]),
                        ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          for (int i = 0; i < station.priceList.length; i++)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
                              child: FuelPreview(
                                station.priceList[i],
                                minAxisSize: true,
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
}
