import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pemo/theme/light_theme.dart';

import '../generated/l10n.dart';

class PemoPhoneNumberField extends StatefulWidget {
  final Color color;
  final Color textColor;
  final Function(PhoneNumber) onChanged;

  const PemoPhoneNumberField({super.key, required this.onChanged, this.color = Palette.primary, this.textColor = Palette.black});

  @override
  State<PemoPhoneNumberField> createState() => _PemoPhoneNumberFieldState();
}

class _PemoPhoneNumberFieldState extends State<PemoPhoneNumberField> {
  PhoneNumber defaultNumber = PhoneNumber(isoCode: Platform.localeName.substring(0, 2).toUpperCase());

  @override
  Widget build(BuildContext context) {
    final intl = S.of(context);

    return InternationalPhoneNumberInput(
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
        showFlags: true,
        useEmoji: true,
      ),
      errorMessage: intl.phone_invalid,
      hintText: intl.phone,
      formatInput: true,
      cursorColor: widget.color,
      textStyle: TextStyle(color: widget.textColor),
      inputDecoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: widget.color,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: widget.color,
          ),
        ),
      ),
      initialValue: defaultNumber,
      onInputChanged: widget.onChanged,
    );
  }
}
