import '../customicons.dart';
import 'package:flutter/material.dart';
import '../constants.dart' as Constants;
import 'dart:convert';
import './profileScreen.dart';
import './AllItems.dart';
import './categoryHome.dart';
import './homeScreen.dart';
import './myOrders.dart';
import './myCart.dart';
import 'package:badges/badges.dart';

import 'package:flutter/services.dart';
import '../states/customerProfileState.dart';
import 'package:provider/provider.dart';
import './LoginScreen.dart';
import '../states/myCartState.dart';

import 'package:provider/provider.dart';

class CartScreenChoose extends StatefulWidget {
  @override
  _CartScreenChooseState createState() => _CartScreenChooseState();
}

class _CartScreenChooseState extends State<CartScreenChoose> {
  bool isLogedin = false;

  @override
  Widget build(BuildContext context) {
    final AuthState authState = Provider.of<AuthState>(context);
    var loginuserResponse = authState.getLoginUser;
    var body = json.encode(loginuserResponse);
    var body2 = json.decode(body);
    setState(() {
      isLogedin = body2['isLogin'];
    });
    return ["", null, false, 0].contains(isLogedin)
        ? LoginScreen()
        : MyCartScreen();
  }
}

class MyOrdersScreenChoose extends StatefulWidget {
  @override
  _MyOrdersScreenChooseState createState() => _MyOrdersScreenChooseState();
}

class _MyOrdersScreenChooseState extends State<MyOrdersScreenChoose> {
  bool isLogedin = false;
  @override
  Widget build(BuildContext context) {
    final AuthState authState = Provider.of<AuthState>(context);
    var loginuserResponse = authState.getLoginUser;
    var body = json.encode(loginuserResponse);
    var body2 = json.decode(body);
    setState(() {
      isLogedin = body2['isLogin'];
    });
    return ["", null, false, 0].contains(isLogedin)
        ? LoginScreen()
        : MyOrdersScreen();
  }
}

class ProfileScreenChoose extends StatefulWidget {
  @override
  _ProfileScreenChooseState createState() => _ProfileScreenChooseState();
}

class _ProfileScreenChooseState extends State<ProfileScreenChoose> {
  bool isLogedin = false;

  @override
  Widget build(BuildContext context) {
    final AuthState authState = Provider.of<AuthState>(context);
    var loginuserResponse = authState.getLoginUser;
    var body = json.encode(loginuserResponse);
    var body2 = json.decode(body);
    setState(() {
      isLogedin = body2['isLogin'];
    });
    return ["", null, false, 0].contains(isLogedin)
        ? LoginScreen()
        : CustomerProfileScreen();
  }
}

class HomeDashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomeDashScreen> {
  bool isLogedin = false;

  final _children = [
    HomeScreen(),
    // CategoryHomeScreen(),

    MyCartScreen(),
    MyOrdersScreenChoose(),
    AllItemsSearchScreen(),
    ProfileScreenChoose(),
    // WelcomeScreen()
  ];

  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final AuthState authState = Provider.of<AuthState>(context);
    // var loginuserResponse = authState.getLoginUser;
    // var body = json.encode(loginuserResponse);
    // var body2 = json.decode(body);
    // setState(() {
    //   isLogedin = body2['isLogin'];
    // });

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
                      /*  final AuthState authState =
                          Provider.of<AuthState>(context, listen: false);
                      authState.saveLoginUser({
                        "isLogin": false,
                        "token": "",
                        "user": {},
                        "userType": "",
                        "phoneNo": ""
                      });*/
                      // Navigator.pushNamed(context, '/login');
                    },
                  )
                ],
              ));
      return option as bool;
    }

    return WillPopScope(
        onWillPop: () async {
          return _onBackPressed();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: _children[_currentIndex], // new
          bottomNavigationBar: BottomNavigationBar(
            onTap: onTabTapped, // new
            selectedIconTheme: IconThemeData(
              color: Color(Constants.primaryBlack),
            ),
            showSelectedLabels: false,
            iconSize: 25,
            showUnselectedLabels: false,
            unselectedIconTheme: IconThemeData(color: Colors.black26),

            currentIndex: _currentIndex, // new
            items: [
              new BottomNavigationBarItem(
                icon: Icon(
                  CustomIcons.home,
                ),
                title: Text('Home'),
              ),
              new BottomNavigationBarItem(
                icon: CartIconForBottom(),
                title: Text('MyCart'),
              ),
              // new BottomNavigationBarItem(
              //   icon: Icon(Icons.search),
              //   title: Text('Messages'),
              // ),
              new BottomNavigationBarItem(
                  icon: Icon(CustomIcons.shoppingbag), title: Text('MyOrders')),
              new BottomNavigationBarItem(
                icon: Icon(Icons.search),
                title: Text('Search'),
              ),
              new BottomNavigationBarItem(
                  icon: Icon(CustomIcons.profile), title: Text('Profile'))
            ],
          ),
        ));
  }
}

class CartIconForBottom extends StatelessWidget {
  const CartIconForBottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int customerId;
    final AuthState authState = Provider.of<AuthState>(context, listen: false);
    dynamic loginuserResponse = authState.getLoginUser;
    final CartState cartItems = Provider.of<CartState>(context);
    final cartList = cartItems.cart;
    if (loginuserResponse['isLogin']) {
      customerId = loginuserResponse["customerInfo"]["cust_id"];
    }

    var count = 0;
    for (var u in cartList) {
      count = count + 1;
    }
    return count == 0
        ? Icon(
            CustomIcons.shoppingcart,
          )
        : Badge(
            badgeContent: Text(
              count.toString(),
              style: TextStyle(
                  color: Colors.yellow, fontFamily: "AvenirLTProMedium"),
            ),
            badgeColor: Colors.black,
            child: Icon(
              CustomIcons.shoppingcart,
            ),
          );
  }
}
