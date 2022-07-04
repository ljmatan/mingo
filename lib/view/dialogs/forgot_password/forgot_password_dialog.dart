import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mingo/api/auth.dart';
import 'package:mingo/utils/input_validation/text_validators.dart';
import 'package:mingo/view/dialogs/dialog_builder.dart';
import 'package:mingo/view/shared/basic/action_button.dart';
import 'package:mingo/view/shared/basic/text_field.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _dialogKey = GlobalKey<MinGODialogState>();

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).appBarTheme.systemOverlayStyle!.copyWith(
            statusBarColor: Colors.white,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
      child: MinGODialog(
        key: _dialogKey,
        backgroundColor: Colors.white,
        children: [
          const Text(
            'Resetiranje lozinke',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Form(
              key: _formKey,
              child: MinGOTextField(
                controller: _emailController,
                label: 'Korisničko ime',
                bordered: true,
                keyboardType: TextInputType.emailAddress,
                validator: (input) => TextInputValidators.emailValidator(input!),
              ),
            ),
          ),
          MinGOActionButton(
            label: 'Resetiraj lozinku',
            icon: Icons.chevron_right,
            onTap: () async {
              if (_formKey.currentState!.validate()) {
                await AuthApi.sendPasswordResetEmail(_emailController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email sa uputama za resetiranje lozinke je poslan na Vaš mail.'),
                  ),
                );
              }
            },
            onError: (message) {
              _dialogKey.currentState!.onError(message);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
