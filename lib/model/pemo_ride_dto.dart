import 'pemo_ride.dart';
import 'pemo_user.dart';

class PemoRideDto {
  final PemoRide ride;
  final PemoUser user;
  final double stars;
  final String placeFrom;
  final String placeTo;

  PemoRideDto(this.ride, this.user, this.placeFrom, this.placeTo, this.stars);
}
