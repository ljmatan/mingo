import 'package:flutter/material.dart';
import 'package:mingo/api/auth.dart';
import 'package:mingo/utils/input_validation/text_validators.dart';
import 'package:mingo/view/dialogs/dialog_builder.dart';
import 'package:mingo/view/shared/basic/action_button.dart';
import 'package:mingo/view/shared/basic/text_field.dart';
import 'package:mingo/view/shared/widgets/title/title.dart';

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({super.key});

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final _dialogKey = GlobalKey<MinGODialogState>();

  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController(),
      _lastNameController = TextEditingController(),
      _addressController = TextEditingController(),
      _cityController = TextEditingController(),
      _phoneController = TextEditingController(),
      _emailController = TextEditingController(),
      _passwordController = TextEditingController();

  // For testing
  //
  // final _firstNameController = TextEditingController(text: 'prvoprezime'),
  //     _lastNameController = TextEditingController(text: 'prvoprezime'),
  //     _addressController = TextEditingController(text: 'prvoprezime'),
  //     _cityController = TextEditingController(text: 'prvoprezime'),
  //     _phoneController = TextEditingController(text: '0955603626'),
  //     _emailController = TextEditingController(text: 'prvoprezime@email.com'),
  //     _passwordController = TextEditingController(text: 'Password1!');

  @override
  Widget build(BuildContext context) {
    return MinGODialog(
      key: _dialogKey,
      children: [
        const MinGOTitle(
          label: 'Registracija',
          brightness: Brightness.dark,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Kreirajte svoj MINGO profil',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        Form(
          key: _formKey,
          child: Column(
            children: [
              MinGOTextField(
                controller: _firstNameController,
                label: 'Ime',
                validator: (input) => TextInputValidators.firstNameValidator(input!),
              ),
              const SizedBox(height: 16),
              MinGOTextField(
                controller: _lastNameController,
                label: 'Prezime',
                validator: (input) => TextInputValidators.lastNameValidator(input!),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: MinGOTextField(
                  controller: _addressController,
                  label: 'Adresa',
                  validator: (input) => TextInputValidators.streetValidator(input!),
                ),
              ),
              MinGOTextField(
                controller: _cityController,
                label: 'Mjesto',
                validator: (input) => TextInputValidators.postCodeValidator(input!),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: MinGOTextField(
                  controller: _phoneController,
                  label: 'Mobitel / Telefon',
                  validator: (input) => TextInputValidators.phoneNumberValidator(input!),
                  keyboardType: TextInputType.phone,
                ),
              ),
              MinGOTextField(
                controller: _emailController,
                label: 'Email adresa',
                validator: (input) => TextInputValidators.emailValidator(input!),
                keyboardType: TextInputType.emailAddress,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: MinGOTextField(
                  controller: _passwordController,
                  label: 'Lozinka',
                  obscured: true,
                  validator: (input) => TextInputValidators.passwordValidator(input!),
                  keyboardType: TextInputType.visiblePassword,
                ),
              ),
            ],
          ),
        ),
        MinGOActionButton(
          label: 'Registracija',
          icon: Icons.chevron_right,
          onTap: () async {
            if (_formKey.currentState!.validate()) {
              await AuthApi.register(
                _firstNameController.text,
                _lastNameController.text,
                _addressController.text,
                _cityController.text,
                _phoneController.text,
                _emailController.text,
                _emailController.text,
                _passwordController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Molimo potvrdite registraciju putem prethodno navedene email adrese.'),
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
