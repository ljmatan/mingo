import 'package:flutter/material.dart';
import 'package:mingo/api/contact.dart';
import 'package:mingo/services/navigator/navigator.dart';
import 'package:mingo/utils/input_validation/text_validators.dart';
import 'package:mingo/view/dialogs/dialog_builder.dart';
import 'package:mingo/view/shared/basic/action_button.dart';
import 'package:mingo/view/shared/basic/text_field.dart';
import 'package:mingo/view/shared/widgets/title/title.dart';

class ContactDialog extends StatefulWidget {
  const ContactDialog({super.key});

  @override
  State<ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<ContactDialog> {
  final _dialogKey = GlobalKey<MinGODialogState>();

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController(),
      _firstNameController = TextEditingController(),
      _lastNameController = TextEditingController(),
      _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MinGODialog(
      key: _dialogKey,
      children: [
        const MinGOTitle(
          label: 'Kontaktirajte nas',
          brightness: Brightness.dark,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Pošaljite nam upit',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MinGOTextField(
                controller: _emailController,
                label: 'Email adresa',
                keyboardType: TextInputType.emailAddress,
                validator: (input) => TextInputValidators.emailValidator(input!),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: MinGOTextField(
                  controller: _firstNameController,
                  label: 'Ime',
                  validator: (input) => TextInputValidators.firstNameValidator(input!),
                ),
              ),
              MinGOTextField(
                controller: _lastNameController,
                label: 'Prezime',
                validator: (input) => TextInputValidators.lastNameValidator(input!),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: MinGOTextField(
                  controller: _messageController,
                  label: 'Vaša poruka',
                  numberOfLines: 4,
                  validator: (input) {
                    if (input!.isEmpty) return 'Molimo unesite vrijednost';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        MinGOActionButton(
          label: 'Pošalji',
          icon: Icons.chevron_right,
          onTap: () async {
            if (_formKey.currentState!.validate()) {
              await ContactApi.sendMessage(
                _emailController.text,
                _firstNameController.text,
                _lastNameController.text,
                _messageController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(AppNavigator.key.currentContext!).showSnackBar(
                const SnackBar(
                  content: Text('Poruka poslana. Kontaktirat ćemo Vas u najkraćem mogućem roku.'),
                  duration: Duration(seconds: 6),
                ),
              );
            }
          },
          onError: (message) {
            _dialogKey.currentState!.onError(message);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
