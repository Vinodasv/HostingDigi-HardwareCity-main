import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> cartModify(int length, String custId, String name) async {
  if (custId != 'null') {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String? firebaseToken = await firebaseMessaging.getToken();
    CollectionReference cart = FirebaseFirestore.instance.collection('cart');
    bool avail;
    if (length == 0) {
      avail = true;
    } else {
      avail = false;
    }
    await cart
        .doc(custId)
        .set({"isEmpty": avail, "token": firebaseToken, "name": name});
  }
  return;
}
