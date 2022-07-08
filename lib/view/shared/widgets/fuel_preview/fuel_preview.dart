import 'package:flutter/material.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/models/app_data.dart';

class FuelPreview extends StatelessWidget {
  final Price price;
  final bool minAxisSize;

  const FuelPreview(
    this.price, {
    super.key,
    this.minAxisSize = false,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xffF9F9F9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 2,
            color: Colors.black12,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: minAxisSize ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 19,
                backgroundColor: Colors.green,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    MinGOData.instance.fuels.firstWhere((e) => e.id == price.fuelId).name!,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                  ),
                ),
                if (DateTime.now().year >= 2023)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(price.priceInEur).toStringAsFixed(2)} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 1),
                        child: Text(
                          'EUR / L',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (DateTime.now().year < 2023 || DateTime.now().year == 2023 && DateTime.now().month < 6)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${price.price} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 1),
                        child: Text(
                          'HRK / L',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (DateTime.now().year < 2023)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(price.priceInEur).toStringAsFixed(2)} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 1),
                        child: Text(
                          'EUR / L',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
