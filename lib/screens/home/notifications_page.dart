import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/notifications/notifications_cubit.dart';
import 'package:ilayki/blocs/requests/requests_cubit.dart';
import 'package:ilayki/blocs/userbase/userbase_cubit.dart';
import 'package:ilayki/models/order.dart';
import 'package:ilayki/models/user.dart';
import 'package:ilayki/screens/chat/chat_room_screen.dart';

import '../../blocs/user/user_bloc.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // userbase cubit
    final UserbaseCubit userbaseCubit = context.watch<UserbaseCubit>();
    final NotificationsCubit notificationsCubit =
        context.watch<NotificationsCubit>();
    final notifications = notificationsCubit.state.notifications;

    // User Bloc for getting current user uid
    final UserBloc userBloc = context.watch<UserBloc>();
    final me = userBloc.state.user;

    // request cubit
    final RequestsCubit requestsCubit = context.watch<RequestsCubit>();
    final requests = requestsCubit.state.requests;

    // all
    final all = [...requests, ...notifications];
    all.sort((a, b) => a.time.compareTo(b.time));

    print(all.length);
    print(notifications.length);
    print(requests.length);

    return all.isEmpty
        ? Center(
            child: Text(AppLocalizations.of(context)!.allCaughtUp),
          )
        : ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final notification = all[index];
              final buyer = userbaseCubit.getUser(notification.buyerID);

              return notification.status == OrderStatus.pending
                  ? me != null && notification.ownerId != me.uid
                      ? _buildRequestSentWidget(
                          context,
                          requestsCubit,
                          buyer,
                          notification,
                        )
                      : _buildAcceptanceOrDenialWidget(
                          context,
                          requestsCubit,
                          buyer,
                          notification,
                        )
                  : _buildOrderNotificationWidget(
                      context,
                      requestsCubit,
                      buyer,
                      notification,
                    );
            },
            itemCount: all.length,
          );
  }

  // description parser
  String orderParser(BuildContext context, Order request) {
    String order =
        '${AppLocalizations.of(context)!.price}: ${request.totalPrice.toString()}\n';

    for (var orderItem in request.orderItems) {
      order = '$order${orderItem.item.name} : ${orderItem.quantity}\n';
    }

    return order;
  }

  Widget _buildAcceptanceOrDenialWidget(
    BuildContext context,
    RequestsCubit requestsCubit,
    User buyer,
    Order request,
  ) {
    return ListTile(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      /* Buyer Pfp */
      leading: Container(
        margin: EdgeInsets.all(6.0.h),
        padding: EdgeInsets.all(6.0.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1.sw),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: GestureDetector(
          onTap: () => Navigator.of(context)
              .pushNamed(ChatRoomScreen.routeName, arguments: {
            "currentUser": request.sellerID,
            "itemOwner": buyer,
          }),
          child: CircleAvatar(
            backgroundImage:
                Image.network(buyer.photoURL, fit: BoxFit.cover).image,
          ),
        ),
      ),

      /* Buyer name */
      title: Text(
        "Ref#${request.productId}",
        textDirection: TextDirection.ltr,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),

      /* Items description */
      subtitle: Text(orderParser(context, request)),

      /* trailing button to accept order */
      trailing: SizedBox(
        width: 0.25.sw,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => requestsCubit.decline(request),
              child: CircleAvatar(
                backgroundColor: Colors.redAccent.withOpacity(0.8),
                child: const Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => requestsCubit.accept(request),
              child: CircleAvatar(
                backgroundColor: Colors.green.withOpacity(0.8),
                child: const Icon(
                  Icons.add_circle,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildOrderNotificationWidget(BuildContext context,
      RequestsCubit requestsCubit, User buyer, Order request) {
    return ListTile(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      /* Buyer Pfp */
      leading: Container(
        margin: EdgeInsets.all(6.0.h),
        padding: EdgeInsets.all(6.0.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1.sw),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: GestureDetector(
          onTap: () => Navigator.of(context)
              .pushNamed(ChatRoomScreen.routeName, arguments: {
            "currentUser": request.sellerID,
            "itemOwner": buyer,
          }),
          child: CircleAvatar(
            backgroundImage:
                Image.network(buyer.photoURL, fit: BoxFit.cover).image,
          ),
        ),
      ),

      /* Buyer name */
      title: Text(
        "Ref#${request.productId}",
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),

      /* Items description */
      subtitle: Text(orderParser(context, request)),

      /* trailing button to accept order */
      trailing: Text("Status: ${describeEnum(request.status)}"),
    );
  }

  _buildRequestSentWidget(BuildContext context, RequestsCubit requestsCubit,
      User buyer, Order notification) {
    return ListTile(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      /* Buyer Pfp */
      leading: Container(
        margin: EdgeInsets.all(6.0.h),
        padding: EdgeInsets.all(6.0.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1.sw),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: GestureDetector(
          onTap: () => Navigator.of(context)
              .pushNamed(ChatRoomScreen.routeName, arguments: {
            "currentUser": notification.sellerID,
            "itemOwner": buyer,
          }),
          child: CircleAvatar(
            backgroundImage:
                Image.network(buyer.photoURL, fit: BoxFit.cover).image,
          ),
        ),
      ),

      /* Buyer name */
      title: Text(
        "${notification.status == OrderStatus.pending ? "Request Sent" : notification.status == OrderStatus.denied ? "Request Denied" : notification.status == OrderStatus.completed ? "Order Completed" : "Request Accepted"} - Ref#${notification.productId}",
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),

      /* Items description */
      subtitle: Text(orderParser(context, notification)),

      /* trailing button to accept order */
      trailing: Text("Status: ${describeEnum(notification.status)}"),
    );
  }
}
