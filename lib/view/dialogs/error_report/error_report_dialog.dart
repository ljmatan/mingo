import 'package:flutter/material.dart';
import 'package:mingo/api/contact.dart';
import 'package:mingo/data/mingo.dart';
import 'package:mingo/utils/input_validation/text_validators.dart';
import 'package:mingo/view/dialogs/dialog_builder.dart';
import 'package:mingo/view/shared/basic/action_button.dart';
import 'package:mingo/view/shared/basic/text_field.dart';
import 'package:mingo/view/shared/widgets/title/title.dart';

class ErrorReportDialog extends StatefulWidget {
  const ErrorReportDialog({super.key});

  @override
  State<ErrorReportDialog> createState() => _ErrorReportDialogState();
}

class _ErrorReportDialogState extends State<ErrorReportDialog> {
  final _dialogKey = GlobalKey<MinGODialogState>();

  final _formKey = GlobalKey<FormState>();

  int? _providerId, _stationId;

  final _reasonController = TextEditingController(), _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MinGODialog(
      key: _dialogKey,
      children: [
        const MinGOTitle(
          label: 'Prijava greške',
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
              DropdownButtonFormField<int>(
                value: _providerId,
                elevation: 0,
                isExpanded: true,
                hint: const Text('Obveznik'),
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
                  for (var provider in MinGOData.instance.providers)
                    DropdownMenuItem(
                      child: Text(provider.name),
                      value: provider.id,
                    ),
                ],
                validator: (value) {
                  if (_providerId == null) return 'Molimo unesite vrijednost.';
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _providerId = value;
                    _stationId = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _stationId,
                elevation: 0,
                isExpanded: true,
                hint: const Text('Postaja'),
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
                  for (var station in MinGOData.instance.stations.where((e) => e.providerId == _providerId))
                    DropdownMenuItem(
                      child: Text(station.name),
                      value: station.id,
                    ),
                ],
                validator: (value) {
                  if (_stationId == null) return 'Molimo unesite vrijednost.';
                  return null;
                },
                onChanged: (value) => _stationId = value,
              ),
              const SizedBox(height: 16),
              MinGOTextField(
                controller: _reasonController,
                label: 'Razlog',
                validator: (input) => TextInputValidators.firstNameValidator(input!),
              ),
              const SizedBox(height: 16),
              MinGOTextField(
                controller: _commentController,
                label: 'Napomena',
                validator: (input) => TextInputValidators.lastNameValidator(input!),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        MinGOActionButton(
          label: 'Pošalji',
          icon: Icons.chevron_right,
          onTap: () async {
            if (_formKey.currentState!.validate()) {
              await ContactApi.reportError(
                _stationId!,
                _reasonController.text,
                _commentController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prijava uspješno poslana.'),
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
    _reasonController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}
