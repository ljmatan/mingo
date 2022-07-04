import 'package:flutter/material.dart';
import 'package:mingo/view/shared/widgets/title/title.dart';
import 'package:mingo/view/shared/widgets/footer/footer.dart';
import 'package:mingo/view/shared/widgets/newsletter_subscription/newsletter_subscription_field.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  static const _guidePoints = <String>{
    'Postaje možete pretraživati i prema njihovim dodatnim uslugama. Kliknite Detaljno filtriranje ispod mape i pronađite postaje s '
        'dodatnim karakteristikama, ponudama i uslugama',
    'Ukoliko želite primati obavijesti o cijenama goriva na email, prijavite se pomoću forme na dnu naslovne stranice',
    'Na stranici svake postaje možete vidjeti trend kretanja cijena osnovnih vrsta goriva',
  };

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width < 1000
        ? ListView(
            padding: EdgeInsets.zero,
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: MinGOTitle(label: 'Upute za korištenje'),
                    ),
                    for (int i = 0; i < _guidePoints.length; i++)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: Text(
                                (i + 1).toString() + '.',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 26,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _guidePoints.elementAt(i),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              Image.asset(
                'assets/images/guide_page/0.jpg',
                width: MediaQuery.of(context).size.width,
                height: 300,
                fit: BoxFit.cover,
              ),
              const NewsletterSubscriptionField(),
              const Footer(),
            ],
          )
        : Column(
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      for (int i = 0; i < 2; i++)
                        Expanded(
                          child: i == 0
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 60),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(bottom: 40),
                                          child: MinGOTitle(label: 'Upute za korištenje'),
                                        ),
                                        for (int i = 0; i < _guidePoints.length; i++)
                                          Padding(
                                            padding: EdgeInsets.only(left: 20, bottom: i == _guidePoints.length - 1 ? 0 : 24),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 14),
                                                  child: Text(
                                                    (i + 1).toString() + '.',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 26,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    _guidePoints.elementAt(i),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/guide_page/0.jpg',
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  fit: BoxFit.cover,
                                ),
                        ),
                    ],
                  ),
                ),
              ),
              const NewsletterSubscriptionField(),
              const Footer(),
            ],
          );
  }
}
