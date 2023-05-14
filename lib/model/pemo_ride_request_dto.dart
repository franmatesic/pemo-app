import 'package:pemo/model/pemo_ride_dto.dart';
import 'package:pemo/model/pemo_ride_request.dart';
import 'package:pemo/model/pemo_user.dart';

class PemoRideRequestDto {
  final PemoRideRequest request;
  final PemoRideDto ride;
  final PemoUser user;

  PemoRideRequestDto(this.request, this.user, this.ride);
}
