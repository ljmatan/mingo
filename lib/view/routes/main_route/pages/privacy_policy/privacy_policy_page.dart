import 'package:flutter/material.dart';
import 'package:mingo/view/shared/widgets/title/title.dart';
import 'package:mingo/view/shared/widgets/footer/footer.dart';
import 'package:mingo/view/shared/widgets/newsletter_subscription/newsletter_subscription_field.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const dataProtectionPoints = <String>{
    'Privatnost podataka',
    'Vaša nam je privatnost iznimno važna. Pravila privatnosti korisnika ove Internet stranice opisuju kako i u koje svrhe Ministarstvo '
        'gospodarstva i održivog razvoja prikuplja te kako koristi vaše osobne podatke. Molimo Vas da se upoznate s praksom zaštite privatnosti.',
    'Prikupljanje i korištenje osobnih podataka',
    'Ministarstvo gospodarstva i održivog razvoja poštuje privatnost korisnika Internet stranice te prikupljene podatke neće prenositi '
        'trećoj strani. Podaci će se koristiti samo za rješavanje pojedinačnih zahtjeva korisnika za dodatnim uslugama te za prijave, upite i komentare.',
    'Kako koristimo osobne podatke koje prikupljamo',
    'Osobne podatke koristimo kako bi vam: pružili usluge koje zatražite, udovoljili pojedinačnim zahtjevima za određenim uslugama, '
        'omogućili prijavu nadležnim inspekcijskim službama, odgovorili na vaše komentare ili upite, unaprijedili Internet stranicu i/ili '
        'dijagnosticirali eventualne probleme pri korištenju Internet stranice. Vaše ćemo osobne podatke pohraniti samo na razdoblje '
        'potrebno u gore navedene svrhe te ih nakon toga izbrisati.',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < 6; i++)
                      i == 0
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: MinGOTitle(label: 'Privatnost podataka'),
                            )
                          : Padding(
                              padding: i % 2 != 0
                                  ? EdgeInsets.only(left: 20, top: 0, bottom: i != 5 ? 30 : 20)
                                  : const EdgeInsets.only(left: 20),
                              child: Text(
                                dataProtectionPoints.elementAt(i),
                                style: i % 2 == 0
                                    ? const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        height: 2.4,
                                      )
                                    : null,
                              ),
                            ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Image.asset(
                'assets/images/about_page/2.jpg',
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
                                        for (int i = 0; i < 6; i++)
                                          i == 0
                                              ? const Padding(
                                                  padding: EdgeInsets.only(bottom: 24),
                                                  child: MinGOTitle(label: 'Privatnost podataka'),
                                                )
                                              : Padding(
                                                  padding: i % 2 != 0
                                                      ? EdgeInsets.only(left: 20, top: 20, bottom: i != 5 ? 30 : 0)
                                                      : const EdgeInsets.only(left: 20),
                                                  child: Text(
                                                    dataProtectionPoints.elementAt(i),
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
                                )
                              : Image.asset(
                                  'assets/images/about_page/2.jpg',
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
