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

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  bool isLoading = false;
  String email = '';
  final _formKey = GlobalKey<FormState>();

  bool validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  forgetPassword() async {
    try {
      setState(() {
        isLoading = true;
      });
      var body = json.encode({"email": email});
      var result =
          await http.post(Uri.parse(Constants.App_url + Constants.forgetPass),
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
        Fluttertoast.showToast(
          msg: response['message'],
          toastLength: Toast.LENGTH_SHORT,
          webBgColor: "#e74c3c",
          timeInSecForIosWeb: 5,
        );

        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
          msg: response['message'],
          toastLength: Toast.LENGTH_SHORT,
          webBgColor: "#e74c3c",
          timeInSecForIosWeb: 5,
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: "#e74c3c",
        timeInSecForIosWeb: 5,
      );
      setState(() {
        isLoading = false;
      });
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
            "Forgot password",
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
                        "Email :",
                        style: TextStyle(
                            fontSize: 16,
                            color: Color(Constants.blackColor),
                            fontFamily: "AvenirLTProBlack"),
                      )),
                  Container(
                    margin: styles.ThemeText.topMargin,
                    child: Theme(
                      data: styles.ThemeText.textInputThemeData,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter email';
                          } else {
                            if (validateEmail(value)) {
                              setState(() {
                                email = value;
                              });
                            } else {
                              return 'Incorrect email format';
                            }
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        style: styles.ThemeText.normalTextStyle,
                        maxLines: 1,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.mail_outline),
                          contentPadding: styles.ThemeText.InputTextProperties,
                          hintText: 'Email address',
                          border: styles.ThemeText.inputOutlineBorder,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: pageWidth,
                    height: 50,
                    margin: styles.ThemeText.margin1,
                    child: RaisedButton(
                      color: Color(Constants.primaryYellow),
                      shape: styles.ThemeText.borderRaidus1,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          print("passed");
                          forgetPassword();
                        }
                      },
                      child: isLoading
                          ? SpinKitThreeBounce(
                              color: Color(Constants.logocolor),
                              size: 20.0,
                            )
                          : Align(
                              child: Text(
                                'Submit',
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
