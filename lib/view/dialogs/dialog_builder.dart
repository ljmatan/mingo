import 'dart:async';

import 'package:flutter/material.dart';

class MinGODialog extends StatefulWidget {
  final List<Widget> children;
  final Color? backgroundColor;

  const MinGODialog({
    super.key,
    required this.children,
    this.backgroundColor,
  });

  @override
  State<MinGODialog> createState() => MinGODialogState();
}

class MinGODialogState extends State<MinGODialog> {
  final _scrollController = ScrollController();

  Timer? _errorMessageTimer;
  final _errorMessageController = StreamController<String?>.broadcast();

  void onError(String? message) {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.ease);
    _errorMessageTimer?.cancel();
    _errorMessageController.add(message);
    _errorMessageTimer = Timer(
      const Duration(seconds: 3),
      () => _errorMessageController.add(null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      child: Center(
        child: ConstrainedBox(
          constraints: MediaQuery.of(context).size.width < 1000
              ? BoxConstraints(minHeight: MediaQuery.of(context).size.height)
              : const BoxConstraints(maxWidth: 400),
          child: Material(
            color: MediaQuery.of(context).size.width < 1000 ? widget.backgroundColor ?? Theme.of(context).primaryColor : Colors.transparent,
            child: SizedBox.expand(
              child: Stack(
                children: [
                  Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.backgroundColor ?? Theme.of(context).primaryColor,
                        borderRadius: MediaQuery.of(context).size.width < 1000 ? null : BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            mainAxisSize: MediaQuery.of(context).size.width < 1000 ? MainAxisSize.max : MainAxisSize.min,
                            mainAxisAlignment:
                                MediaQuery.of(context).size.width < 1000 ? MainAxisAlignment.center : MainAxisAlignment.start,
                            children: [
                              StreamBuilder<String?>(
                                stream: _errorMessageController.stream,
                                builder: (context, message) {
                                  if (message.data == null) return const SizedBox();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 30),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [
                                          BoxShadow(
                                            offset: Offset(0, 4),
                                            blurRadius: 4,
                                            color: Colors.black26,
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Text(
                                          message.data!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 30),
                              ...widget.children,
                              SizedBox(
                                height: MediaQuery.of(context).viewInsets.bottom + 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (MediaQuery.of(context).size.width < 1000)
                    Positioned(
                      top: 10 + MediaQuery.of(context).padding.top,
                      right: 10,
                      child: IconButton(
                        icon: ColorFiltered(
                          colorFilter: const ColorFilter.matrix([-1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0]),
                          child: Icon(
                            Icons.close,
                            color: widget.backgroundColor ?? Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _errorMessageTimer?.cancel();
    _errorMessageController.close();
    super.dispose();
  }
}
