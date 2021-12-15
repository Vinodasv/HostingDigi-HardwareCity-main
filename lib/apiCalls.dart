import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import './constants.dart' as Constants;

class ApiCalls {
  Future<dynamic> _login(var body) async {
    var result = await http.post(Uri.parse(Constants.login),
        headers: {
          "Content-Type": "application/json",
        },
        body: body);
    Map<String, dynamic> response = json.decode(result.body);
    return response;
  }
}
