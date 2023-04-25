import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/light_theme.dart';
import '../../utils/navigation.dart';
import '../main.dart';
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
    initRedirect();
  }

  Future initRedirect() async {
    final authService = context.read<AuthService>();
    Future.delayed(const Duration(milliseconds: 500), () => redirect(authService));
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
    return const Scaffold(
      backgroundColor: Palette.primary,
      body: SafeArea(
        child: Center(
          child: Text(appName, style: TextStyle(fontSize: 64, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
