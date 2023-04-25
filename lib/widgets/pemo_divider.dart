import 'package:flutter/material.dart';
import 'package:pemo/theme/light_theme.dart';

class PemoDivider extends StatelessWidget {
  final Color color;
  final String text;
  final double height;
  final bool fullWidth;

  const PemoDivider({super.key, this.color = Palette.ternary, this.text = '', this.height = 20, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    final hasText = text.isNotEmpty;

    final edgeMargin = fullWidth ? 0.0 : 10.0;
    return hasText
        ? Row(
            children: [
              Expanded(
                child: Divider(
                  indent: edgeMargin,
                  endIndent: 20,
                  color: color,
                  height: height,
                  thickness: 1,
                ),
              ),
              Text(
                text,
                style: textStyle(color, FontSize.sm),
              ),
              Expanded(
                child: Divider(
                  indent: 20,
                  endIndent: edgeMargin,
                  color: color,
                  height: height,
                  thickness: 1,
                ),
              ),
            ],
          )
        : Divider(
            indent: edgeMargin,
            endIndent: edgeMargin,
            color: color,
            height: height,
            thickness: 1,
          );
  }
}
