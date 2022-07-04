import 'package:flutter/material.dart';
import 'package:mingo/view/shared/widgets/title/title.dart';
import 'package:mingo/view/shared/widgets/footer/footer.dart';
import 'package:mingo/view/shared/widgets/newsletter_subscription/newsletter_subscription_field.dart';
import 'package:mingo/view/routes/main_route/pages/privacy_policy/privacy_policy_page.dart';
import 'package:mingo/view/theme.dart';

class _Stat extends StatelessWidget {
  final String value, label;

  const _Stat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: MinGOTheme.buttonGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 140,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '$value+',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: MediaQuery.of(context).size.width < 1000
          ? [
              DecoratedBox(
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: MinGOTitle(label: 'O projektu'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Web portal i aplikacija za mobilne uređaje s informacijama o maloprodajnim '
                        'cijenama naftnih derivata u Republici Hrvatskoj\n\n'
                        'Na web portalu su prikazane cijene svih naftnih derivata na svim benzinskim '
                        'postajama i punionicama autoplina u Republici Hrvatskoj. Aplikacija pokazuje korisnicima '
                        'gdje se nalaze benzinske postaje sa najjeftinijim gorivima, ovisno o lokaciji korisnika.\n\n'
                        'Osnovni ciljevi za pokretanje Web portala i aplikacije o cijenama goriva bili su '
                        'dodatna zaštita potrošača, poticanje tržišnog natjecanja među trgovcima naftnim '
                        'derivatima i konkurentnije određivanje cijena naftnih derivata, pojačavanje tržišne '
                        'utakmice, određivanje cijena na dnevnoj bazi.\n\n'
                        'Stvoreni su uvjeti za trenutačni i potpuni uvid u promjene cijena svih trgovaca naftnim derivatima.',
                        style: MediaQuery.of(context).size.width < 600 ? null : const TextStyle(height: 2),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Image.asset(
                'assets/images/about_page/0.jpg',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xffF9F9F9),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      MinGOTitle(label: 'Projekt u brojkama'),
                      SizedBox(height: 16),
                      _Stat(value: '130', label: 'Obveznika'),
                      SizedBox(height: 6),
                      _Stat(value: '1 000', label: 'Postaja'),
                      SizedBox(height: 6),
                      _Stat(value: '2 000 000', label: 'Unešenih cijena'),
                    ],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: MinGOTitle(label: 'Upute za korištenje'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Ukoliko pretražujete mjesto koje ima identičan naziv s nekim drugim mjestom (npr Ivanec), u adresu '
                        'napišite i županiju u ovom formatu: Ivanec, Varaždinska županija Postaje možete pretraživati i prema '
                        'njihovim dodatnim uslugama. Kliknite Detaljno filtriranje ispod mape i pronađite postaje s dodatnim '
                        'karakteristikama, ponudama i uslugama\n\n'
                        '· Ukoliko želite primati obavijesti o cijenama goriva na email, prijavite se pomoću forme na '
                        'dnu naslovne stranice\n'
                        '· Na stranici svake postaje možete vidjeti trend kretanja cijena \n\n',
                        style: MediaQuery.of(context).size.width < 600 ? null : const TextStyle(height: 2),
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/images/about_page/1.jpg',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              DecoratedBox(
                decoration: const BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < 6; i++)
                        Padding(
                          padding: i % 2 != 0 ? EdgeInsets.only(top: 20, bottom: i == 5 ? 0 : 30) : EdgeInsets.zero,
                          child: Text(
                            PrivacyPolicyPage.dataProtectionPoints.elementAt(i),
                            style: i % 2 == 0
                                ? const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  )
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Image.asset(
                'assets/images/about_page/2.jpg',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              const NewsletterSubscriptionField(),
              const Footer(),
            ]
          : [
              DecoratedBox(
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    for (int i = 0; i < 2; i++)
                      Expanded(
                        child: i == 0
                            ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const MinGOTitle(label: 'O projektu'),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20, top: 40, right: 20),
                                      child: Text(
                                        'Web portal i aplikacija za mobilne uređaje s informacijama o maloprodajnim '
                                        'cijenama naftnih derivata u Republici Hrvatskoj\n\n'
                                        'Na web portalu su prikazane cijene svih naftnih derivata na svim benzinskim '
                                        'postajama i punionicama autoplina u Republici Hrvatskoj. Aplikacija pokazuje korisnicima '
                                        'gdje se nalaze benzinske postaje sa najjeftinijim gorivima, ovisno o lokaciji korisnika.\n\n'
                                        'Osnovni ciljevi za pokretanje Web portala i aplikacije o cijenama goriva bili su '
                                        'dodatna zaštita potrošača, poticanje tržišnog natjecanja među trgovcima naftnim '
                                        'derivatima i konkurentnije određivanje cijena naftnih derivata, pojačavanje tržišne '
                                        'utakmice, određivanje cijena na dnevnoj bazi.\n\n'
                                        'Stvoreni su uvjeti za trenutačni i potpuni uvid u promjene cijena svih trgovaca naftnim derivatima.',
                                        style: MediaQuery.of(context).size.width < 600 ? null : const TextStyle(height: 2),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Image.asset(
                                'assets/images/about_page/0.jpg',
                                width: MediaQuery.of(context).size.width,
                                height: 700,
                                fit: BoxFit.cover,
                              ),
                      ),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xffF9F9F9),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        const MinGOTitle(label: 'Projekt u brojkama'),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 6, vertical: 20),
                          child: Row(
                            children: const [
                              Expanded(
                                child: _Stat(value: '130', label: 'Obveznika'),
                              ),
                              SizedBox(width: 30),
                              Expanded(
                                child: _Stat(value: '1 000', label: 'Postaja'),
                              ),
                              SizedBox(width: 30),
                              Expanded(
                                child: _Stat(value: '2 000 000', label: 'Unešenih cijena'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    for (int i = 0; i < 2; i++)
                      Expanded(
                        child: i == 1
                            ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const MinGOTitle(label: 'Upute za korištenje'),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20, top: 40, right: 20),
                                      child: Text(
                                        'Ukoliko pretražujete mjesto koje ima identičan naziv s nekim drugim mjestom (npr Ivanec), u adresu '
                                        'napišite i županiju u ovom formatu: Ivanec, Varaždinska županija Postaje možete pretraživati i prema '
                                        'njihovim dodatnim uslugama. Kliknite Detaljno filtriranje ispod mape i pronađite postaje s dodatnim '
                                        'karakteristikama, ponudama i uslugama\n\n'
                                        '· Ukoliko želite primati obavijesti o cijenama goriva na email, prijavite se pomoću forme na '
                                        'dnu naslovne stranice\n\n'
                                        '· Na stranici svake postaje možete vidjeti trend kretanja cijena \n\n',
                                        style: MediaQuery.of(context).size.width < 600 ? null : const TextStyle(height: 2),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Image.asset(
                                'assets/images/about_page/1.jpg',
                                width: MediaQuery.of(context).size.width,
                                height: 700,
                                fit: BoxFit.cover,
                              ),
                      ),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    for (int i = 0; i < 2; i++)
                      Expanded(
                        child: i == 0
                            ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (int i = 0; i < 6; i++)
                                      Padding(
                                        padding: i % 2 != 0 ? const EdgeInsets.only(top: 20, bottom: 30) : EdgeInsets.zero,
                                        child: Text(
                                          PrivacyPolicyPage.dataProtectionPoints.elementAt(i),
                                          style: i % 2 == 0
                                              ? const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18,
                                                )
                                              : null,
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            : Image.asset(
                                'assets/images/about_page/2.jpg',
                                width: MediaQuery.of(context).size.width,
                                height: 700,
                                fit: BoxFit.cover,
                              ),
                      ),
                  ],
                ),
              ),
              const NewsletterSubscriptionField(),
              const Footer(),
            ],
    );
  }
}
