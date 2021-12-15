import '../customicons.dart';
import 'package:flutter/material.dart';
import '../constants.dart' as Constants;
import '../styles.dart' as styles;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../states/customerProfileState.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String msg = '';
  String email = '';
  String phone = '';
  String name = '';
  String subj = '';
  String message = '';
  final _formKey = GlobalKey<FormState>();

  sendFeedBack() async {
    message = "Subject : $subj \nMessage : $msg";
    print(message);
    final AuthState authState = Provider.of<AuthState>(context, listen: false);
    dynamic loginuserResponse = authState.getLoginUser;
    print(loginuserResponse['customerInfo']["cust_email"]);
    print(loginuserResponse['customerInfo']["cust_phone"]);
    print(loginuserResponse['customerInfo']["cust_firstname"]);
    print(loginuserResponse['customerInfo']["cust_lastname"]);
    email = loginuserResponse['customerInfo']["cust_email"];
    phone = loginuserResponse['customerInfo']["cust_phone"];
    name = loginuserResponse['customerInfo']["cust_firstname"] +
        " " +
        loginuserResponse['customerInfo']["cust_lastname"];
    print(name);
    Loader.show(context, progressIndicator: CupertinoActivityIndicator());

    var body = json.encode({
      "name": name,
      "email": email,
      "phone": phone,
      "message": msg,
    });
    var result =
        await http.post(Uri.parse(Constants.App_url + Constants.feedBack),
            headers: {
              "Content-Type": "application/json",
              'Accept': 'application/json',
            },
            body: body);
    Map<String, dynamic> response = json.decode(result.body);
    print(response);
    if (response["response"] == "success") {
      Fluttertoast.showToast(
        msg: response["message"],
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: "#e74c3c",
        timeInSecForIosWeb: 5,
      );
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
        msg: response["message"],
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: "#e74c3c",
        timeInSecForIosWeb: 5,
      );
    }
    Loader.hide();
  }

  @override
  Widget build(BuildContext context) {
    var pageWidth = MediaQuery.of(context).size.width;
    var pageHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
//        backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(CustomIcons.backarrow,
                color: Color(Constants.primaryYellow)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Color(Constants.logocolor),
          elevation: 16,
          title: Text(
            "Feedback/Enquiry",
            style: styles.ThemeText.appbarTextStyles2,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
              color: Color(Constants.white),
              width: pageWidth,
              height: pageHeight,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: Color(Constants.borderGreyColor),
                                width: 1.0))),
                    child: Container(
                      width: pageWidth,
                      margin: styles.ThemeText.margins,
                      padding: EdgeInsets.only(top: 20, bottom: 10),
                      child: Column(
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Theme(
                                  data: styles.ThemeText.textInputThemeData,
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Write Subject';
                                      } else {
                                        setState(() {
                                          subj = value;
                                        });
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    style: styles.ThemeText.normalTextStyle,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          styles.ThemeText.InputTextProperties,
                                      hintText: 'Subject',
                                      border:
                                          styles.ThemeText.inputOutlineBorder,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 20),
                                  child: Theme(
                                    data: styles.ThemeText.textInputThemeData,
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Write something';
                                        } else {
                                          setState(() {
                                            msg = value;
                                          });
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.emailAddress,
                                      style: styles.ThemeText.normalTextStyle,
                                      maxLines: 10,
                                      decoration: InputDecoration(
                                        contentPadding: styles
                                            .ThemeText.InputTextProperties,
                                        hintText: 'Type your feedback',
                                        border:
                                            styles.ThemeText.inputOutlineBorder,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: pageWidth,
                            height: 50,
                            child: RaisedButton(
                              color: Color(Constants.primaryYellow),
                              shape: styles.ThemeText.borderRaidus1,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  print("Pressed");
                                  sendFeedBack();
                                }
                              },
                              child: Align(
                                child: Text(
                                  'Send feedback',
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
                ],
              )),
        ));
  }
}
