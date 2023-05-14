import 'package:flutter/material.dart';
import 'package:pemo/theme/light_theme.dart';

class PemoTextField extends StatelessWidget {
  final String text;
  final String labelText;
  final Color color;
  final Color textColor;
  final bool enabled;
  final Icon? prefixIcon;
  final TextInputType? textInputType;
  final Function(String?) validator;
  final Function(String?) onChanged;

  const PemoTextField(
      {super.key,
      required this.labelText,
      required this.validator,
      required this.onChanged,
      this.prefixIcon,
      this.text = '',
      this.color = Palette.primary,
      this.textColor = Palette.black,
      this.enabled = true,
      this.textInputType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      style: textStyle(textColor, FontSize.md),
      cursorColor: color,
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: color,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: color,
          ),
        ),
        labelText: labelText,
        labelStyle: textStyle(enabled ? color : Palette.neutral800, FontSize.md),
        prefixIconColor: color,
        prefixIcon: prefixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 5,
        ),
      ),
      keyboardType: textInputType,
      initialValue: text,
      validator: (String? value) {
        return validator.call(value);
      },
      onChanged: (value) => onChanged(value),
    );
  }
}
