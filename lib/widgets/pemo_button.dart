import 'package:flutter/material.dart';
import 'package:pemo/theme/light_theme.dart';

class PemoButton extends StatelessWidget {
  final Widget child;
  final bool fullWidth;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool outlined;
  final Function() onPressed;

  const PemoButton(
      {super.key,
      required this.onPressed,
      required this.child,
      this.fullWidth = true,
      this.width = 100,
      this.height = 45,
      this.backgroundColor = Palette.primary,
      this.foregroundColor = Palette.white,
      this.outlined = false});

  @override
  Widget build(BuildContext context) {
    final actualWidth = fullWidth ? double.infinity : width;
    final style = ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(outlined ? Colors.transparent : backgroundColor),
      foregroundColor: MaterialStatePropertyAll(foregroundColor),
      minimumSize: MaterialStatePropertyAll(Size(actualWidth, height)),
      side: MaterialStatePropertyAll(
        BorderSide(
          color: outlined ? foregroundColor : Colors.transparent,
        ),
      ),
    );

    return outlined
        ? OutlinedButton(
            style: style,
            onPressed: onPressed,
            child: child,
          )
        : FilledButton(
            style: style,
            onPressed: onPressed,
            child: child,
          );
  }
}
