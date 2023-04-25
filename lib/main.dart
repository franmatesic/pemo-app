import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pemo/service/auth_service.dart';
import 'package:pemo/service/internet_service.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';
import 'screens/splash_screen.dart';
import 'theme/light_theme.dart';

const String appName = 'PEMO';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PemoApp());
}

class PemoApp extends StatelessWidget {
  const PemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => AuthService()), ChangeNotifierProvider(create: (context) => InternetService())],
      child: MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: S.delegate.supportedLocales,
        theme: buildLightTheme(),
        title: appName,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
