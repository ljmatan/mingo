import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MinGOTitle extends StatelessWidget {
  final String label;
  final String? subtitle, iconFilename;
  final Brightness brightness;
  final Color lineColor;

  const MinGOTitle({
    super.key,
    required this.label,
    this.subtitle,
    this.iconFilename,
    this.brightness = Brightness.light,
    this.lineColor = const Color(0xff16FFBD),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Positioned(
            bottom: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: lineColor,
              ),
              child: SizedBox(width: label.split('\n').last.length * 6, height: 6),
            ),
          ),
          if (iconFilename != null)
            Positioned(
              left: 2,
              bottom: 20,
              child: SvgPicture.asset(
                'assets/' + iconFilename!,
                width: MediaQuery.of(context).size.width < 1000 ? 20 : 24,
                color: brightness == Brightness.dark ? Colors.white : Theme.of(context).primaryColor,
              ),
            ),
          Padding(
            padding: iconFilename == null ? const EdgeInsets.symmetric(horizontal: 20) : const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                if (subtitle != null)
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: brightness == Brightness.light ? const Color(0xff949494) : Colors.white,
                      fontSize: 12,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: brightness == Brightness.light ? Theme.of(context).primaryColor : Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
