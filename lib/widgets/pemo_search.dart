import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../generated/l10n.dart';
import '../screens/pages/new_ride_screen.dart';
import '../theme/light_theme.dart';
import '../utils/dialogs.dart';
import '../utils/navigation.dart';

class PemoSearch extends StatefulWidget {
  final LatLng? myLocation;

  const PemoSearch({Key? key, required this.myLocation}) : super(key: key);

  @override
  State<PemoSearch> createState() => _PemoSearchState();
}

class _PemoSearchState extends State<PemoSearch> {
  final dateFormatter = DateFormat.yMd();

  var _searchDate = DateTime.now();
  var _searchTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    final intl = S.of(context);

    return TextFormField(
      style: textStyle(Palette.black, FontSize.md),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        filled: true,
        fillColor: Palette.neutral100,
        hintText: intl.where_to,
        prefixIcon: const Icon(Icons.search),
        prefixIconColor: Palette.black,
        // suffixIcon: Padding(
        //   padding: const EdgeInsets.only(right: 5),
        //   child: TextButton.icon(
        //       style: TextButton.styleFrom(
        //         minimumSize: const Size(100, 0),
        //         backgroundColor: Palette.white,
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(100),
        //         ),
        //         foregroundColor: Palette.primary,
        //       ),
        //       icon: const Icon(Icons.schedule),
        //       label: Text(intl.now),
        //       onPressed: () {
        //         setState(() {
        //           _searchDate = DateTime.now();
        //           _searchTime = TimeOfDay.now();
        //         });
        //
        //         showModalBottomSheet(
        //             clipBehavior: Clip.antiAlias,
        //             shape: const RoundedRectangleBorder(
        //               borderRadius: BorderRadius.only(
        //                 topLeft: Radius.circular(20),
        //                 topRight: Radius.circular(20),
        //               ),
        //             ),
        //             context: context,
        //             builder: (context) {
        //               return StatefulBuilder(
        //                 builder: (BuildContext context, StateSetter setState) {
        //                   return SizedBox(
        //                     height: 320,
        //                     child: Padding(
        //                       padding: const EdgeInsets.all(20),
        //                       child: Column(
        //                         children: [
        //                           Text(
        //                             intl.when,
        //                             textAlign: TextAlign.center,
        //                             style: textStyle(Palette.black, FontSize.xl),
        //                           ),
        //                           const SizedBox(height: 20),
        //                           PemoButton(
        //                             outlined: true,
        //                             foregroundColor: Palette.primary,
        //                             onPressed: () async {
        //                               final datePicker = await showDatePicker(
        //                                   context: context,
        //                                   initialDate: _searchDate,
        //                                   firstDate: DateTime.now(),
        //                                   lastDate: DateTime.now().add(const Duration(days: 31)));
        //                               if (datePicker != null) {
        //                                 setState(() => _searchDate = datePicker);
        //                               }
        //                             },
        //                             width: 300,
        //                             fullWidth: false,
        //                             child: Text(
        //                               dateFormatter.format(_searchDate),
        //                               style: textStyle(Palette.black, FontSize.lg),
        //                             ),
        //                           ),
        //                           const SizedBox(height: 10),
        //                           PemoButton(
        //                             outlined: true,
        //                             foregroundColor: Palette.primary,
        //                             onPressed: () async {
        //                               final timePicker = await showTimePicker(context: context, initialTime: _searchTime);
        //                               if (timePicker != null) {
        //                                 setState(() => _searchTime = timePicker);
        //                               }
        //                             },
        //                             width: 300,
        //                             fullWidth: false,
        //                             child: Text(
        //                               _searchTime.format(context),
        //                               style: textStyle(Palette.black, FontSize.lg),
        //                             ),
        //                           ),
        //                           const SizedBox(height: 20),
        //                           PemoButton(
        //                             fullWidth: false,
        //                             width: 300,
        //                             onPressed: () {
        //                               Navigator.pop(context);
        //                               nextScreen(context, const NewRideScreen());
        //                             },
        //                             child: Text(
        //                               intl.set_time,
        //                               style: textStyle(Palette.white, FontSize.md),
        //                             ),
        //                           ),
        //                         ],
        //                       ),
        //                     ),
        //                   );
        //                 },
        //               );
        //             });
        //       }),
        // ),
      ),
      keyboardType: TextInputType.text,
      onTap: () {
        if (widget.myLocation == null) {
          openSnackbar(context, "Allow location permission to search", Colors.red, 3);
        } else {
          nextScreen(context, const NewRideScreen());
        }
      },
      readOnly: true,
    );
  }
}
