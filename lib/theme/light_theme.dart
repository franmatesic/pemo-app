import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  return ThemeData(
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
    }),
    filledButtonTheme: FilledButtonThemeData(style: defaultButtonStyle()),
    outlinedButtonTheme: OutlinedButtonThemeData(style: defaultButtonStyle()),
  );
}

defaultButtonStyle() {
  return ButtonStyle(
    shape:
        MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
  );
}

textStyle(Color color, double fontSize) {
  return TextStyle(
    color: color,
    fontSize: fontSize,
  );
}

boldTextStyle(Color color, double fontSize) {
  return TextStyle(
    color: color,
    fontSize: fontSize,
    fontWeight: FontWeight.bold,
  );
}

class FontSize {
  FontSize._();

  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class Palette {
  Palette._();

  static const primary = Color(0xFF1976D2);
  static const complementary = Colors.white;
  static const secondary = Colors.orange;
  static const background = Colors.white;
  static const ternary = Colors.black45;

  static const black = Colors.black;
}

class PemoTransitionBuilder extends PageTransitionsBuilder {
  const PemoTransitionBuilder();

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.ease));

    return FadeTransition(
      opacity: animation.drive(tween),
      child: child,
    );
  }
}
