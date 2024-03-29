import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:ilayki/models/order.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  /* acquiring the database reference */
  final DatabaseReference _orders = FirebaseDatabase.instance.ref('orders');
  final DatabaseReference _requests = FirebaseDatabase.instance.ref('requests');

  /* Streams Subscription */
  late StreamSubscription _stream;

  OrdersCubit() : super(const OrdersInitial([]));

  /* initialize */
  void initialize() {
    // get the orders that are only for the current user
    _stream = _orders.onValue.listen((event) async {
      // get the current user
      final myUID = FirebaseAuth.instance.currentUser?.uid;

      /* container for orders */
      final List<Order> allOrders = List.empty(growable: true);

      // extract the data
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      // if the data exists
      if (data != null) {
        // filter the keys
        for (var key in data.keys) {
          // checking if the owner id is this user
          // print(key.toString().split('+')[0]);
          // print(myUID);
          if (key.toString().split('+')[0] == myUID) {
            // set this key as the ref to our requests
            final ordersRef = _orders.child(key);

            // print(ordersRef);
            // get all the orders between these two users
            final data =
                (await ordersRef.get()).value as Map<dynamic, dynamic>?;

            if (data != null) {
              // print(data.values);
              // for each order in the orders
              for (var order in data.values) {
                // parse each order to Order
                final parsedOrder = Order.fromJson(order.toString());

                // print(parsedOrder);
                // add to container
                allOrders.add(parsedOrder);
              }
            }
          }
        }
      }

      emit(OrdersUpdate(allOrders));
    });
  }

  void markCompleted(Order order) async {
    final requestRef = FirebaseDatabase.instance
        .ref('requests/${order.buyerID}+${order.sellerID}/${order.refID}');
    final orderRef =
        _orders.child('${order.buyerID}+${order.sellerID}/${order.refID}');
    final notificationsRef =
        FirebaseDatabase.instance.ref('notifications/${order.buyerID}');
    final notificationRef = notificationsRef.push();

    //   Approach change from deleting to updating the status of the order
    //   and placing it in the orders along with the requests so for that we
    //   will need to get the order and then update the status of the order
    final data = await requestRef.get();

    if (data.value != null) {
      final request = jsonDecode(data.value.toString());

      // parse each request to Order
      final parsedRequest = Order.fromJson(json.encode(request));
      final updatedRequest = parsedRequest.copyWith(
          status: OrderStatus.completed, time: DateTime.now());
      await requestRef.set(updatedRequest.toJson());
      await orderRef.set(updatedRequest.toJson());
      await notificationRef.set(updatedRequest.toJson());
    }
  }

  /* disposing the stream */
  void dispose() async {
    await _stream.cancel();

    // clearing the state
    emit(const OrdersUpdate([]));

    if (kDebugMode) {
      print("Cancelling order stream...");
    }
  }
}
