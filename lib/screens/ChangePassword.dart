import '../customicons.dart';
import 'package:flutter/material.dart';
import '../styles.dart' as styles;
import '../constants.dart' as Constants;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../states/customerProfileState.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:flappy_search_bar/flappy_search_bar.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool currentpassHidden2 = true;
  bool currentpassHidden = true;
  bool currentpassHidden3 = true;
  String password = "";
  String password2 = "";
  String oldPassword = "";
  String? errorTextForPassword;
  int? customerId;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  changePass() async {
    setState(() {
      isLoading = true;
    });
    final AuthState authState = Provider.of<AuthState>(context, listen: false);
    dynamic loginuserResponse = authState.getLoginUser;
    if (loginuserResponse['isLogin']) {
      setState(() {
        customerId = loginuserResponse["customerInfo"]["cust_id"];
      });
    }
    var body = json.encode({
      "customerid": customerId,
      "old_password": oldPassword,
      "new_password": password
    });
    print(body);
    var result =
        await http.post(Uri.parse(Constants.App_url + Constants.changePass),
            headers: {
              "Content-Type": "application/json",
              'Accept': 'application/json',
            },
            body: body);

    Map<String, dynamic> response = json.decode(result.body);
    print(response);

    if (response["response"] == "success") {
      setState(() {
        isLoading = false;
      });
      final AuthState authState =
          Provider.of<AuthState>(context, listen: false);
      authState.saveLoginUser({"isLogin": false, "customerInfo": {}});
      Navigator.pushNamed(context, '/login');
      Fluttertoast.showToast(
        msg: response['message'],
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: "#e74c3c",
        timeInSecForIosWeb: 5,
      );
    }
    if (response["response"] == "failed") {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: response['message'],
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: "#e74c3c",
        timeInSecForIosWeb: 5,
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var pageWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Color(Constants.logocolor),

          //backgroundColor: Color(0x44ffffff),
          elevation: 16,
          title: Text(
            "Change password",
            style: styles.ThemeText.appbarTextStyles2,
          ),
          leading: IconButton(
            icon: Icon(CustomIcons.backarrow,
                color: Color(Constants.primaryYellow)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 20),
                      child: Text(
                        "Old password",
                        style: styles.ThemeText.buttonTextStyles,
                      )),
                  Container(
                    margin: styles.ThemeText.topMargin,
                    child: Theme(
                      data: styles.ThemeText.textInputThemeData,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your old password';
                          } else {
                            setState(() {
                              oldPassword = value;
                            });
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        style: styles.ThemeText.normalTextStyle,
                        maxLines: 1,
                        obscureText: currentpassHidden3,
                        decoration: InputDecoration(
                          suffixIcon: currentpassHidden3
                              ? IconButton(
                                  icon: Icon(
                                    Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      currentpassHidden3 = false;
                                    });
                                  },
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      currentpassHidden3 = true;
                                    });
                                  },
                                ),
                          prefixIcon: Icon(Icons.lock_outline),
                          contentPadding: styles.ThemeText.InputTextProperties,
                          hintText: 'Old password',
                          border: styles.ThemeText.inputOutlineBorder,
                        ),
                      ),
                    ),
                  ),
                  Container(
                      alignment: Alignment.centerLeft,
                      // margin: styles.ThemeText.margins,
                      margin: EdgeInsets.only(top: 20),
                      child: Text(
                        "New password",
                        style: styles.ThemeText.buttonTextStyles,
                      )),
                  Container(
                    margin: styles.ThemeText.topMargin,
                    child: Theme(
                      data: styles.ThemeText.textInputThemeData,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your new password';
                          } else if (value.length < 6) {
                            return 'Password must be 6 digits';
                          } else {
                            setState(() {
                              password = value;
                            });
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        style: styles.ThemeText.normalTextStyle,
                        maxLines: 1,
                        obscureText: currentpassHidden,
                        decoration: InputDecoration(
                          errorText: errorTextForPassword,
                          suffixIcon: currentpassHidden
                              ? IconButton(
                                  icon: Icon(
                                    Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      currentpassHidden = false;
                                    });
                                  },
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      currentpassHidden = true;
                                    });
                                  },
                                ),
                          prefixIcon: Icon(Icons.lock_outline),
                          contentPadding: styles.ThemeText.InputTextProperties,
                          hintText: 'New password',
                          border: styles.ThemeText.inputOutlineBorder,
                        ),
                      ),
                    ),
                  ),
                  Container(
                      alignment: Alignment.centerLeft,
                      // margin: styles.ThemeText.margins,
                      margin: EdgeInsets.only(top: 20),
                      child: Text(
                        "Confirm password",
                        style: styles.ThemeText.buttonTextStyles,
                      )),
                  Container(
                    margin: styles.ThemeText.topMargin,
                    child: Theme(
                      data: styles.ThemeText.textInputThemeData,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your new password';
                          } else {
                            setState(() {
                              password2 = value;
                            });
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        style: styles.ThemeText.normalTextStyle,
                        maxLines: 1,
                        obscureText: currentpassHidden2,
                        decoration: InputDecoration(
                          errorText: errorTextForPassword,
                          suffixIcon: currentpassHidden2
                              ? IconButton(
                                  icon: Icon(
                                    Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      currentpassHidden2 = false;
                                    });
                                  },
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      currentpassHidden2 = true;
                                    });
                                  },
                                ),
                          prefixIcon: Icon(Icons.lock_outline),
                          contentPadding: styles.ThemeText.InputTextProperties,
                          hintText: 'Confirm new password',
                          border: styles.ThemeText.inputOutlineBorder,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: pageWidth,
                    height: 50,
                    margin: EdgeInsets.only(top: 20),
                    child: RaisedButton(
                      color: Color(Constants.primaryYellow),
                      shape: styles.ThemeText.borderRaidus1,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (password == password2) {
                            setState(() {
                              errorTextForPassword = null;
                            });

                            changePass();
                            print("passed");
                          } else {
                            setState(() {
                              errorTextForPassword = "Password mismatch";
                            });
                          }
                        }
                      },
                      child: isLoading
                          ? SpinKitThreeBounce(
                              color: Color(Constants.logocolor),
                              size: 20.0,
                            )
                          : Align(
                              child: Text(
                                'Change password',
                                style: styles.ThemeText.buttonTextStyles,
                                textAlign: TextAlign.center,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
