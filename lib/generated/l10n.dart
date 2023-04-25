// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `PEMO`
  String get app_name {
    return Intl.message(
      'PEMO',
      name: 'app_name',
      desc: '',
      args: [],
    );
  }

  /// `Log in`
  String get login {
    return Intl.message(
      'Log in',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get signup {
    return Intl.message(
      'Sign up',
      name: 'signup',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with Google`
  String get sign_google {
    return Intl.message(
      'Sign in with Google',
      name: 'sign_google',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with Facebook`
  String get sign_facebook {
    return Intl.message(
      'Sign in with Facebook',
      name: 'sign_facebook',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid email`
  String get email_invalid {
    return Intl.message(
      'Enter a valid email',
      name: 'email_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Enter a password`
  String get password_missing {
    return Intl.message(
      'Enter a password',
      name: 'password_missing',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 8 characters long`
  String get password_invalid {
    return Intl.message(
      'Password must be at least 8 characters long',
      name: 'password_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Account already exists with different provider`
  String get provider_error {
    return Intl.message(
      'Account already exists with different provider',
      name: 'provider_error',
      desc: '',
      args: [],
    );
  }

  /// `Unexpected error occurred`
  String get unexpected_error {
    return Intl.message(
      'Unexpected error occurred',
      name: 'unexpected_error',
      desc: '',
      args: [],
    );
  }

  /// `User not found`
  String get user_not_found {
    return Intl.message(
      'User not found',
      name: 'user_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect password`
  String get incorrect_password {
    return Intl.message(
      'Incorrect password',
      name: 'incorrect_password',
      desc: '',
      args: [],
    );
  }

  /// `The password provided is too weak`
  String get weak_password {
    return Intl.message(
      'The password provided is too weak',
      name: 'weak_password',
      desc: '',
      args: [],
    );
  }

  /// `Email already is use`
  String get email_in_use {
    return Intl.message(
      'Email already is use',
      name: 'email_in_use',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `By clicking Sign Up, you agree to our `
  String get tos_1 {
    return Intl.message(
      'By clicking Sign Up, you agree to our ',
      name: 'tos_1',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service`
  String get tos_2 {
    return Intl.message(
      'Terms of Service',
      name: 'tos_2',
      desc: '',
      args: [],
    );
  }

  /// ` and that you have read our `
  String get tos_3 {
    return Intl.message(
      ' and that you have read our ',
      name: 'tos_3',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get tos_4 {
    return Intl.message(
      'Privacy Policy',
      name: 'tos_4',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Enter a name`
  String get name_missing {
    return Intl.message(
      'Enter a name',
      name: 'name_missing',
      desc: '',
      args: [],
    );
  }

  /// `Name must be at least 3 characters long`
  String get name_invalid {
    return Intl.message(
      'Name must be at least 3 characters long',
      name: 'name_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Phone number`
  String get phone {
    return Intl.message(
      'Phone number',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid phone number`
  String get phone_invalid {
    return Intl.message(
      'Enter a valid phone number',
      name: 'phone_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get create_account {
    return Intl.message(
      'Create Account',
      name: 'create_account',
      desc: '',
      args: [],
    );
  }

  /// `Welcome Back`
  String get welcome_back {
    return Intl.message(
      'Welcome Back',
      name: 'welcome_back',
      desc: '',
      args: [],
    );
  }

  /// `OR`
  String get or {
    return Intl.message(
      'OR',
      name: 'or',
      desc: '',
      args: [],
    );
  }

  /// `Check your internet connection`
  String get internet_error {
    return Intl.message(
      'Check your internet connection',
      name: 'internet_error',
      desc: '',
      args: [],
    );
  }

  /// `Driver`
  String get driver {
    return Intl.message(
      'Driver',
      name: 'driver',
      desc: '',
      args: [],
    );
  }

  /// `Passenger`
  String get passenger {
    return Intl.message(
      'Passenger',
      name: 'passenger',
      desc: '',
      args: [],
    );
  }

  /// `Choose your role`
  String get choose_role {
    return Intl.message(
      'Choose your role',
      name: 'choose_role',
      desc: '',
      args: [],
    );
  }

  /// `Role`
  String get role {
    return Intl.message(
      'Role',
      name: 'role',
      desc: '',
      args: [],
    );
  }

  /// `Driver`
  String get driver_description {
    return Intl.message(
      'Driver',
      name: 'driver_description',
      desc: '',
      args: [],
    );
  }

  /// `Passenger`
  String get passenger_description {
    return Intl.message(
      'Passenger',
      name: 'passenger_description',
      desc: '',
      args: [],
    );
  }

  /// `Choose`
  String get choose {
    return Intl.message(
      'Choose',
      name: 'choose',
      desc: '',
      args: [],
    );
  }

  /// `Sign out`
  String get sign_out {
    return Intl.message(
      'Sign out',
      name: 'sign_out',
      desc: '',
      args: [],
    );
  }

  /// `Finish your registration`
  String get finish_account {
    return Intl.message(
      'Finish your registration',
      name: 'finish_account',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message(
      'Skip',
      name: 'skip',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Provide additional information`
  String get input_info {
    return Intl.message(
      'Provide additional information',
      name: 'input_info',
      desc: '',
      args: [],
    );
  }

  /// `Profile picture`
  String get picture {
    return Intl.message(
      'Profile picture',
      name: 'picture',
      desc: '',
      args: [],
    );
  }

  /// `(Optional)`
  String get optional {
    return Intl.message(
      '(Optional)',
      name: 'optional',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  /// `Male`
  String get male {
    return Intl.message(
      'Male',
      name: 'male',
      desc: '',
      args: [],
    );
  }

  /// `Female`
  String get female {
    return Intl.message(
      'Female',
      name: 'female',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get other {
    return Intl.message(
      'Other',
      name: 'other',
      desc: '',
      args: [],
    );
  }

  /// `Date of birth`
  String get date_of_birth {
    return Intl.message(
      'Date of birth',
      name: 'date_of_birth',
      desc: '',
      args: [],
    );
  }

  /// `Your name`
  String get choose_name {
    return Intl.message(
      'Your name',
      name: 'choose_name',
      desc: '',
      args: [],
    );
  }

  /// `Your gender`
  String get choose_gender {
    return Intl.message(
      'Your gender',
      name: 'choose_gender',
      desc: '',
      args: [],
    );
  }

  /// `Enter a gender`
  String get gender_missing {
    return Intl.message(
      'Enter a gender',
      name: 'gender_missing',
      desc: '',
      args: [],
    );
  }

  /// `Choose date`
  String get choose_date {
    return Intl.message(
      'Choose date',
      name: 'choose_date',
      desc: '',
      args: [],
    );
  }

  /// `Enter a date`
  String get date_missing {
    return Intl.message(
      'Enter a date',
      name: 'date_missing',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'hr', countryCode: 'HR'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
