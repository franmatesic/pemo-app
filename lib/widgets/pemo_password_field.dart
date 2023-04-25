import 'package:flutter/material.dart';
import 'package:pemo/generated/l10n.dart';

class PemoPasswordField extends StatefulWidget {
  final Function(String?)? additionalValidator;
  final Function(String?) onChanged;

  const PemoPasswordField({super.key, this.additionalValidator, required this.onChanged});

  @override
  State<PemoPasswordField> createState() => _PemoPasswordFieldState();
}

class _PemoPasswordFieldState extends State<PemoPasswordField> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    final intl = S.of(context);

    return TextFormField(
      decoration: InputDecoration(
        labelText: intl.password,
        prefixIcon: const Icon(
          Icons.lock_outline,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 5,
        ),
      ),
      obscureText: !_passwordVisible,
      keyboardType: TextInputType.text,
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return intl.password_missing;
        }
        if (value.length < 8) {
          return intl.password_invalid;
        }
        return widget.additionalValidator?.call(value);
      },
      onChanged: (value) => widget.onChanged(value),
    );
  }
}
