import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../service/user_service.dart';
import '../../theme/light_theme.dart';
import '../../utils/navigation.dart';
import '../../widgets/pemo_button.dart';
import 'auth/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final intl = S.of(context);
    final userService = UserService(context);
    final user = userService.getSignedInUser();

    String translateRole(String role) {
      return role == 'PASSENGER' ? intl.passenger : intl.driver;
    }

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Spacer(),
                  ClipOval(
                    child: SizedBox.fromSize(
                      size: const Size.fromRadius(80),
                      child: user.image ?? Image.asset('assets/images/user.png'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${user.name!} - ${translateRole(user.role!)}',
                    textAlign: TextAlign.center,
                    style: textStyle(Colors.black, FontSize.lg),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${user.email}\n${user.phoneNumber!}\n${user.gender}\n${user.dateOfBirth}',
                    textAlign: TextAlign.center,
                    style: textStyle(Palette.ternary, FontSize.md),
                  ),
                  const Spacer(),
                  PemoButton(
                    onPressed: () {
                      userService.handleSignOut();
                      nextScreenReplace(context, const AuthScreen());
                    },
                    child: Text(intl.sign_out),
                  ),
                  const SizedBox(height: 10),
                  PemoButton(
                    onPressed: () {
                      userService.handleDeleteUser();
                      nextScreenReplace(context, const AuthScreen());
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    child: const Text("Delete account"),
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
