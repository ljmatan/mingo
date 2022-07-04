import 'package:flutter/material.dart';

class ContentBlockingDialog extends StatelessWidget {
  const ContentBlockingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: GestureDetector(
        child: const SizedBox.expand(),
        onTap: () {
          // User input blocked
        },
      ),
      onWillPop: () async => false,
    );
  }
}
