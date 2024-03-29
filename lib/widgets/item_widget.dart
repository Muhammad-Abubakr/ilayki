import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/items/items_bloc.dart';
import 'package:ilayki/blocs/user/user_bloc.dart';

import '../models/item.dart';

class ItemWidget extends StatelessWidget {
  final Item item;

  const ItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    Future<bool?> deleteItem(DismissDirection direction) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ItemsBloc>().add(
                      ItemsDeleteEvent(
                        userUID: context.read<UserBloc>().state.user!.uid,
                        itemFID: item.id,
                      ),
                    );
                Navigator.of(context).pop(true);
              },
              child: Text(AppLocalizations.of(context)!.confirm),
            ),
          ],
          title: Text(AppLocalizations.of(context)!.confirmationDialog),
          content: Text(AppLocalizations.of(context)!.confirmRemoval),
        ),
      );
    }

    /* Wrapping in dismissable for deletion */
    return Dismissible(
      direction: DismissDirection.endToStart,
      background: _buildDismissibleBackground(),
      confirmDismiss: deleteItem,
      key: UniqueKey(),
      child: Padding(
        padding: EdgeInsets.only(right: 8.0.w),
        /* Item */
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /* Item Image */
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(24.r)),
                color: Theme.of(context).primaryColor,
                image: DecorationImage(
                  image: Image.network(item.image).image,
                  fit: BoxFit.cover,
                ),
              ),
              width: 64.spMax,
              height: 64.spMax,
            ),
            Column(
              children: [
                /* Item Name */
                Text(
                  item.name,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                  softWrap: true,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                /* Item Description */
                SizedBox(
                  width: 296.w,
                  child: Text(
                    item.description,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            /* Price Text */
            Column(
              children: [
                Text('\$${item.price}'),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Theme.of(context).primaryColor,
                    ),
                    Text(
                        "${item.rating ?? AppLocalizations.of(context)!.noRating} (${item.ratingCount})")
                  ],
                )
              ],
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        /* Update the State of Items List which will in turn update this */
      },
    );
  }

// Generator Method
  Widget _buildDismissibleBackground() {
    return Container(
      padding: EdgeInsets.only(right: 24.spMax),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        color: Colors.redAccent,
      ),
      child: const Icon(Icons.delete_sweep, color: Colors.white),
    );
  }
}
