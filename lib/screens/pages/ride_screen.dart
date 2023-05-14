import 'package:flutter/material.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pemo/model/enums.dart';
import 'package:pemo/model/pemo_ride_request_dto.dart';
import 'package:pemo/repository/ride_request_repository.dart';
import 'package:pemo/repository/user_repository.dart';
import 'package:pemo/repository/vehicle_repository.dart';
import 'package:pemo/screens/main_screen.dart';
import 'package:pemo/secrets.dart';
import 'package:pemo/utils/dialogs.dart';
import 'package:pemo/widgets/pemo_rating.dart';
import 'package:pemo/widgets/pemo_ride_request_card.dart';
import 'package:uuid/uuid.dart';

import '../../generated/l10n.dart';
import '../../model/pemo_ride.dart';
import '../../model/pemo_ride_dto.dart';
import '../../model/pemo_ride_request.dart';
import '../../repository/ride_repository.dart';
import '../../service/user_service.dart';
import '../../theme/light_theme.dart';
import '../../utils/navigation.dart';
import '../../utils/parsers.dart';
import '../../utils/places.dart';
import '../../widgets/pemo_autocomplete.dart';
import '../../widgets/pemo_button.dart';

class RideScreen extends StatefulWidget {
  final PemoRideDto ride;
  final bool asOwner;
  final bool asPassenger;

  const RideScreen(this.ride, {Key? key, this.asOwner = false, this.asPassenger = false}) : super(key: key);

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final rideRequestRepository = RideRequestRepository();
  final userRepository = UserRepository();
  final rideRepository = RideRepository();
  final vehicleRepository = VehicleRepository();

  late GoogleMapController _mapController;
  late GoogleMapPolyline _mapPolyline;

  final _stopController = TextEditingController();
  final _startController = TextEditingController();
  var _placingStop = false;
  var _placingStart = false;
  PemoRideRequestDto? _showingRequest;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  List<PemoRideRequestDto> _rideRequests = [];

  var _paymentMethod = PemoPaymentMethod.cash;
  var _passengerCount = 1;
  var _maxPassengers = 3;

