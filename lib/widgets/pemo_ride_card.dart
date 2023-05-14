import 'package:flutter/material.dart';
import 'package:pemo/model/pemo_ride_dto.dart';

import '../generated/l10n.dart';
import '../screens/pages/ride_screen.dart';
import '../service/user_service.dart';
import '../theme/light_theme.dart';
import '../utils/navigation.dart';
import '../utils/parsers.dart';
import 'pemo_rating.dart';

class PemoRideCard extends StatelessWidget {
  final PemoRideDto ride;
  final bool asOwner;
  final bool asHistory;

  const PemoRideCard(this.ride, {Key? key, this.asHistory = false, this.asOwner = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final intl = S.of(context);
    final userService = UserService(context);
    final user = userService.getSignedInUser();

    final isDriver = user.id == ride.user.id;

    String formatDateTimeDto(DateTime dateTime) {
      if (asHistory) {
        return formatDate(dateTime);
      }
      if (dateTime.day == DateTime.now().day) {
        return intl.ride_time_today + formatTime(dateTime);
      }
      if (dateTime.day == DateTime.now().add(const Duration(days: 1)).day) {
        return intl.ride_time_tomorrow + formatTime(dateTime);
      }
      return formatDate(dateTime);
    }

    return InkWell(
      onTap: () => nextScreen(context, RideScreen(ride, asPassenger: !asHistory && !asOwner, asOwner: asOwner)),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!asHistory && !asOwner) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ride.user.name ?? intl.driver,
                      style: boldTextStyle(Palette.black, FontSize.md),
                    ),
                    PemoRating(ride.stars),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              if (asHistory && !isDriver) ...[
                Row(
                  children: [
                    Icon(Icons.local_taxi),
                    const SizedBox(width: 10),
                    Text(ride.user.name!),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 20),
                          const SizedBox(width: 5),
                          Text(
                            formatDateTimeDto(ride.ride.startsAt),
                            style: textStyle(Palette.black, FontSize.sm),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.swipe_down_alt_outlined, size: 20),
                          const SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ride.placeFrom,
                                style: textStyle(Palette.black, FontSize.sm),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                ride.placeTo,
                                style: textStyle(Palette.black, FontSize.sm),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    "${ride.ride.price.toStringAsFixed(2)}€",
                    style: boldTextStyle(Palette.black, (asHistory || asOwner) ? FontSize.md : FontSize.lg),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
