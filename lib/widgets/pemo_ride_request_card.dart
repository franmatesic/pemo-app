import 'package:flutter/material.dart';
import 'package:pemo/model/pemo_ride_request_dto.dart';

import '../generated/l10n.dart';
import '../theme/light_theme.dart';
import '../utils/parsers.dart';
import 'pemo_rating.dart';

class PemoRideRequestCard extends StatelessWidget {
  final PemoRideRequestDto rideRequest;
  final bool asOwner;
  final bool asHistory;
  final bool highlighted;
  final bool accepted;
  final bool denied;
  final VoidCallback? onTap;

  const PemoRideRequestCard(this.rideRequest,
      {Key? key, this.asHistory = false, this.asOwner = false, this.onTap, this.highlighted = false, this.accepted = false, this.denied = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final intl = S.of(context);

    textColor() => highlighted ? Palette.white : Palette.black;

    return InkWell(
      onTap: onTap,
      child: Card(
        color: highlighted ? Palette.primary : Palette.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    accepted
                        ? Icons.check_circle
                        : denied
                            ? Icons.cancel
                            : Icons.radio_button_unchecked,
                    color: accepted
                        ? Colors.green
                        : denied
                            ? Colors.red
                            : Palette.neutral500,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    rideRequest.user.name ?? intl.passenger,
                    style: boldTextStyle(textColor(), FontSize.md),
                  ),
                  const Spacer(),
                  PemoRating(5, color: highlighted ? Palette.white : Palette.primary),
                ],
              ),
              if (asHistory || asOwner) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      formatDate(rideRequest.ride.ride.startsAt),
                      style: textStyle(textColor(), FontSize.sm),
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
                          rideRequest.ride.placeFrom,
                          style: textStyle(textColor(), FontSize.sm),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          rideRequest.ride.placeTo,
                          style: textStyle(textColor(), FontSize.sm),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