  var _fromMarker = const Marker(markerId: MarkerId('fromMarker'));
  var _toMarker = const Marker(markerId: MarkerId('toMarker'));
  var _stopMarker = Marker(markerId: const MarkerId('stopMarker'), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue));
  var _startMarker = Marker(markerId: const MarkerId('startMarker'), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue));

  var _polyline1 = const Polyline(polylineId: PolylineId('route1'), color: Palette.primary, width: 5, endCap: Cap.roundCap, startCap: Cap.roundCap);
  var _polyline2 = const Polyline(polylineId: PolylineId('route2'), color: Palette.primary, width: 5, endCap: Cap.roundCap, startCap: Cap.roundCap);
  var _polyline3 = const Polyline(polylineId: PolylineId('route3'), color: Palette.primary, width: 5, endCap: Cap.roundCap, startCap: Cap.roundCap);
  final _currentLocation = const LatLng(45.815, 15.9819);

  @override
  void initState() {
    super.initState();
    _mapPolyline = GoogleMapPolyline(apiKey: googleApiKey);

    _setupLocations();
    _setMaxPassengers();
    if (widget.asOwner) {
      _initRequests();
    }
  }

  _initRequests() async {
    final requests = await rideRequestRepository.getByRide(widget.ride.ride.id);
    List<PemoRideRequestDto> requestDtos = [];
    for (var request in requests) {
      final user = await userRepository.getUser(request.userId);
      final ride = await rideRepository.get(request.rideId);
      requestDtos.add(PemoRideRequestDto(request, user!, await _mapRide(ride!)));
    }
    setState(() => _rideRequests = requestDtos);
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
    return PemoRideDto(ride, user, formatPlace(start), formatPlace(end), rating);
  }

  _setMaxPassengers() async {
    final vehicle = await vehicleRepository.get(widget.ride.ride.vehicleId);
    _maxPassengers = vehicle!.maxPassengers;
  }

  _setupLocations() async {
    _fromMarker = _fromMarker.copyWith(positionParam: widget.ride.ride.start);
    _toMarker = _toMarker.copyWith(positionParam: widget.ride.ride.end);
    _startMarker = _startMarker.copyWith(positionParam: widget.ride.ride.start);
    _stopMarker = _stopMarker.copyWith(positionParam: widget.ride.ride.end);
    _markers.add(_startMarker);
    _markers.add(_fromMarker);
    _markers.add(_stopMarker);
    _markers.add(_toMarker);

    final points =
        await _mapPolyline.getCoordinatesWithLocation(origin: _fromMarker.position, destination: _toMarker.position, mode: RouteMode.driving);
    setState(() {
      _polyline1 = _polyline1.copyWith(pointsParam: points);
      _polylines.add(_polyline1);
    });

    _adjustCameraToPolyline();
  }

  _getPlaceFormatted(LatLng location) async {
    final place = await getPlaceFromLocation(location);
    if (place == null) {
      return "Loading...";
    }
    return formatPlace(place);
  }

  _adjustCameraToPolyline() async {
    final start = _fromMarker.position;
    final end = _toMarker.position;

    double minY = start.latitude <= end.latitude ? start.latitude : end.latitude;
    double minX = start.longitude <= end.longitude ? start.longitude : end.longitude;
    double maxY = start.latitude <= end.latitude ? end.latitude : start.latitude;
    double maxX = start.longitude <= end.longitude ? end.longitude : start.longitude;

    _mapController.moveCamera(CameraUpdate.newLatLngBounds(LatLngBounds(southwest: LatLng(minY, minX), northeast: LatLng(maxY, maxX)), 80));
  }

  _updatePolyline(adjustCamera) async {
    final points1 =
        await _mapPolyline.getCoordinatesWithLocation(origin: _fromMarker.position, destination: _startMarker.position, mode: RouteMode.driving);

    final points2 =
        await _mapPolyline.getCoordinatesWithLocation(origin: _startMarker.position, destination: _stopMarker.position, mode: RouteMode.driving);
    final points3 =
        await _mapPolyline.getCoordinatesWithLocation(origin: _stopMarker.position, destination: _toMarker.position, mode: RouteMode.driving);
    setState(() {
      _polyline1 = _polyline1.copyWith(pointsParam: points1);
      _polyline2 = _polyline2.copyWith(pointsParam: points2);
      _polyline3 = _polyline3.copyWith(pointsParam: points3);
      _polylines.add(_polyline1);
      _polylines.add(_polyline2);
      _polylines.add(_polyline3);
    });
    if (adjustCamera) {
      _adjustCameraToPolyline();
    }
  }

  _onShowRequest(PemoRideRequestDto request) async {
    setState(() {
      if (_showingRequest == null || _showingRequest != request) {
        _showingRequest = request;
      } else {
        _showingRequest = null;
      }

      _markers.remove(_startMarker);
      _markers.remove(_stopMarker);
      if (_showingRequest != null) {
        _startMarker = _startMarker.copyWith(positionParam: request.request.pickup);
        _stopMarker = _stopMarker.copyWith(positionParam: request.request.stop);
      } else {
        _startMarker = _startMarker.copyWith(positionParam: _fromMarker.position);
        _stopMarker = _stopMarker.copyWith(positionParam: _toMarker.position);
      }
      _markers.add(_startMarker);
      _markers.add(_stopMarker);
    });
    _updatePolyline(true);
  }

  @override
  Widget build(BuildContext context) {
    final intl = S.of(context);
    final userService = UserService(context);
    final user = userService.getSignedInUser();

    String translatePaymentMethod(String method) {
      return method == PemoPaymentMethod.cash ? intl.cash : method;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => previousScreen(context),
                    child: const Icon(
                      Icons.chevron_left_outlined,
                      size: 32,
                      color: Palette.primary,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Icon(Icons.local_taxi),
                  const SizedBox(width: 10),
                  Text(
                    widget.ride.user.name ?? intl.driver,
                    style: boldTextStyle(Palette.black, FontSize.md),
                  ),
                  const Spacer(),
                  PemoRating(widget.ride.stars),
                ],
              ),
              const SizedBox(height: 10),
              if (widget.asPassenger) ...[
                PemoAutocomplete(
                  controller: _startController,
                  prefixIcon: Icons.location_on_outlined,
                  hint: intl.set_pickup,
                  targetColor: _placingStart ? Colors.blue.shade800 : Palette.neutral500,
                  onTarget: () {
                    if (!_placingStop) {
                      setState(() => _placingStart = !_placingStart);
                    }
                  },
                  onAutoComplete: (prediction) async {
                    final location = LatLng(double.parse(prediction.lat!), double.parse(prediction.lng!));
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      _markers.remove(_startMarker);
                      _startMarker = _startMarker.copyWith(positionParam: location);
                      _markers.add(_startMarker);
                      _updatePolyline(true);
                    });
                  },
                ),
                const SizedBox(height: 10),
                PemoAutocomplete(
                  controller: _stopController,
                  prefixIcon: Icons.where_to_vote_outlined,
                  hint: intl.set_stop,
                  targetColor: _placingStop ? Colors.blue.shade800 : Palette.neutral500,
                  onTarget: () {
                    if (!_placingStart) {
                      setState(() => _placingStop = !_placingStop);
                    }
                  },
                  onAutoComplete: (prediction) async {
                    final location = LatLng(double.parse(prediction.lat!), double.parse(prediction.lng!));
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      _markers.remove(_stopMarker);
                      _stopMarker = _stopMarker.copyWith(positionParam: location);
                      _markers.add(_stopMarker);
                      _updatePolyline(true);
                    });
                  },
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                height: widget.asOwner ? 300 : 400,
                child: Stack(
                  children: [
                    GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentLocation,
                          zoom: 16,
                        ),
                        myLocationButtonEnabled: false,
                        markers: _markers,
                        polylines: _polylines,
                        tiltGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        zoomControlsEnabled: false,
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        onCameraIdle: () async {
                          if (!_placingStart && !_placingStop) {
                            return;
                          }
                          final region = await _mapController.getVisibleRegion();
                          final location = LatLng((region.northeast.latitude + region.southwest.latitude) / 2,
                              (region.northeast.longitude + region.southwest.longitude) / 2);

                          if (_placingStart) {
                            _startController.text = await _getPlaceFormatted(location);
                          }
                          if (_placingStop) {
                            _stopController.text = await _getPlaceFormatted(location);
                          }
                        }),
                    if (_placingStart || _placingStop) ...[
                      Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.location_pin,
                          color: Colors.blue.shade800,
                          size: 40,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
                          child: PemoButton(
                            onPressed: () async {
                              final region = await _mapController.getVisibleRegion();
                              final location = LatLng((region.northeast.latitude + region.southwest.latitude) / 2,
                                  (region.northeast.longitude + region.southwest.longitude) / 2);
                              if (_placingStart) {
                                _startController.text = await _getPlaceFormatted(location);
                                setState(() {
                                  _placingStart = false;
                                  _markers.remove(_startMarker);
                                  _startMarker = _startMarker.copyWith(positionParam: location);
                                  _markers.add(_startMarker);
                                  _updatePolyline(true);
                                });
                              }
                              if (_placingStop) {
                                _stopController.text = await _getPlaceFormatted(location);
                                setState(() {
                                  _placingStop = false;
                                  _markers.remove(_stopMarker);
                                  _stopMarker = _stopMarker.copyWith(positionParam: location);
                                  _markers.add(_stopMarker);
                                  _updatePolyline(true);
                                });
                              }
                            },
                            child: Text(_placingStart ? intl.set_pickup : intl.set_stop),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 20),
                  const SizedBox(width: 5),
                  Text(
                    formatDate(widget.ride.ride.startsAt),
                    style: textStyle(Palette.black, FontSize.md),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.swipe_down_alt_outlined, size: 20),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ride.placeFrom,
                        style: textStyle(Palette.black, FontSize.md),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.ride.placeTo,
                        style: textStyle(Palette.black, FontSize.md),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (widget.asOwner) ...[
                Text(intl.ride_requests),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    itemBuilder: (context, index) => PemoRideRequestCard(
                      _rideRequests[index],
                      accepted: _rideRequests[index].request.acceptedAt != null,
                      highlighted: _showingRequest == _rideRequests[index],
                      onTap: () {
                        _onShowRequest(_rideRequests[index]);
                      },
                    ),
                    itemCount: _rideRequests.length,
                  ),
                ),
                const Spacer(),
                if (_showingRequest == null && widget.asOwner) ...[
                  FilledButton(
                    style: FilledButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size.fromHeight(40),
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      _showingRequest!.request.cancelledAt = DateTime.now();
                      await rideRequestRepository.update(_showingRequest!.request);
                      await _initRequests();
                    },
                    child: Text(intl.cancel),
                  ),
                ],
                if (_showingRequest != null && _showingRequest!.request.acceptedAt == null) ...[
                  Flex(
                    direction: Axis.horizontal,
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: const Size.fromHeight(40),
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            _showingRequest!.request.deniedAt = DateTime.now();
                            await rideRequestRepository.update(_showingRequest!.request);
                            setState(() => _showingRequest = null);
                            await _initRequests();
                          },
                          child: Text(intl.deny),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: const Size.fromHeight(40),
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () async {
                            _showingRequest!.request.acceptedAt = DateTime.now();
                            await rideRequestRepository.update(_showingRequest!.request);
                            setState(() => _showingRequest = null);
                            await _initRequests();
                          },
                          child: Text(intl.approve),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                // FilledButton(
                //   style: FilledButton.styleFrom(
                //     backgroundColor: Colors.red,
                //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //     minimumSize: const Size.fromHeight(40),
                //   ),
                //   onPressed: () {
                //     showAlertDialog(context, intl.cancel, intl.sure, () async {
                //       widget.ride.ride.cancelledAt = DateTime.now();
                //       await rideRepository.update(widget.ride.ride);
                //       nextScreenReplace(context, const MainScreen());
                //     });
                //   },
                //   child: Text(intl.cancel),
                // ),
              ],
              if (widget.asPassenger) ...[
                FilledButton(
                  style: FilledButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: const Size.fromHeight(40),
                  ),
                  onPressed: () async {
                    final rideRequests = await rideRequestRepository.getByUserActive(user.id!);
                    final existsActive = rideRequests.any((e) {
                      return e.rideId == widget.ride.ride.id && e.acceptedAt == null && e.cancelledAt == null;
                    });
                    if (existsActive) {
                      openSnackbar(context, intl.request_exists, Colors.red, 3);
                      return;
                    }
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
                              height: 400,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        intl.request_ride,
                                        textAlign: TextAlign.center,
                                        style: textStyle(Palette.black, FontSize.lg),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(intl.preferred_payment_method),
                                      DropdownButtonFormField(
                                        items: widget.ride.ride.preferredPaymentMethods
                                            .map((e) => DropdownMenuItem<String>(
                                                  value: e,
                                                  child: Text(translatePaymentMethod(e)),
                                                ))
                                            .toList(),
                                        value: _paymentMethod,
                                        onChanged: (value) => setState(() => _paymentMethod = value as String),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(intl.passenger_count),
                                      DropdownButtonFormField(
                                        items: List<int>.generate(_maxPassengers, (i) => i + 1)
                                            .map((e) => DropdownMenuItem<int>(
                                                  value: e,
                                                  child: Text(e.toString()),
                                                ))
                                            .toList(),
                                        value: _passengerCount,
                                        onChanged: (value) => setState(() => _passengerCount = value as int),
                                      ),
                                      const SizedBox(height: 20),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          minimumSize: const Size.fromHeight(40),
                                        ),
                                        onPressed: () {
                                          final rideRequest = PemoRideRequest(const Uuid().v4(), user.id!, widget.ride.ride.id, _startMarker.position,
                                              _stopMarker.position, _paymentMethod, _passengerCount, DateTime.now());
                                          rideRequestRepository.create(rideRequest);
                                          nextScreenReplace(context, const MainScreen());
                                        },
                                        child: Text(intl.request_ride),
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
                  child: Text(intl.request_ride),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
