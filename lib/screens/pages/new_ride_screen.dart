import 'package:flutter/material.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:pemo/model/enums.dart';
import 'package:pemo/model/pemo_vehicle.dart';
import 'package:pemo/repository/ride_repository.dart';
import 'package:pemo/screens/main_screen.dart';
import 'package:pemo/utils/dialogs.dart';
import 'package:pemo/utils/places.dart';
import 'package:pemo/widgets/pemo_autocomplete.dart';
import 'package:pemo/widgets/pemo_button.dart';
import 'package:uuid/uuid.dart';

import '../../generated/l10n.dart';
import '../../model/pemo_ride.dart';
import '../../model/pemo_user.dart';
import '../../repository/user_repository.dart';
import '../../repository/vehicle_repository.dart';
import '../../service/location_service.dart';
import '../../service/user_service.dart';
import '../../theme/light_theme.dart';
import '../../utils/navigation.dart';

class NewRideScreen extends StatefulWidget {
  const NewRideScreen({Key? key}) : super(key: key);

  @override
  State<NewRideScreen> createState() => _NewRideScreenState();
}

class _NewRideScreenState extends State<NewRideScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late GoogleMapController _mapController;
  late GoogleMapPolyline _mapPolyline;
  late PemoUser _user;

  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final dateFormatter = DateFormat.yMd();
  final rideRepository = RideRepository();
  final UserRepository userRepository = UserRepository();

  var _loading = true;
  var _currentLocation = const LatLng(45.815, 15.9819);
  LatLng? _myLocation;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  var _date = DateTime.now();
  var _time = TimeOfDay.now();
  var _multipleDates = false;
  Duration _dateDuration = const Duration(days: 1);
  final _preferredPaymentMethods = [PemoPaymentMethod.cash];
  var _vehicles = [];
  PemoVehicle? _vehicle;
  var _placingFrom = false;
  var _placingTo = false;
  var _fromMarker = const Marker(markerId: MarkerId('fromMarker'));
  var _toMarker = const Marker(markerId: MarkerId('toMarker'));
  var _polyline = const Polyline(polylineId: PolylineId('route'), color: Palette.primary, endCap: Cap.roundCap, startCap: Cap.roundCap);

  @override
  void initState() {
    super.initState();
    _mapPolyline = GoogleMapPolyline(apiKey: 'AIzaSyBXnvOvWt_VZ1pTDJjQ0gxMZpEu75riko8');

    _getLocation();
  }

  _getVehicles(userId) async {
    final vehicleRepo = VehicleRepository();
    _vehicles = await vehicleRepo.getAllFromUser(userId);
  }

  _getLocation() async {
    _myLocation = LocationService.location;
    _currentLocation = _myLocation!;

    _fromController.text = await _getPlaceFormatted(_currentLocation);
    _fromMarker = _fromMarker.copyWith(positionParam: _currentLocation);
    _markers.add(_fromMarker);

    setState(() => _loading = false);
  }

  _getPlaceFormatted(LatLng location) async {
    final place = await getPlaceFromLocation(location);
    if (place == null) {
      return "Loading...";
    }
    return formatPlace(place);
  }

  _onMyLocation() {
    _mapController.animateCamera(CameraUpdate.newLatLng(_myLocation!));
  }

  _updatePolyline() async {
    if (_markers.length == 2) {
      final points = await _mapPolyline.getCoordinatesWithLocation(
          origin: _markers.first.position, destination: _markers.last.position, mode: RouteMode.driving);
      setState(() {
        _polyline = _polyline.copyWith(pointsParam: points);
        _polylines.add(_polyline);
      });
      _adjustCameraToPolyline();
    }
  }

  _adjustCameraToPolyline() async {
    final start = _markers.first.position;
    final end = _markers.last.position;

    double minY = start.latitude <= end.latitude ? start.latitude : end.latitude;
    double minX = start.longitude <= end.longitude ? start.longitude : end.longitude;
    double maxY = start.latitude <= end.latitude ? end.latitude : start.latitude;
    double maxX = start.longitude <= end.longitude ? end.longitude : start.longitude;

    _mapController.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(southwest: LatLng(minY, minX), northeast: LatLng(maxY, maxX)), 100));
  }

  _createRide() async {
    if (_multipleDates) {
      for (var i = 0; i < _dateDuration.inDays; i++) {
        final date = _date.add(Duration(days: i));
        final ride = PemoRide(const Uuid().v4(), _user.id!, _vehicle!.id, _fromMarker.position, _toMarker.position, _preferredPaymentMethods,
            DateTime(date.year, date.month, date.day, _time.hour, _time.minute), DateTime.now());
        await rideRepository.create(ride);
      }
    } else {
      final ride = PemoRide(const Uuid().v4(), _user.id!, _vehicle!.id, _fromMarker.position, _toMarker.position, _preferredPaymentMethods,
          DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute), DateTime.now());
      await rideRepository.create(ride);
    }
    nextScreenReplace(context, const MainScreen());
  }

  @override
  Widget build(BuildContext context) {
    final intl = S.of(context);

    final userService = UserService(context);
    _user = userService.getSignedInUser();
    _getVehicles(_user.id!);

    String translatePaymentMethod(String method) {
      return method == PemoPaymentMethod.cash ? intl.cash : method;
    }

    return Scaffold(
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation,
                      zoom: 16,
                    ),
                    myLocationEnabled: true,
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
                      if (!_placingTo && !_placingFrom) {
                        return;
                      }
                      final region = await _mapController.getVisibleRegion();
                      final location = LatLng(
                          (region.northeast.latitude + region.southwest.latitude) / 2, (region.northeast.longitude + region.southwest.longitude) / 2);
                      if (_placingFrom) {
                        _fromController.text = await _getPlaceFormatted(location);
                      }
                      if (_placingTo) {
                        _toController.text = await _getPlaceFormatted(location);
                      }
                    }),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () => previousScreen(context),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  size: 32,
                                  color: Palette.black,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PemoAutocomplete(
                                      controller: _fromController,
                                      prefixIcon: Icons.location_on_outlined,
                                      hint: intl.where_from,
                                      targetColor: _placingFrom ? Colors.red : Palette.neutral500,
                                      onTarget: () {
                                        if (!_placingTo) {
                                          setState(() {
                                            _placingFrom = !_placingFrom;
                                            if (_placingFrom) {
                                              _polylines.remove(_polyline);
                                              _markers.remove(_fromMarker);
                                            } else {
                                              _markers.add(_fromMarker);
                                            }
                                          });
                                        }
                                      },
                                      onAutoComplete: (prediction) async {
                                        final location = LatLng(double.parse(prediction.lat!), double.parse(prediction.lng!));
                                        FocusManager.instance.primaryFocus?.unfocus();
                                        setState(() {
                                          _markers.remove(_fromMarker);
                                          _fromMarker = _fromMarker.copyWith(positionParam: location);
                                          _markers.add(_fromMarker);
                                        });
                                        _updatePolyline();
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    PemoAutocomplete(
                                      controller: _toController,
                                      prefixIcon: Icons.where_to_vote_outlined,
                                      hint: intl.where_to,
                                      targetColor: _placingTo ? Colors.red : Palette.neutral500,
                                      onTarget: () {
                                        if (!_placingFrom) {
                                          setState(() {
                                            _placingTo = !_placingTo;
                                            if (_placingTo) {
                                              _polylines.remove(_polyline);
                                              _markers.remove(_toMarker);
                                            } else {
                                              _markers.add(_toMarker);
                                            }
                                          });
                                        }
                                      },
                                      onAutoComplete: (prediction) async {
                                        final location = LatLng(double.parse(prediction.lat!), double.parse(prediction.lng!));
                                        FocusManager.instance.primaryFocus?.unfocus();
                                        setState(() {
                                          _markers.remove(_toMarker);
                                          _toMarker = _toMarker.copyWith(positionParam: location);
                                          _markers.add(_toMarker);
                                        });
                                        _updatePolyline();
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    Flex(
                                      direction: Axis.horizontal,
                                      children: [
                                        Expanded(
                                          child: FilledButton(
                                            style: FilledButton.styleFrom(
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              minimumSize: const Size.fromHeight(40),
                                            ),
                                            onPressed: () {
                                              if (!_polylines.contains(_polyline)) {
                                                openSnackbar(context, intl.location_missing, Colors.red, 3);
                                                return;
                                              }
                                              nextScreenReplace(context, const MainScreen());
                                            },
                                            child: Text(intl.search),
                                          ),
                                        ),
                                        if (_user.role == PemoRole.driver) ...[
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: FilledButton(
                                              style: FilledButton.styleFrom(
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                minimumSize: const Size.fromHeight(40),
                                              ),
                                              onPressed: () {
                                                if (!_polylines.contains(_polyline)) {
                                                  openSnackbar(context, intl.location_missing, Colors.red, 3);
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
                                                          height: 600,
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(20),
                                                            child: Form(
                                                              key: _formKey,
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    intl.ride_options,
                                                                    textAlign: TextAlign.center,
                                                                    style: textStyle(Palette.black, FontSize.lg),
                                                                  ),
                                                                  const SizedBox(height: 20),
                                                                  Flex(
                                                                    direction: Axis.horizontal,
                                                                    children: [
                                                                      Expanded(
                                                                        child: FilledButton(
                                                                          style: flippedButtonStyle(),
                                                                          onPressed: () async {
                                                                            if (!_multipleDates) {
                                                                              final datePicker = await showDatePicker(
                                                                                  context: context,
                                                                                  initialDate: _date,
                                                                                  firstDate: DateTime.now(),
                                                                                  lastDate: DateTime.now().add(const Duration(days: 31)));
                                                                              if (datePicker != null) {
                                                                                setState(() => _date = datePicker);
                                                                              }
                                                                              return;
                                                                            }
                                                                            final datePicker = await showDateRangePicker(
                                                                              context: context,
                                                                              firstDate: DateTime.now(),
                                                                              lastDate: DateTime.now().add(const Duration(days: 31)),
                                                                            );
                                                                            if (datePicker != null) {
                                                                              setState(() {
                                                                                _date = datePicker.start;
                                                                                _dateDuration = datePicker.duration;
                                                                              });
                                                                            }
                                                                          },
                                                                          child: Text(_multipleDates
                                                                              ? "${dateFormatter.format(_date)} (${_dateDuration.inDays + 1})"
                                                                              : dateFormatter.format(_date)),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(width: 20),
                                                                      Expanded(
                                                                        child: FilledButton(
                                                                          style: flippedButtonStyle(),
                                                                          onPressed: () async {
                                                                            final timePicker =
                                                                                await showTimePicker(context: context, initialTime: _time);
                                                                            if (timePicker != null) {
                                                                              setState(() => _time = timePicker);
                                                                            }
                                                                          },
                                                                          child: Text(_time.format(context)),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  CheckboxListTile(
                                                                    title: Text(intl.multiple_dates),
                                                                    dense: true,
                                                                    value: _multipleDates,
                                                                    onChanged: (value) => setState(() => _multipleDates = value!),
                                                                  ),
                                                                  Text(intl.vehicle),
                                                                  DropdownButtonFormField(
                                                                    items: _vehicles
                                                                        .map((e) => DropdownMenuItem<PemoVehicle>(
                                                                              value: e,
                                                                              child: Text("${e.brand} ${e.model} (${e.color})"),
                                                                            ))
                                                                        .toList(),
                                                                    validator: (value) {
                                                                      if (value == null) {
                                                                        return intl.vehicle_missing;
                                                                      }
                                                                      return null;
                                                                    },
                                                                    onChanged: (value) => setState(() => _vehicle = value as PemoVehicle),
                                                                  ),
                                                                  const SizedBox(height: 20),
                                                                  Text(intl.preferred_payment_methods),
                                                                  MultiSelectChipDisplay(
                                                                    items: PemoPaymentMethod.values
                                                                        .map((e) => MultiSelectItem(e, translatePaymentMethod(e)))
                                                                        .toList(),
                                                                    colorator: (String value) => _preferredPaymentMethods.contains(value)
                                                                        ? Palette.primary
                                                                        : Palette.neutral500,
                                                                    textStyle: textStyle(Palette.white, FontSize.md),
                                                                    onTap: (String value) {
                                                                      if (_preferredPaymentMethods.contains(value)) {
                                                                        setState(() => _preferredPaymentMethods.remove(value));
                                                                      } else {
                                                                        setState(() => _preferredPaymentMethods.add(value));
                                                                      }
                                                                    },
                                                                  ),
                                                                  const SizedBox(height: 10),
                                                                  FilledButton(
                                                                    style: FilledButton.styleFrom(
                                                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                      minimumSize: const Size.fromHeight(40),
                                                                    ),
                                                                    onPressed: () {
                                                                      if (!_formKey.currentState!.validate()) {
                                                                        return;
                                                                      }
                                                                      _createRide();
                                                                    },
                                                                    child: Text(intl.new_ride),
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
                                              child: Text(intl.new_ride),
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10, bottom: 90),
                      child: ClipOval(
                        child: Material(
                          color: Colors.white70,
                          child: InkWell(
                            onTap: _onMyLocation,
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.my_location,
                                size: 24,
                                color: Palette.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_placingFrom || _placingTo) ...[
                  const Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
                      child: PemoButton(
                        onPressed: () async {
                          final region = await _mapController.getVisibleRegion();
                          final location = LatLng((region.northeast.latitude + region.southwest.latitude) / 2,
                              (region.northeast.longitude + region.southwest.longitude) / 2);

                          if (_placingFrom) {
                            _fromController.text = await _getPlaceFormatted(location);
                            setState(() {
                              _placingFrom = false;
                              _fromMarker = _fromMarker.copyWith(positionParam: location);
                              _markers.add(_fromMarker);
                            });
                          }
                          if (_placingTo) {
                            _toController.text = await _getPlaceFormatted(location);
                            setState(() {
                              _placingTo = false;
                              _toMarker = _toMarker.copyWith(positionParam: location);
                              _markers.add(_toMarker);
                            });
                          }
                          _updatePolyline();
                        },
                        child: Text(_placingFrom ? intl.set_source : intl.set_destination),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
