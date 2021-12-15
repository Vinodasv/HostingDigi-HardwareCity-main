import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// DiagnosticableTreeMixin
class AuthState with ChangeNotifier {
  Object loginUser = {"isLogin": false, "customerInfo": {}};
  Object get getLoginUser => loginUser;

  void saveLoginUser(Object loginObject) async {
    loginUser = loginObject;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', json.encode(loginObject));
    notifyListeners();
  }
}
