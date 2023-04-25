import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pemo/theme/light_theme.dart';

import '../generated/l10n.dart';

class PemoDatePicker extends StatefulWidget {
  final Color color;
  final Color textColor;
  final Color iconColor;
  final Function(String?)? validator;
  final Function(String?) onChanged;

  const PemoDatePicker(
      {super.key,
      required this.onChanged,
      this.validator,
      this.color = Palette.primary,
      this.textColor = Palette.black,
      this.iconColor = Palette.primary});

  @override
  State<PemoDatePicker> createState() => _PemoDatePickerState();
}

class _PemoDatePickerState extends State<PemoDatePicker> {
  final dateController = TextEditingController();
  final formatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    dateController.text = "";
    super.initState();
  }

  Future _pickDate() async {
    final datePicker = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1920), lastDate: DateTime.now());

    if (datePicker != null) {
      final formattedDate = formatter.format(datePicker);
      setState(() => dateController.text = formattedDate);
      widget.onChanged(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final intl = S.of(context);

    return TextFormField(
      controller: dateController,
      style: textStyle(widget.textColor, FontSize.md),
      cursorColor: widget.color,
      decoration: InputDecoration(
        icon: const Icon(Icons.calendar_month),
        iconColor: widget.iconColor,
        labelStyle: TextStyle(color: widget.color),
        labelText: intl.choose_date,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 5,
        ),
      ),
      readOnly: true,
      onTap: _pickDate,
      validator: (String? value) {
        return widget.validator?.call(value);
      },
      onChanged: null,
    );
  }
}
