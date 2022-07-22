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

  int _fuelTypeId(int fuelId) {
    try {
      return MinGOData.instance.fuelTypes
          .firstWhere((e) => e.id == MinGOData.instance.fuels.firstWhere((e) => e.id == fuelId).fuelKindId)
          .fuelKindId;
    } catch (e) {
      return 5;
    }
  }

  Color _fuelColor(int fuelId) {
    final int fuelTypeId = _fuelTypeId(fuelId);
    switch (fuelTypeId) {
      case 1:
        return const Color(0xff8DD374);
      case 2:
        return const Color(0xff2C313C);
      case 3:
        return const Color(0xffFAC02D);
      case 4:
        return const Color(0xff701D46);
      default:
        return Colors.grey;
    }
  }

  String _fuelMarking(int fuelId) {
    final int fuelTypeId = _fuelTypeId(fuelId);
    switch (fuelTypeId) {
      case 1:
        return 'E';
      case 2:
        return 'B';
      case 3:
        return 'H';
      case 4:
        return 'L';
      default:
        return 'N';
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
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
          padding: minAxisSize ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8) : const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: minAxisSize ? MainAxisSize.min : MainAxisSize.max,
            children: [
              if (minAxisSize) const SizedBox(width: 20),
              Padding(
                padding: minAxisSize ? const EdgeInsets.only(right: 16) : const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: _fuelColor(price.fuelId),
                  child: Text(
                    _fuelMarking(price.fuelId),
                    style: const TextStyle(color: Colors.white),
                  ),
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
              if (minAxisSize) const SizedBox(width: 20),
            ],
          ),
        ),
      );
    } catch (e) {
      return const SizedBox();
    }
  }
}
