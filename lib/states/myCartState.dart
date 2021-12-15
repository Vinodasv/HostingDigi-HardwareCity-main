import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// DiagnosticableTreeMixin
class CartState with ChangeNotifier {
  List cart = [];
  List get getCart => cart;

  void saveCart(dynamic cartObject) async {
    cart = cartObject;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cart', json.encode(cartObject));
    notifyListeners();
  }

//   _mapTodoData(todos) async{
//   try {
//       var res = todos.map((v) => json.encode(v)).toList();
//       return res;
//     } catch (err) {
//      // Just in case
//       return [];
//     }
//  }

}
