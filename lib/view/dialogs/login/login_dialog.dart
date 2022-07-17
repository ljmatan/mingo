import 'package:flutter/material.dart';
import 'package:mingo/api/auth.dart';
import 'package:mingo/services/navigator/navigator.dart';
import 'package:mingo/view/dialogs/dialog_builder.dart';
import 'package:mingo/view/dialogs/forgot_password/forgot_password_dialog.dart';
import 'package:mingo/view/dialogs/register/register_dialog.dart';
import 'package:mingo/view/dialogs/resend_confirmation/resend_confirmation_dialog.dart';
import 'package:mingo/view/shared/basic/action_button.dart';
import 'package:mingo/view/shared/basic/text_field.dart';
import 'package:mingo/view/shared/widgets/title/title.dart';

class LoginDialog extends StatefulWidget {
  final Function rebuildNavigationBar;

  const LoginDialog({
    super.key,
    required this.rebuildNavigationBar,
  });

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _dialogKey = GlobalKey<MinGODialogState>();

  final _emailController = TextEditingController(), _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MinGODialog(
      key: _dialogKey,
      children: [
        const MinGOTitle(
          label: 'Prijava',
          brightness: Brightness.dark,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Ako već imate profil, prijavite se ovdje',
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
                label: 'Korisničko ime',
                // validator: (input) => TextInputValidators.emailValidator(input!),
                keyboardType: TextInputType.emailAddress,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: MinGOTextField(
                  controller: _passwordController,
                  label: 'Lozinka',
                  obscured: true,
                  // validator: (input) => TextInputValidators.passwordValidator(input!),
                  keyboardType: TextInputType.visiblePassword,
                ),
              ),
            ],
          ),
        ),
        MinGOActionButton(
          label: 'Prijava',
          onTap: () async {
            if (_formKey.currentState!.validate()) {
              await AuthApi.getJwt(_emailController.text, _passwordController.text);
              Navigator.pop(context);
              widget.rebuildNavigationBar();
            }
          },
          onError: (message) {
            _dialogKey.currentState!.onError(message);
          },
        ),
        if (MediaQuery.of(context).size.width < 1000)
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: TextButton(
              child: const Text(
                'Nemate račun? Registrirajte se',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: AppNavigator.key.currentContext!,
                  useSafeArea: false,
                  barrierColor: Colors.transparent,
                  builder: (context) => const RegisterDialog(),
                );
              },
            ),
          ),
        Padding(
          padding:
              MediaQuery.of(context).size.width < 1000 ? const EdgeInsets.only(bottom: 10) : const EdgeInsets.only(top: 20, bottom: 10),
          child: TextButton(
            child: const Text(
              'Zaboravljena lozinka?',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: AppNavigator.key.currentContext!,
                useSafeArea: false,
                barrierColor: Colors.transparent,
                builder: (context) => const ForgotPasswordDialog(),
              );
            },
          ),
        ),
        TextButton(
          child: const Text(
            'Niste primili email potvrdu?',
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.underline,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            showDialog(
              context: AppNavigator.key.currentContext!,
              useSafeArea: false,
              barrierColor: Colors.transparent,
              builder: (context) => const ResendConfirmationDialog(),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
