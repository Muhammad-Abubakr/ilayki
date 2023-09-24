// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'orderitem.dart';

enum OrderType { pickup, delivery }

class Order {
  final String refID;
  final String buyerID;
  final String sellerID;
  final List<OrderItem> orderItems;
  final TimeOfDay pickupTime;
  final DateTime time;
  final double totalPrice;
  final OrderType orderType;

  Order({
    required this.refID,
    required this.buyerID,
    required this.sellerID,
    required this.pickupTime,
    required this.orderItems,
    required this.time,
    required this.totalPrice,
    required this.orderType,
  });

  Order copyWith({
    String? refID,
    String? buyerID,
    String? sellerID,
    List<OrderItem>? orderItems,
    DateTime? time,
    double? totalPrice,
    OrderType? orderType,
    TimeOfDay? pickupTime,
  }) {
    return Order(
      orderType: orderType ?? this.orderType,
      refID: refID ?? this.refID,
      buyerID: buyerID ?? this.buyerID,
      pickupTime: pickupTime ?? this.pickupTime,
      sellerID: sellerID ?? this.sellerID,
      orderItems: orderItems ?? this.orderItems,
      time: time ?? this.time,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'refID': refID,
      'buyerID': buyerID,
      'sellerID': sellerID,
      'pickupTime': "${pickupTime.hour}:${pickupTime.minute}",
      'orderType': describeEnum(orderType),
      'orderItems': orderItems.map((x) => x.toMap()).toList(),
      'time': time.millisecondsSinceEpoch,
      'totalPrice': totalPrice,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      refID: map['refID'] as String,
      buyerID: map['buyerID'] as String,
      sellerID: map['sellerID'] as String,
      pickupTime: TimeOfDay(
          hour: int.parse(map['pickupTime'].split(':')[0]),
          minute: int.parse(map['pickupTime'].split(':')[1])),
      orderType: OrderType.values
          .firstWhere((element) => describeEnum(element) == map['orderType']),
      orderItems: List<OrderItem>.from(
        (map['orderItems'] as List<dynamic>).map<OrderItem>(
          (x) => OrderItem.fromMap(x as Map<String, dynamic>),
        ),
      ),
      time: DateTime.fromMillisecondsSinceEpoch(map['time'] as int),
      totalPrice: map['totalPrice'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Order(refID: $refID, buyerID: $buyerID, pickupTime: $pickupTime, sellerID: $sellerID, orderType: $orderType, orderItems: $orderItems, time: $time, totalPrice: $totalPrice)';
  }

  @override
  bool operator ==(covariant Order other) {
    if (identical(this, other)) return true;

    return other.refID == refID &&
        other.buyerID == buyerID &&
        other.sellerID == sellerID &&
        other.orderType == orderType &&
        other.pickupTime == pickupTime &&
        listEquals(other.orderItems, orderItems) &&
        other.time == time &&
        other.totalPrice == totalPrice;
  }

  @override
  int get hashCode {
    return refID.hashCode ^
        buyerID.hashCode ^
        orderType.hashCode ^
        pickupTime.hashCode ^
        sellerID.hashCode ^
        orderItems.hashCode ^
        time.hashCode ^
        totalPrice.hashCode;
  }
}
