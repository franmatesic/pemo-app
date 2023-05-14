import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../generated/l10n.dart';
import '../../model/pemo_ride.dart';
import '../../model/pemo_ride_dto.dart';
import '../../model/pemo_ride_request_dto.dart';
import '../../repository/ride_repository.dart';
import '../../repository/ride_request_repository.dart';
import '../../repository/user_repository.dart';
import '../../service/location_service.dart';
import '../../service/user_service.dart';
import '../../theme/light_theme.dart';
import '../../utils/places.dart';
import '../../widgets/pemo_ride_card.dart';
import '../../widgets/pemo_ride_request_card.dart';

class RidesScreen extends StatefulWidget {
  const RidesScreen({Key? key}) : super(key: key);

  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  final rideRepository = RideRepository();
  final rideRequestRepository = RideRequestRepository();
  final userRepository = UserRepository();

  LatLng? _myLocation;
  List<PemoRideDto> _myRides = [];
  List<PemoRideRequestDto> _myRequests = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _init();
  }

  _init() async {
    if (LocationService.location == null) {
      _myLocation ??= await LocationService.loadLocation();
    } else {
      _myLocation = LocationService.location;
    }
    _getMyRides();
    _getMyRequests();
  }

  _getMyRequests() async {
    final userService = UserService(context);
    final user = userService.getSignedInUser();
    final requests = await rideRequestRepository.getByUserActive(user.id!);

    List<PemoRideRequestDto> requestDtos = [];
    for (var request in requests) {
      final user = await userRepository.getUser(request.userId);
      final ride = await rideRepository.get(request.rideId);
      requestDtos.add(PemoRideRequestDto(request, user!, await _mapRide(ride!)));
    }
    setState(() => _myRequests = requestDtos);
  }

  _getMyRides() async {
    final userService = UserService(context);
    final user = userService.getSignedInUser();
    final rides = await rideRepository.getByUser(user.id!, true, false);
    final ridesDto = await _mapRides(rides);
    setState(() => _myRides = ridesDto);
  }

  _mapRides(List<PemoRide> rides) async {
    List<PemoRideDto> ridesDto = [];
    for (var ride in rides) {
      ridesDto.add(await _mapRide(ride));
    }
    return ridesDto;
  }

  _mapRide(PemoRide ride) async {
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
    if (user.email! == 'putnik@pemo.hr') {
      rating = 4.5;
    }
    return PemoRideDto(ride, user, formatPlace(start), formatPlace(end), rating);
  }

  @override
  Widget build(BuildContext context) {
    final intl = S.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_myRides.isEmpty) ...[
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
                if (_myRides.isNotEmpty) ...[
                  Text(intl.my_rides, style: boldTextStyle(Palette.black, FontSize.xmd)),
                  const SizedBox(height: 5),
                  ..._myRides.map((ride) => PemoRideCard(ride, asOwner: true)).toList(),
                ],
                const SizedBox(height: 40),
                if (_myRequests.isEmpty) ...[
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
                if (_myRequests.isNotEmpty) ...[
                  Text(intl.my_requests, style: boldTextStyle(Palette.black, FontSize.xmd)),
                  const SizedBox(height: 5),
                  ..._myRequests
                      .map((request) => PemoRideRequestCard(
                            request,
                            asOwner: true,
                            accepted: request.request.acceptedAt != null,
                            denied: request.request.deniedAt != null,
                          ))
                      .toList(),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
