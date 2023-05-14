import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:pemo/utils/places.dart';

import '../theme/light_theme.dart';

class PemoAutocomplete extends StatelessWidget {
  final String hint;
  final bool autoFocus;
  final Color targetColor;
  final IconData? prefixIcon;
  final Function(Prediction)? onAutoComplete;
  final VoidCallback? onTarget;
  final TextEditingController controller;

  const PemoAutocomplete(
      {super.key,
      this.onAutoComplete,
      this.autoFocus = false,
      this.onTarget,
      this.hint = 'Search',
      this.targetColor = Palette.neutral500,
      required this.controller,
      this.prefixIcon});

  @override
  Widget build(BuildContext context) {
    return GooglePlaceAutoCompleteTextField(
      textStyle: textStyle(Palette.black, FontSize.sm),
      inputDecoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Palette.black,
          ),
        ),
        constraints: const BoxConstraints(maxHeight: 40),
        filled: true,
        fillColor: Palette.white,
        prefixIcon: Icon(
          prefixIcon ?? Icons.search,
          color: Palette.neutral800,
        ),
        prefixIconColor: Palette.black,
        suffixIcon: IconButton(
          icon: Icon(
            Icons.edit_location_outlined,
            color: targetColor,
          ),
          onPressed: onTarget,
        ),
        hintText: hint,
      ),
      textEditingController: controller,
      googleAPIKey: 'AIzaSyBXnvOvWt_VZ1pTDJjQ0gxMZpEu75riko8',
      isLatLngRequired: true,
      getPlaceDetailWithLatLng: (prediction) async {
        final location = LatLng(double.parse(prediction.lat!), double.parse(prediction.lng!));
        final place = await getPlaceFromLocation(location);
        if (place != null) {
          controller.text = formatPlace(place);
        }
        if (onAutoComplete != null) {
          onAutoComplete!(prediction);
        }
      },
      itmClick: (prediction) {},
    );
  }
}
