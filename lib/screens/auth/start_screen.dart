import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../main.dart';
import '../../service/user_service.dart';
import '../../theme/light_theme.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    final intl = S.of(context);
    final UserService userService = UserService(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: Palette.primary),
            child: SafeArea(
              minimum: const EdgeInsets.only(top: 80),
              child: Text(
                appName,
                style: textStyle(Palette.primary, FontSize.xl),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
