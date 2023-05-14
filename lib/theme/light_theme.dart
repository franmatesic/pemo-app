import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  return ThemeData(
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
    }),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const MaterialStatePropertyAll<Color>(Palette.primary),
        foregroundColor: const MaterialStatePropertyAll<Color>(Palette.white),
        shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const MaterialStatePropertyAll<Color>(Colors.transparent),
        foregroundColor: const MaterialStatePropertyAll<Color>(Palette.primary),
        shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        side: const MaterialStatePropertyAll(BorderSide(color: Palette.primary)),
      ),
    ),
  );
}

flippedButtonStyle() {
  return ButtonStyle(
    backgroundColor: const MaterialStatePropertyAll<Color>(Colors.white),
    foregroundColor: const MaterialStatePropertyAll<Color>(Palette.primary),
    shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    side: const MaterialStatePropertyAll(BorderSide(color: Palette.primary)),
  );
}

flatButtonStyle() {
  return ButtonStyle(
    backgroundColor: const MaterialStatePropertyAll<Color>(Colors.transparent),
    foregroundColor: const MaterialStatePropertyAll<Color>(Palette.neutral800),
    overlayColor: const MaterialStatePropertyAll<Color>(Palette.neutral100),
    textStyle: MaterialStatePropertyAll(textStyle(Palette.black, FontSize.lg)),
    shape: const MaterialStatePropertyAll(ContinuousRectangleBorder()),
    padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 20, horizontal: 20)),
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

  static const xsm = 10.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const xmd = 20.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class Palette {
  Palette._();

  static const primary = Color(0xFF1976D2);
  static const primary10 = Color(0xDD1976D2);

  static const white = Colors.white;
  static const neutral100 = Color(0xFFe6e6e6);
  static const neutral200 = Color(0xFFcccccc);
  static const neutral300 = Color(0xFFb3b3b3);
  static const neutral400 = Color(0xFF999999);
  static const neutral500 = Color(0xFF808080);
  static const neutral600 = Color(0xFF666666);
  static const neutral700 = Color(0xFF4d4d4d);
  static const neutral800 = Color(0xFF333333);
  static const neutral900 = Color(0xFF1a1a1a);
  static const black = Colors.black;
}

class PemoTransitionBuilder extends PageTransitionsBuilder {
  const PemoTransitionBuilder();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.ease));

    return FadeTransition(
      opacity: animation.drive(tween),
      child: child,
    );
  }
}
