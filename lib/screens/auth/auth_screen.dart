import 'package:flutter/material.dart';
import 'package:pemo/screens/auth/register_screen.dart';

import '../../generated/l10n.dart';
import '../../main.dart';
import '../../theme/light_theme.dart';
import '../../utils/navigation.dart';
import '../../widgets/pemo_button.dart';
import '../../widgets/pemo_divider.dart';
import 'login_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final intl = S.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Palette.complementary,
            ),
          ),
          Center(
            child: Text(
              appName,
              style: textStyle(Palette.primary, FontSize.xxl),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 30,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      PemoButton(
                        backgroundColor: Palette.primary,
                        foregroundColor: Palette.complementary,
                        onPressed: () => nextScreen(context, const LoginScreen()),
                        child: Text(
                          intl.login,
                        ),
                      ),
                      PemoDivider(
                        color: Palette.primary,
                        text: intl.or,
                        height: 30,
                      ),
                      PemoButton(
                        foregroundColor: Palette.primary,
                        outlined: true,
                        onPressed: () => nextScreen(context, const RegisterScreen()),
                        child: Text(
                          intl.signup,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
