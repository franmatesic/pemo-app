import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:provider/provider.dart';

import '../../theme/light_theme.dart';
import '../../utils/navigation.dart';
import '../service/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initLocale();
    initRedirect();
  }

  Future initLocale() async {
    Intl.systemLocale = await findSystemLocale();
  }

  Future initRedirect() async {
    final authService = context.read<AuthService>();
    Future.delayed(const Duration(milliseconds: 800), () => redirect(authService));
  }

  Future redirect(AuthService authService) async {
    final redirectInfo = await authService.getRedirect();
    if (redirectInfo.left) {
      nextScreenReplace(context, redirectInfo.right);
    } else {
      nextScreen(context, redirectInfo.right);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Image.asset('assets/images/logo.png'),
          ),
        ),
      ),
    );
  }
}
