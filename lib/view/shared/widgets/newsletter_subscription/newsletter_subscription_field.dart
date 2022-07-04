import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mingo/api/email_subscription.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/utils/input_validation/text_validators.dart';
import 'package:mingo/view/routes/main_route/pages/dashboard/elements/search_field/search_field.dart';
import 'package:mingo/view/shared/basic/text_field.dart';

class _InputFields extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController, firstNameController, lastNameController;

  const _InputFields({
    required this.formKey,
    required this.emailController,
    required this.firstNameController,
    required this.lastNameController,
  });

  @override
  State<_InputFields> createState() => _InputFieldsState();
}

class _InputFieldsState extends State<_InputFields> {
  String? _fuelType, _county;

  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MinGOTextField(
              controller: widget.emailController,
              label: 'Email',
              validator: (input) => TextInputValidators.emailValidator(input!),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: MinGOTextField(
                  controller: widget.firstNameController,
                  label: 'Ime',
                  validator: (input) => TextInputValidators.firstNameValidator(input!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MinGOTextField(
                  controller: widget.lastNameController,
                  label: 'Prezime',
                  validator: (input) => TextInputValidators.lastNameValidator(input!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  elevation: 0,
                  isExpanded: true,
                  hint: const Text('Vrsta goriva'),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  items: [
                    for (int i = 0; i < DashboardPageSearchField.fuelKinds.length; i++)
                      DropdownMenuItem(
                        child: Text(DashboardPageSearchField.fuelKinds.elementAt(i)),
                        value: DashboardPageSearchField.fuelKinds.elementAt(i),
                      ),
                  ],
                  validator: (value) {
                    if (value == null) return 'Molimo unesite vrijednost.';
                    return null;
                  },
                  onChanged: (value) => _fuelType = value,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  elevation: 0,
                  isExpanded: true,
                  hint: const Text('Županija'),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  items: [
                    for (var county in MinGOData.instance.counties)
                      DropdownMenuItem(
                        child: Text(county.name),
                        value: county.name,
                      ),
                  ],
                  validator: (value) {
                    if (value == null) return 'Molimo unesite vrijednost.';
                    return null;
                  },
                  onChanged: (value) => _county = value,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: StatefulBuilder(
              builder: (context, setState) {
                return InkWell(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: _sending
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'Šalji mi cijene goriva',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                  ),
                  onTap: () async {
                    if (widget.formKey.currentState!.validate()) {
                      setState(() => _sending = true);
                      try {
                        await EmailSubscriptionApi.addUser(
                          widget.emailController.text,
                          widget.firstNameController.text,
                          widget.lastNameController.text,
                          _fuelType!,
                          _county!,
                        );
                        setState(() => _sending = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Molimo potvrdite pretplatu putem svoje email adrese.'),
                          ),
                        );
                      } catch (e) {
                        setState(() => _sending = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$e'),
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class NewsletterSubscriptionField extends StatefulWidget {
  const NewsletterSubscriptionField({super.key});

  @override
  State<NewsletterSubscriptionField> createState() => _NewsletterSubscriptionFieldState();
}

class _NewsletterSubscriptionFieldState extends State<NewsletterSubscriptionField> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController(),
      _firstNameController = TextEditingController(),
      _lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xff16FFBD),
      ),
      child: MediaQuery.of(context).size.width < 1000
          ? Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/vectors/newsletter_subscription/bg.svg',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                  child: Column(
                    children: [
                      const Text(
                        'Primajte cijene\ne-mailom',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 32,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 20),
                        child: Text(
                          'Želite primati obavijesti putem e-maila o promijeni cijena goriva? Ništa lakše! Popunite ova polja svojim'
                          ' podacima i uskoro ćete početi primati cijene goriva.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      _InputFields(
                        formKey: _formKey,
                        emailController: _emailController,
                        firstNameController: _firstNameController,
                        lastNameController: _lastNameController,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                Positioned(
                  left: MediaQuery.of(context).size.width / 4,
                  bottom: 0,
                  child: SvgPicture.asset(
                    'assets/vectors/newsletter_subscription/bg.svg',
                    height: 260,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 6, 40, MediaQuery.of(context).size.width / 6, 33),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Primajte cijene\ne-mailom',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 32,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 16),
                                  child: Text(
                                    'Želite primati obavijesti putem e-maila o promijeni cijena goriva? Ništa lakše! Popunite ova polja svojim'
                                    ' podacima i uskoro ćete početi primati cijene goriva.',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 50),
                          Expanded(
                            child: _InputFields(
                              formKey: _formKey,
                              emailController: _emailController,
                              firstNameController: _firstNameController,
                              lastNameController: _lastNameController,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
