import 'package:flutter/material.dart';

import '../styles.dart' as styles;
import '../constants.dart' as Constants;
import 'dart:async';
import '../states/myCartState.dart';

import 'package:provider/provider.dart';
import '../states/customerProfileState.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebaseStorage.dart';
import '../customicons.dart';

class CustomerProfileScreen extends StatefulWidget {
  @override
  _CustomerProfileScreenState createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  String searchString = '';
  bool isLoading = true;
  String storeId = '';
  String firstName = '';
  String mailID = '';
  String mobileNumber = '';
  String lastName = '';
  String customerId = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10), () {
      print("called");
      this._checkLogin();
    });
  }

  _logOut() async {
    cartModify(0, customerId, firstName);
    final AuthState authState = Provider.of<AuthState>(context, listen: false);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('images');
    authState.saveLoginUser({"isLogin": false, "customerInfo": {}});
    final CartState cartItems = Provider.of<CartState>(context, listen: false);
    var cartList = cartItems.cart;
    cartList = [];
    cartItems.saveCart(cartList);
    Navigator.pushNamed(context, '/login');
  }

  _onlogOutPressed() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                  'Do you really want to log out, once logged out cart will be cleared?',
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
                    _logOut();
                    Navigator.pop(context, false);
                  },
                )
              ],
            ));
  }

  _checkLogin() async {
    print("called");

    final AuthState authState = Provider.of<AuthState>(context, listen: false);
    dynamic loginuserResponse = authState.getLoginUser;
    print(loginuserResponse);
    print(loginuserResponse['isLogin']);

    if (loginuserResponse['isLogin']) {
      setState(() {
        firstName = loginuserResponse['customerInfo']["cust_firstname"];
        lastName = loginuserResponse['customerInfo']["cust_lastname"];
        mailID = loginuserResponse['customerInfo']["cust_email"];
        customerId = loginuserResponse['customerInfo']["cust_id"].toString();
      });
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    var pageWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Color(Constants.logocolor),
          // backgroundColor: Color(0x44ffffff),
          elevation: 16,
          title: Text(
            "Profile",
            style: styles.ThemeText.appbarTextStyles2,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(

              //  padding: styles.ThemeText.defaultfontStyles,
              child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // SpinKitCircle(
              //   color: Color(0xFF1BC47D),
              //   size: 50.0,
              // ),

              Container(
                  height: 100,
                  color: Colors.grey[200],
                  padding: EdgeInsets.fromLTRB(16, 0, 0, 10),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisAlignment:
                          // MainAxisAlignment
                          //     .start,
                          MainAxisAlignment.spaceBetween,
                      // crossAxisAlignment:CrossAxisAlignment.stretch,
                      //  verticalDirection:VerticalDirection.up,
                      children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Stack(
                                children: <Widget>[
                                  Container(
                                      width: 70,
                                      height: 70,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(300),
                                          child: Image.asset(
                                              "assets/images/user.png"))),
                                ],
                              ),
                              SizedBox(
                                  // width: 100,
                                  child: Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 5),
                                                    child: Row(
                                                      children: <Widget>[
                                                        SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                2,
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                  firstName ==
                                                                              null &&
                                                                          lastName ==
                                                                              null
                                                                      ? ''
                                                                      : firstName +
                                                                          " " +
                                                                          lastName,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: styles
                                                                      .ThemeText
                                                                      .editProfileText
                                                                  // style: TextStyle(color: Color(Constants.textColor)
                                                                  // )
                                                                  ),
                                                            )),
                                                        /*  Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left: 2),
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topLeft,
                                                                    child: Text(
                                                                        lastName ==
                                                                                null
                                                                            ? ''
                                                                            : lastName,
                                                                        textAlign:
                                                                            TextAlign
                                                                                .left,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Color(Constants.textColor))
                                                                        // style: TextStyle(color: Color(Constants.textColor)
                                                                        // )
                                                                        ),
                                                                  ))*/
                                                      ],
                                                    ))),
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 5),
                                                    child: Container(
                                                        child: Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                                mailID == null
                                                                    ? ""
                                                                    : mailID,
                                                                style: styles
                                                                    .ThemeText
                                                                    .editProfileText2
                                                                // style: TextStyle(color: Color(Constants.textColor)
                                                                // )
                                                                ))))),
                                            // SizedBox(
                                            //     width: MediaQuery.of(context)
                                            //             .size
                                            //             .width /
                                            //         2,
                                            //     child: Container(
                                            //         padding:
                                            //             const EdgeInsets.only(
                                            //                 bottom: 5),
                                            //         child: Container(
                                            //             child: Text(
                                            //                 mobileNumber ==
                                            //                         null
                                            //                     ? ""
                                            //                     : mobileNumber,
                                            //                 style: TextStyle()
                                            //                 // style: TextStyle(color: Color(Constants.textColor)
                                            //                 // )
                                            //                 )))),

                                            //   Align(
                                            //           alignment: Alignment.topLeft,

                                            // child: Container(
                                            //     padding:
                                            //         const EdgeInsets.only(
                                            //             bottom: 5),
                                            //     child:
                                            //     SizedBox(
                                            //                                                         width: 100,
                                            //           child:
                                            //      RaisedButton(
                                            //       onPressed: () {
                                            //  final AuthState authState = Provider.of<AuthState>(context, listen: false);
                                            //  authState.saveLoginUser({
                                            //     "isLogin":false,
                                            //     "token":"",
                                            //     "user":{},
                                            //     "userType":"",
                                            //     "phoneNo":""
                                            //   });
                                            //    Navigator.pushNamed(context, '/login');
                                            //         },
                                            //         child:Text(
                                            //            'Login',
                                            //             style: TextStyle()
                                            //             // style: TextStyle(color: Color(Constants.textColor)
                                            //             // )
                                            //             ))))),
                                          ])))
                            ]),
                        Container(
                            decoration: BoxDecoration(
                              color: Color(Constants.primaryYellow),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                            ),
                            width: 50,
                            height: 50,
                            child: IconButton(
                                icon: Icon(
                                  Icons.navigate_next,
                                  size: 30,
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(
                                          context, '/editProfileScreen')
                                      .then((value) {
                                    if (value == "edited") {
                                      _checkLogin();
                                    } // if true and you have come back to your Settings screen
                                  });
                                }))
                      ],
                    ),
                  )),
              Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Column(children: <Widget>[
                    new GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/favScreen');
                          // Navigator.pushNamed(context, '/edit-profile')
                          //     .then((value) => {
                          //           if (value == "editProfile")
                          //            // {this._checkLogin()
                          //             }
                          //         });
                        },
                        child: Container(
                            margin: const EdgeInsets.only(
                                left: 16, right: 16, top: 5, bottom: 5),
                            padding: const EdgeInsets.only(top: 15, bottom: 20),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color(Constants.borderGreyColor),
                                        width: 1.0))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Icon(
                                  Icons.favorite,
                                  size: 24,
                                  color: Color(Constants.grey),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.55,
                                  child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text('My Favourite',
                                          style: styles
                                              .ThemeText.profileTitlesStyles)),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_right,
                                  size: 24,
                                ),
                              ],
                            ))),
                            new GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/myOrders',arguments: {
                            "from":"123",
                          });
                        },
                        child: Container(
                            margin: const EdgeInsets.only(
                                left: 16, right: 16, top: 5, bottom: 5),
                            padding: const EdgeInsets.only(top: 15, bottom: 20),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color(Constants.borderGreyColor),
                                        width: 1.0))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Icon(
                                  CustomIcons.shoppingbag,
                                  size: 24,
                                  color: Color(Constants.grey),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.55,
                                  child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text('My Orders',
                                          style: styles
                                              .ThemeText.profileTitlesStyles)),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_right,
                                  size: 24,
                                ),
                              ],
                            ))),
                    new GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/feedbackScreen');
                          //
                        },
                        child: Container(
                            margin: const EdgeInsets.only(
                                left: 16, right: 16, top: 5, bottom: 5),
                            padding: const EdgeInsets.only(top: 15, bottom: 20),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color(Constants.borderGreyColor),
                                        width: 1.0))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Icon(
                                  Icons.feedback,
                                  size: 24,
                                  color: Color(Constants.grey),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.55,
                                  child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text('Feedback/Enquiry',
                                          style: styles
                                              .ThemeText.profileTitlesStyles)),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_right,
                                  size: 24,
                                ),
                              ],
                            ))),
                    new GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/T&C');
                        },
                        child: Container(
                            margin: const EdgeInsets.only(
                                left: 16, right: 16, top: 5, bottom: 5),
                            padding: const EdgeInsets.only(top: 15, bottom: 20),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color(Constants.borderGreyColor),
                                        width: 1.0))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Icon(
                                  Icons.settings,
                                  size: 24,
                                  color: Color(Constants.grey),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.55,
                                  child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text('Terms & shipping policy',
                                          style: styles
                                              .ThemeText.profileTitlesStyles)),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_right,
                                  size: 24,
                                ),
                              ],
                            ))),
                    new GestureDetector(
                        onTap: () {
                          _onlogOutPressed();
                        },
                        child: Container(
                            margin: const EdgeInsets.only(
                                left: 16, right: 16, top: 5, bottom: 5),
                            padding: const EdgeInsets.only(top: 15, bottom: 20),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color(Constants.borderGreyColor),
                                        width: 1.0))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Icon(
                                  Icons.exit_to_app,
                                  size: 24,
                                  color: Color(Constants.redColor),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.55,
                                  child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text('Log out',
                                          style: styles
                                              .ThemeText.profileTitlesStyles)),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_right,
                                  size: 24,
                                ),
                              ],
                            )))
                  ])),
            ],
          )),
        ));
  }
}
