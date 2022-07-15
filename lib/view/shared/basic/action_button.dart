import 'package:flutter/material.dart';
import 'package:mingo/view/dialogs/content_blocking/content_blocking.dart';
import 'package:mingo/view/theme.dart';

class MinGOActionButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Function? onTap;
  final Function(String)? onError;
  final bool minWidth, gradientBorder, contentBlocking, underlined;
  final double? iconSize;

  const MinGOActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.onError,
    this.minWidth = false,
    this.gradientBorder = false,
    this.contentBlocking = true,
    this.underlined = false,
    this.iconSize,
  });

  @override
  State<MinGOActionButton> createState() => _MinGOActionButtonState();
}

class _MinGOActionButtonState extends State<MinGOActionButton> {
  bool _running = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.w600),
      child: InkWell(
        child: widget.underlined
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: MediaQuery.of(context).size.width <= 400 ? 14 : 16,
                      ),
                    ),
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      size: widget.iconSize,
                    ),
                  ],
                ),
              )
            : widget.gradientBorder
                ? AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: MinGOTheme.buttonGradient,
                    ),
                    child: _running
                        ? const SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(4),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: SizedBox(
                                height: 40,
                                child: Padding(
                                  padding: MediaQuery.of(context).size.width < 1100
                                      ? const EdgeInsets.symmetric(horizontal: 12)
                                      : MediaQuery.of(context).size.width < 1300
                                          ? const EdgeInsets.symmetric(horizontal: 16)
                                          : const EdgeInsets.symmetric(horizontal: 30),
                                  child: widget.icon != null
                                      ? Row(
                                          mainAxisSize: widget.minWidth ? MainAxisSize.min : MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              widget.label,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                                fontSize: MediaQuery.of(context).size.width <= 300
                                                    ? 12
                                                    : MediaQuery.of(context).size.width < 500
                                                        ? 14
                                                        : null,
                                              ),
                                            ),
                                            if (widget.minWidth) const SizedBox(width: 60),
                                            Icon(
                                              widget.icon,
                                              size: widget.iconSize,
                                            ),
                                          ],
                                        )
                                      : Center(
                                          child: Text(
                                            widget.label,
                                            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: MinGOTheme.buttonGradient,
                      border: null,
                    ),
                    child: _running
                        ? const SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 48,
                            child: Padding(
                              padding: MediaQuery.of(context).size.width < 1100
                                  ? const EdgeInsets.symmetric(horizontal: 12)
                                  : MediaQuery.of(context).size.width < 1300
                                      ? const EdgeInsets.symmetric(horizontal: 16)
                                      : const EdgeInsets.symmetric(horizontal: 30),
                              child: widget.icon != null
                                  ? Row(
                                      mainAxisSize: widget.minWidth ? MainAxisSize.min : MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          widget.label,
                                          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: MediaQuery.of(context).size.width <= 300
                                                    ? 12
                                                    : MediaQuery.of(context).size.width < 500
                                                        ? 13
                                                        : null,
                                              ),
                                        ),
                                        if (widget.minWidth) const SizedBox(width: 60),
                                        Icon(
                                          widget.icon,
                                          size: widget.iconSize,
                                          color: Colors.white,
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Text(
                                        widget.label,
                                        style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                            ),
                          ),
                  ),
        onTap: widget.onTap != null
            ? () async {
                setState(() => _running = true);
                try {
                  FocusScope.of(context).unfocus();
                  if (widget.contentBlocking) {
                    showDialog(
                      context: context,
                      barrierColor: Colors.transparent,
                      builder: (context) => const ContentBlockingDialog(),
                    );
                  }
                  if (widget.contentBlocking) {
                    await widget.onTap!();
                    Navigator.pop(context);
                  } else {
                    widget.onTap!();
                  }
                  setState(() => _running = false);
                } catch (e) {
                  if (widget.contentBlocking) Navigator.pop(context);
                  if (widget.onError != null) await widget.onError!('$e');
                  if (mounted) setState(() => _running = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$e'),
                    ),
                  );
                }
              }
            : null,
      ),
    );
  }
}
