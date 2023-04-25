import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pemo/model/pemo_role.dart';
import 'package:pemo/screens/home_screen.dart';
import 'package:pemo/theme/light_theme.dart';
import 'package:pemo/utils/navigation.dart';
import 'package:pemo/widgets/pemo_date_picker.dart';
import 'package:pemo/widgets/pemo_phone_number_field.dart';

import '../../generated/l10n.dart';
import '../../service/user_service.dart';
import '../../widgets/pemo_button.dart';
import '../../widgets/pemo_text_field.dart';

class AdditionalInfoScreen extends StatefulWidget {
  const AdditionalInfoScreen({Key? key}) : super(key: key);

  @override
  State<AdditionalInfoScreen> createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(debugLabel: 'name'),
    GlobalKey<FormState>(debugLabel: 'gender'),
    GlobalKey<FormState>(debugLabel: 'dateOfBirth'),
    GlobalKey<FormState>(debugLabel: 'phoneNumber')
  ];

  int _currentStep = 0;
  bool _passengerChosen = true;
  String? _name;
  String? _gender;
  String? _dateOfBirth;
  String? _phoneNumber;
  File? _imageFile;

  stepSelected(int step) {
    setState(() => _currentStep = step);
  }

  nextStep(UserService userService) {
    if (_currentStep > 0 && !_formKeys[_currentStep - 1].currentState!.validate()) {
      return;
    }
    if (_currentStep == 4) {
      userService.handleAddUserRole(_passengerChosen ? PemoRole.passenger : PemoRole.driver);
      userService.handleAdditionalUserData(_name!, _gender!, _dateOfBirth!, _phoneNumber!, null);
      nextScreenReplace(context, const HomeScreen());
    }
    _currentStep < 4 ? setState(() => _currentStep += 1) : null;
  }

  previousStep() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  getStepState(int step) {
    return _currentStep == step
        ? StepState.editing
        : _currentStep > step
            ? StepState.complete
            : StepState.indexed;
  }

  @override
  Widget build(BuildContext context) {
    final intl = S.of(context);
    final UserService userService = UserService(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 20),
          child: Stack(
            children: [
              Stepper(
                type: StepperType.horizontal,
                currentStep: _currentStep,
                controlsBuilder: (context, details) {
                  return Container();
                },
                physics: const ScrollPhysics(),
                steps: [
                  Step(
                    title: const Text(""),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          intl.choose_role,
                          style: boldTextStyle(Palette.primary, FontSize.lg),
                        ),
                        const SizedBox(height: 100),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PemoButton(
                              fullWidth: false,
                              backgroundColor: Palette.secondary,
                              foregroundColor: Palette.primary,
                              width: 150,
                              height: 150,
                              outlined: !_passengerChosen,
                              onPressed: () {
                                setState(() {
                                  _passengerChosen = true;
                                });
                              },
                              child: Text(
                                intl.passenger,
                                style: boldTextStyle(Palette.primary, FontSize.lg),
                              ),
                            ),
                            PemoButton(
                              fullWidth: false,
                              backgroundColor: Palette.secondary,
                              foregroundColor: Palette.primary,
                              width: 150,
                              height: 150,
                              outlined: _passengerChosen,
                              onPressed: () {
                                setState(() {
                                  _passengerChosen = false;
                                });
                              },
                              child: Text(
                                intl.driver,
                                style: boldTextStyle(Palette.primary, FontSize.lg),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Text(
                          _passengerChosen ? intl.passenger_description : intl.driver_description,
                          style: textStyle(
                            Palette.primary,
                            FontSize.lg,
                          ),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                    state: getStepState(0),
                  ),
                  Step(
                    title: const Text(""),
                    content: Column(
                      children: [
                        Text(
                          intl.choose_name,
                          style: boldTextStyle(Palette.primary, FontSize.lg),
                        ),
                        const SizedBox(height: 100),
                        Form(
                          key: _formKeys[0],
                          child: PemoTextField(
                            labelText: intl.name,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return intl.name_missing;
                              }
                              if (value.length < 3) {
                                return intl.name_invalid;
                              }
                              return null;
                            },
                            onChanged: (value) => _name = value,
                          ),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                    state: getStepState(1),
                  ),
                  Step(
                    title: const Text(""),
                    content: Column(
                      children: [
                        Text(
                          intl.choose_gender,
                          style: boldTextStyle(Palette.primary, FontSize.lg),
                        ),
                        const SizedBox(height: 40),
                        PemoButton(
                          backgroundColor: Palette.secondary,
                          foregroundColor: Palette.primary,
                          outlined: _gender != 'MALE',
                          onPressed: () {
                            setState(() => _gender = _gender == 'MALE' ? null : 'MALE');
                            _formKeys[1].currentState?.reset();
                          },
                          child: Text(
                            intl.male,
                            style: boldTextStyle(Palette.primary, FontSize.md),
                          ),
                        ),
                        const SizedBox(height: 10),
                        PemoButton(
                          backgroundColor: Palette.secondary,
                          foregroundColor: Palette.primary,
                          outlined: _gender != 'FEMALE',
                          onPressed: () {
                            setState(() => _gender = _gender == 'FEMALE' ? null : 'FEMALE');
                            _formKeys[1].currentState?.reset();
                          },
                          child: Text(
                            intl.female,
                            style: boldTextStyle(Palette.primary, FontSize.md),
                          ),
                        ),
                        const SizedBox(height: 10),
                        PemoButton(
                          backgroundColor: Palette.secondary,
                          foregroundColor: Palette.primary,
                          outlined: _gender == null || _gender == 'MALE' || _gender == 'FEMALE',
                          onPressed: () {
                            setState(() => _gender = _gender == 'OTHER' ? null : 'OTHER');
                          },
                          child: Text(
                            intl.other,
                            style: boldTextStyle(Palette.primary, FontSize.md),
                          ),
                        ),
                        Form(
                          key: _formKeys[1],
                          child: PemoTextField(
                            enabled: _gender != null && _gender != 'MALE' && _gender != 'FEMALE',
                            labelText: intl.gender,
                            validator: (String? value) {
                              if (_gender == null || _gender == 'OTHER' || _gender!.isEmpty) {
                                return intl.gender_missing;
                              }
                              return null;
                            },
                            onChanged: (value) => _gender = value,
                          ),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                    state: getStepState(2),
                  ),
                  Step(
                    title: const Text(""),
                    content: Column(
                      children: [
                        Text(
                          intl.date_of_birth,
                          style: boldTextStyle(Palette.primary, FontSize.lg),
                        ),
                        const SizedBox(height: 100),
                        Form(
                          key: _formKeys[2],
                          child: PemoDatePicker(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return intl.date_missing;
                              }
                              return null;
                            },
                            onChanged: (value) => _dateOfBirth = value,
                          ),
                        )
                      ],
                    ),
                    isActive: _currentStep >= 0,
                    state: getStepState(3),
                  ),
                  Step(
                    title: const Text(""),
                    content: Column(
                      children: [
                        Text(
                          intl.phone,
                          style: boldTextStyle(Palette.primary, FontSize.lg),
                        ),
                        const SizedBox(height: 100),
                        Form(
                          key: _formKeys[3],
                          child: PemoPhoneNumberField(
                            onChanged: (value) => _phoneNumber = value.phoneNumber,
                          ),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                    state: getStepState(4),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _currentStep == 0
                            ? const SizedBox()
                            : PemoButton(
                                fullWidth: false,
                                onPressed: () {
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  previousStep();
                                },
                                child: Text(intl.back),
                              ),
                        PemoButton(
                          fullWidth: false,
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            nextStep(userService);
                          },
                          child: Text(_currentStep == 4 ? intl.save : intl.next),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
