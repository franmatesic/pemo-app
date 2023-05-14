import 'package:flutter/material.dart';
import 'package:pemo/screens/pages/rides_screen.dart';
import 'package:pemo/theme/light_theme.dart';

import '../generated/l10n.dart';
import 'pages/account_screen.dart';
import 'pages/history_screen.dart';
import 'pages/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedPageIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    RidesScreen(),
    HistoryScreen(),
    AccountScreen(),
  ];

  _onNavigationTapped(int index) {
    setState(() => _selectedPageIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final intl = S.of(context);

    return Scaffold(
      body: SafeArea(
        child: _pages.elementAt(_selectedPageIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: intl.home),
          BottomNavigationBarItem(icon: const Icon(Icons.directions_car), label: intl.my_rides),
          BottomNavigationBarItem(icon: const Icon(Icons.history), label: intl.history),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: intl.account),
        ],
        unselectedLabelStyle: textStyle(Palette.black, FontSize.sm),
        selectedLabelStyle: boldTextStyle(Palette.black, FontSize.sm),
        unselectedItemColor: Palette.black,
        currentIndex: _selectedPageIndex,
        showUnselectedLabels: true,
        selectedItemColor: Palette.primary,
        onTap: _onNavigationTapped,
      ),
    );
  }
}
