import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../generated/l10n.dart';
import '../../service/user_service.dart';
import '../../theme/light_theme.dart';
import '../../utils/navigation.dart';
import '../../widgets/pemo_button.dart';
import '../../widgets/pemo_password_field.dart';
import '../../widgets/pemo_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    final intl = S.of(context);
    final UserService userService = UserService(context);
    final welcomeBack = intl.welcome_back.split(' ');

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Palette.primary,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 15,
                    left: 5,
                  ),
                  child: IconButton(
                    onPressed: () => previousScreen(context),
                    icon: const Icon(
                      Icons.chevron_left_outlined,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    top: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        welcomeBack[0],
                        style: textStyle(Colors.white, FontSize.xxl),
                      ),
                      Text(
                        welcomeBack[1],
                        style: textStyle(Colors.white, FontSize.xxl),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Image.asset('assets/images/blob3.png'),
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 30,
                          right: 30,
                          bottom: 10,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              PemoTextField(
                                labelText: intl.email,
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  size: 20,
                                ),
                                textInputType: TextInputType.emailAddress,
                                validator: (String? value) {
                                  if (value == null || value.isEmpty || !isValid(value)) {
                                    return intl.email_invalid;
                                  }
                                  return null;
                                },
                                onChanged: (value) => _email = value,
                              ),
                              const SizedBox(height: 10),
                              PemoPasswordField(
                                onChanged: (value) => _password = value,
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: RichText(
                                  text: TextSpan(
                                    style: boldTextStyle(Palette.primary, FontSize.md),
                                    text: intl.forgotPassword,
                                    recognizer: TapGestureRecognizer()..onTap = () {},
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              PemoButton(
                                backgroundColor: Palette.primary,
                                foregroundColor: Colors.white,
                                onPressed: () {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  userService.handleSignInWithEmailAndPassword(_email!, _password!);
                                },
                                child: Text(
                                  intl.login,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: PemoButton(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      fullWidth: false,
                                      onPressed: () => userService.handleGoogleSignIn(),
                                      child: Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 20,
                                        children: const [
                                          Icon(FontAwesomeIcons.google, size: 20, color: Colors.white),
                                          Text('Google'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: PemoButton(
                                      backgroundColor: Colors.blue.shade800,
                                      foregroundColor: Colors.white,
                                      fullWidth: false,
                                      onPressed: () => userService.handleFacebookSignIn(),
                                      child: Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 20,
                                        children: const [
                                          Icon(FontAwesomeIcons.facebook, size: 20, color: Colors.white),
                                          Text('Facebook'),
                                        ],
                                      ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isValid(String email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\])|(([a-zA-Z\-\d]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }
}
