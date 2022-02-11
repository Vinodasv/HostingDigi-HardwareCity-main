import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart' as Constants;
import '../states/customerProfileState.dart';
import '../styles.dart' as styles;
import '../widgets/Loader.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String searchString = '';
  bool isLoading = false;

  setOpened() async {
    final prefs = await SharedPreferences.getInstance();

// set value

    prefs.setBool("opened", true);
  }

  @override
  void initState() {
    super.initState();
    setOpened();
  }

  bool _onBackPressed() {
    var option = showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Do you really want to close the app ?',
                  style: TextStyle(
                    color: Color(Constants.primaryBlack),
                    fontSize: 14,
                  )),
              actions: <Widget>[
                FlatButton(
                  child: Text('No'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(
                  child: Text('Yes'),
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                )
              ],
            ));
    return option as bool;
  }

  @override
  Widget build(BuildContext context) {
    var pageWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: WillPopScope(
        onWillPop: () async {
          return _onBackPressed();
        },
        child: SingleChildScrollView(
          child: Container(
              //height: MediaQuery.of(context).size.height,
              color: Color(Constants.logocolor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //  crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  SizedBox(
                    child: Container(
                      child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            // padding: styles.ThemeText.DefautlLeftRightPadding,
                            margin: const EdgeInsets.all(0),
                            child: Image(
                              width: MediaQuery.of(context).size.width * 0.6,
                              image: AssetImage('assets/images/logo1.png'),
                            ),
                          )),
                    ),
                  ),
                  Container(
                    decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(50.0),
                            topRight: const Radius.circular(50.0))),
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                            alignment: Alignment.center,
                            child: Container(
                              // padding: styles.ThemeText.DefautlLeftRightPadding,
                              margin: const EdgeInsets.all(30),
                              child: Text(
                                'Login',
                                style: styles.ThemeText.loginTextStyle,
                              ),
                            )),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.60,
                            child: LoginForm()),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
      bottomNavigationBar: Visibility(
          maintainSize: false,
          maintainAnimation: true,
          maintainState: true,
          child: Container(
            height: 60,

            //  margin: styles.ThemeText.buttonMargin,
            //  color: Color(Constants.textColor),
            decoration: new BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, //Center Row contents horizontally,
              crossAxisAlignment:
                  CrossAxisAlignment.center, //Center Row contents vertically,
              children: <Widget>[
                Text(
                  "Don't have an account? ",
                  style: styles.ThemeText.editProfileText2,
                ),
                // style: styles.ThemeText.defaultSubTitle),
                GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/registration');
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "AvenirLTProRoman",
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold),
                      // style: styles.ThemeText.flatBtnStyles
                    ))
              ],
            ),
          )),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  bool currentpassHidden = true;
  bool isLoading = false;
  String userName = '';
  String password = '';

  _login() async {
    try {
      print("called");
      setState(() {
        isLoading = true;
      });
      var body = json.encode({"username": userName, "password": password});
      print(body);
      print(Constants.login);
      var result =
          await http.post(Uri.parse(Constants.App_url + Constants.login),
              headers: {
                "Content-Type": "application/json",
              },
              body: body);
      print(result);
      Map<String, dynamic> response = json.decode(result.body);
      print(response);
      if (response["response"] == "success") {
        Fluttertoast.showToast(
          msg: response['message'],
          toastLength: Toast.LENGTH_SHORT,
          webBgColor: "#e74c3c",
          timeInSecForIosWeb: 5,
        );
        final AuthState authState =
            Provider.of<AuthState>(context, listen: false);
        final prefs = await SharedPreferences.getInstance();

        // print('saved $value');

        authState.saveLoginUser(
            {"isLogin": true, "customerInfo": response["customerdata"]});

        Navigator.pushNamed(context, '/bottomTab');
      } else {
        Fluttertoast.showToast(
          msg: response['message'],
          toastLength: Toast.LENGTH_SHORT,
          webBgColor: "#e74c3c",
          timeInSecForIosWeb: 5,
        );
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(),
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: <Widget>[
                Container(
                  margin: styles.ThemeText.topMargin,
                  child: Theme(
                    data: styles.ThemeText.textInputThemeData,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter email';
                        } else {
                          setState(() {
                            userName = value;
                          });
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
                  margin: styles.ThemeText.topMargin,
                  child: Theme(
                    data: styles.ThemeText.textInputThemeData,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter password';
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
                        hintText: 'Password',
                        border: styles.ThemeText.inputOutlineBorder,
                      ),
                    ),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(
                      top: 5,
                    ),
                    child: SizedBox(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/forgotPass');
                            },
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: "AvenirLTProRoman",
                                decoration: TextDecoration.underline,
                                //textBaseline: TextBaseline.alphabetic,
                              ),
                              // style: styles.ThemeText.subRedTitleStyles
                            ),
                          )),
                    )),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    margin: styles.ThemeText.topMargin,
                    child: RaisedButton(
                      color: Color(Constants.primaryYellow),
                      shape: styles.ThemeText.borderRaidus1,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _login();
                          // If the form is valid, display a Snackbar.

                        }
                      },
                      child: isLoading
                          ? LoadingWidget()
                          : Text(
                              'Login',
                              style: styles.ThemeText.buttonTextStyles,
                            ),
                    )),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    margin: styles.ThemeText.topMargin,
                    child: RaisedButton(
                      color: Colors.white,
                      shape: styles.ThemeText.borderRadiusOutLine,
                      onPressed: () {
                        Navigator.pushNamed(context, '/bottomTab');
                      },
                      child: Text(
                        'Continue as guest',
                        style: styles.ThemeText.buttonTextStyles2,
                      ),
                    )),
              ],
            ),
          ),
        ));
  }
}
