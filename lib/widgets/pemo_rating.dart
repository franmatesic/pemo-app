import 'package:flutter/material.dart';

import '../theme/light_theme.dart';

class PemoRating extends StatelessWidget {
  final double rating;
  final Color color;

  const PemoRating(this.rating, {Key? key, this.color = Palette.primary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
              rating >= i
                  ? Icons.star
                  : rating >= i - 0.5
                      ? Icons.star_half
                      : Icons.star_border,
              color: color)
      ],
    );
  }
}
