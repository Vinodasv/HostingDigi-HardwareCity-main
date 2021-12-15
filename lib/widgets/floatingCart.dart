import 'package:flutter/material.dart';
import '../styles.dart' as styles;
import '../constants.dart' as Constants;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:badges/badges.dart';
import '../customicons.dart';
import '../states/myCartState.dart';

import 'package:provider/provider.dart';
import '../states/customerProfileState.dart';

class FloatingCartWidget extends StatelessWidget {
  const FloatingCartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int customerId;
    final CartState cartItems = Provider.of<CartState>(context);
    final cartList = cartItems.cart;
    final AuthState authState = Provider.of<AuthState>(context, listen: false);
    dynamic loginuserResponse = authState.getLoginUser;
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
              style: TextStyle(color: Colors.black),
            ),
            badgeColor: Colors.white,
            child: Icon(CustomIcons.shoppingcart,
                color: Color(Constants.primaryYellow)),
          );
  }
}
