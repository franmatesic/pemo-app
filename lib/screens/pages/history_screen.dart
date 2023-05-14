import 'package:flutter/material.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:pemo/repository/ride_request_repository.dart';
import 'package:pemo/theme/light_theme.dart';

import '../../generated/l10n.dart';
import '../../model/enums.dart';
import '../../model/pemo_ride.dart';
import '../../model/pemo_ride_dto.dart';
import '../../repository/ride_repository.dart';
import '../../repository/user_repository.dart';
import '../../service/user_service.dart';
import '../../utils/places.dart';
import '../../widgets/pemo_ride_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final rideRepository = RideRepository();
  final rideRequestRepository = RideRequestRepository();
  final userRepository = UserRepository();

  List<PemoRideDto> _myRides = [];
  String? _filter;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () => _getMyRides());
  }

  _getMyRides() async {
    final userService = UserService(context);
    final user = userService.getSignedInUser();
    List<PemoRide> filteredRides = [];

    if (_filter != PemoRole.passenger) {
      final rides = await rideRepository.getByUser(user.id!, false, true);
      filteredRides.addAll(rides);
    }

    if (_filter != PemoRole.driver) {
      final rideRequests = await rideRequestRepository.getByUser(user.id!);
      for (var rideRequest in rideRequests) {
        final ride = await rideRepository.get(rideRequest.rideId);
        filteredRides.add(ride!);
      }
    }

    final ridesDto = await _mapRides(filteredRides);
    setState(() => _myRides = ridesDto);
  }

  _mapRides(List<PemoRide> rides) async {
    List<PemoRideDto> ridesDto = [];
    for (var ride in rides) {
      final start = await getPlaceFromLocation(ride.start);
      final end = await getPlaceFromLocation(ride.end);
      final user = await userRepository.getUser(ride.userId);
      /*
      TEMPORARY RATING
       */
      var rating = 5.0;
      if (user!.email! == 'vozac@pemo.hr') {
        rating = 3.5;
      }
      ridesDto.add(PemoRideDto(ride, user, formatPlace(start), formatPlace(end), rating));
    }
    return ridesDto;
  }

  @override
  Widget build(BuildContext context) {
    final intl = S.of(context);
    final userService = UserService(context);
    final user = userService.getSignedInUser();

    String translateRole(role) {
      return role == PemoRole.passenger ? intl.passenger : intl.driver;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(intl.history, style: boldTextStyle(Palette.black, FontSize.xmd)),
                const SizedBox(height: 10),
                if (user.role! == PemoRole.driver) ...[
                  MultiSelectChipDisplay(
                    items: [PemoRole.passenger, PemoRole.driver].map((e) => MultiSelectItem(e, translateRole(e))).toList(),
                    colorator: (String value) => _filter == value ? Palette.primary : Palette.neutral500,
                    textStyle: textStyle(Palette.white, FontSize.md),
                    onTap: (String value) {
                      setState(() => _filter = _filter == value ? null : value);
                      _getMyRides();
                    },
                  ),
                ],
                const SizedBox(height: 10),
                ..._myRides.map((ride) => PemoRideCard(ride, asHistory: true)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
