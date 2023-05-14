import 'package:flutter/material.dart';
import 'package:pemo/model/pemo_vehicle.dart';
import 'package:pemo/repository/vehicle_repository.dart';
import 'package:pemo/screens/auth/auth_screen.dart';
import 'package:pemo/utils/dialogs.dart';
import 'package:pemo/widgets/pemo_divider.dart';
import 'package:uuid/uuid.dart';

import '../../generated/l10n.dart';
import '../../model/enums.dart';
import '../../repository/user_repository.dart';
import '../../service/user_service.dart';
import '../../theme/light_theme.dart';
import '../../utils/navigation.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final userRepository = UserRepository();
  final vehicleRepository = VehicleRepository();

  String? _brand;
  String? _model;
  String? _color;
  int _maxPassengers = 3;

  @override
  Widget build(BuildContext context) {
    final intl = S.of(context);
    final userService = UserService(context);
    final user = userService.getSignedInUser();

    String translateRole(String role) {
      return role == PemoRole.passenger ? intl.passenger : intl.driver;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: SizedBox.fromSize(
                  size: const Size.fromRadius(40),
                  child: user.image ?? Image.asset('assets/images/user.png'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(user.name!, style: boldTextStyle(Palette.black, FontSize.lg)),
                        Card(
                          color: Palette.primary,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                            child: Text(
                              translateRole(user.role!),
                              style: textStyle(Palette.white, FontSize.xmd),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      user.email!,
                      style: textStyle(Palette.black, FontSize.md),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PemoDivider(
          thickness: 5,
          color: Palette.neutral200,
          fullWidth: true,
        ),
        FilledButton(
          style: flatButtonStyle(),
          onPressed: () {},
          child: Row(
            children: [
              const Icon(Icons.person),
              const SizedBox(width: 25),
              Text(intl.account),
            ],
          ),
        ),
        FilledButton(
          style: flatButtonStyle(),
          onPressed: () {},
          child: Row(
            children: [
              const Icon(Icons.settings),
              const SizedBox(width: 25),
              Text(intl.settings),
            ],
          ),
        ),
        if (user.role == PemoRole.passenger) ...[
          FilledButton(
            style: flatButtonStyle(),
            onPressed: () => showAlertDialog(context, intl.become_driver, intl.sure, () async {
              await userService.handleAddUserRole(PemoRole.driver);
              Navigator.of(context).pop();
            }),
            child: Row(
              children: [
                const Icon(Icons.local_taxi),
                const SizedBox(width: 25),
                Text(intl.become_driver),
              ],
            ),
          ),
        ],
        if (user.role == PemoRole.driver) ...[
          FilledButton(
            style: flatButtonStyle(),
            onPressed: () async {
              showModalBottomSheet(
                clipBehavior: Clip.antiAlias,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return SizedBox(
                        height: 800,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(intl.brand),
                                TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return intl.brand_missing;
                                    }
                                    return null;
                                  },
                                  onChanged: (value) => _brand = value,
                                ),
                                const SizedBox(height: 10),
                                Text(intl.model),
                                TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return intl.model_missing;
                                    }
                                    return null;
                                  },
                                  onChanged: (value) => _model = value,
                                ),
                                const SizedBox(height: 10),
                                Text(intl.color),
                                TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return intl.color_missing;
                                    }
                                    return null;
                                  },
                                  onChanged: (value) => _color = value,
                                ),
                                const SizedBox(height: 10),
                                Text(intl.max_passengers),
                                DropdownButtonFormField(
                                  items: List<int>.generate(6, (i) => i + 1)
                                      .map((e) => DropdownMenuItem<int>(
                                            value: e,
                                            child: Text(e.toString()),
                                          ))
                                      .toList(),
                                  value: _maxPassengers,
                                  onChanged: (value) => setState(() => _maxPassengers = value as int),
                                ),
                                const SizedBox(height: 10),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    minimumSize: const Size.fromHeight(40),
                                  ),
                                  onPressed: () {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }
                                    final vehicle = PemoVehicle.all(const Uuid().v4(), user.id!, _brand!, _model, _color!, _maxPassengers);
                                    vehicleRepository.create(vehicle);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(intl.new_vehicle),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            child: Row(
              children: [
                const Icon(Icons.local_taxi),
                const SizedBox(width: 25),
                Text(intl.vehicles),
              ],
            ),
          ),
        ],
        FilledButton(
          style: flatButtonStyle(),
          onPressed: () {},
          child: Row(
            children: [
              const Icon(Icons.info_outline),
              const SizedBox(width: 25),
              Text(intl.about),
            ],
          ),
        ),
        FilledButton(
          style: flatButtonStyle(),
          onPressed: () {
            userService.handleSignOut();
            nextScreenReplace(context, const AuthScreen());
          },
          child: Row(
            children: [
              const Icon(Icons.logout),
              const SizedBox(width: 25),
              Text(intl.sign_out),
            ],
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "©2023, Fran Matešić (Pemo)",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
