import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderRatingsScreen extends StatefulWidget {
  const OrderRatingsScreen({super.key});

  @override
  State<OrderRatingsScreen> createState() => _OrderRatingsScreenState();
}

class _OrderRatingsScreenState extends State<OrderRatingsScreen> {
  double userRating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.rating),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /* Silly Prompt */
            Text(
              AppLocalizations.of(context)!.rateYourOrder,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface),
            ),

            /* Spacing */
            SizedBox(
              height: 24.spMax,
            ),

            /* Rating Indicator */
            RatingBar(
              ratingWidget: RatingWidget(
                empty: Icon(
                  Icons.star_border_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                full: Icon(
                  Icons.star,
                  color: Theme.of(context).colorScheme.primary,
                ),
                half: Icon(
                  Icons.star_half,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              itemCount: 5,
              unratedColor: Theme.of(context).colorScheme.primary,
              glowColor: Theme.of(context).colorScheme.primary,
              initialRating: userRating,
              allowHalfRating: true,
              updateOnDrag: true,
              glow: true,
              onRatingUpdate: (value) => setState(() => userRating = value),
            ),

            /* Spacing */
            SizedBox(
              height: 96.spMax,
            ),

            /* Submit Rating */
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.confirm),
            )
          ],
        ),
      ),
    );
  }
}
