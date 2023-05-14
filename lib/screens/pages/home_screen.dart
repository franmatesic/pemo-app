import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pemo/repository/ride_repository.dart';
import 'package:pemo/repository/user_repository.dart';
import 'package:pemo/service/location_service.dart';
import 'package:pemo/utils/places.dart';

import '../../../generated/l10n.dart';
import '../../model/pemo_ride.dart';
import '../../model/pemo_ride_dto.dart';
import '../../repository/ride_request_repository.dart';
import '../../service/user_service.dart';
import '../../theme/light_theme.dart';
import '../../utils/navigation.dart';
import '../../widgets/pemo_ride_card.dart';
import 'new_ride_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RideRepository rideRepository = RideRepository();
  final rideRequestRepository = RideRequestRepository();
  final UserRepository userRepository = UserRepository();

  LatLng? _myLocation;
  List<PemoRideDto> _closestRides = [];

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
    _getClosestRides();
  }

  _getClosestRides() async {
    final userService = UserService(context);
    final user = userService.getSignedInUser();
    final rides = await rideRepository.getClosest(_myLocation, user.id!, 100, 9999);
    final ridesDto = await _mapRides(rides);
    setState(() => _closestRides = ridesDto);
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Image.asset(
                    'assets/images/logo.png',
                    color: Palette.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            TextFormField(
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
              ),
              keyboardType: TextInputType.text,
              onTap: () {
                if (_myLocation != null) {
                  nextScreen(context, const NewRideScreen());
                }
              },
              readOnly: true,
            ),
            const SizedBox(height: 60),
            if (_closestRides.isNotEmpty) ...[
              Text(intl.close_rides, style: boldTextStyle(Palette.black, FontSize.xmd)),
              const SizedBox(height: 5),
              ..._closestRides.map((ride) => PemoRideCard(ride)).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
