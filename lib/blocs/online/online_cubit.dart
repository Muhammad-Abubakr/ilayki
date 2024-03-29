import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

part 'online_state.dart';

class OnlineCubit extends Cubit<OnlineState> {
  /* getting the firebase database singleton root ref */
  final _database = FirebaseDatabase.instance.ref();

  /* getting the reference to the online users in database */
  late final _onlineUsersRef = _database.child("online");

  /* stream holder */
  late StreamSubscription _onlineStream;

  /* Constructor */
  OnlineCubit() : super(const OnlineInitial([]));

  // intialization of the online users cubit
  void initialize() {
    // get all the online users snapshot
    _onlineStream = _onlineUsersRef.onValue.listen((event) {
      /* Uids Container which after mapping from the snapshot is set as the state */
      List<String> uids = List.empty(growable: true);

      // get the data from the snapshot
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      // if we have any data
      if (data != null) {
        // for each key in data as keys are uids of our users
        for (var uid in data.keys) {
          uids.add(uid.toString());
        }
      }
      if (kDebugMode) {
        print('Online Users: $uids');
      }
      // after the stream emit the state
      emit(OnlineUpdated(uids));
    });
  }

  // is this user online
  bool isOnline(String uid) {
    return state.onlineUsers.contains(uid);
  }

  // set online
  void setOnline() async {
    // keeping the ref to signed in user
    late DatabaseReference signedInUserRef;

    // put the value to the onlineUsers ref if signed in and remove if signed out
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && !isOnline(user.uid)) {
      // getting the ref to the user
      signedInUserRef = _onlineUsersRef.child(user.uid);

      // setting the timestamp as to when the user logged in
      await signedInUserRef.set({"timestamp": '${DateTime.now()}'});
    }
  }

  // set offline
  void setOffline() async {
    // keeping the ref to signed in user
    late DatabaseReference signedInUserRef;

    // put the value to the onlineUsers ref if signed in and remove if signed out
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // getting the ref to the user
      signedInUserRef = _onlineUsersRef.child(user.uid);

      // setting to offline
      await signedInUserRef.remove();
    }
  }

  // disposing the stream
  void dispose() async {
    await _onlineStream.cancel();

    // clearing the state
    emit(const OnlineUpdated([]));
    if (kDebugMode) {
      print("Cancelling the online users stream...");
    }
  }
}
