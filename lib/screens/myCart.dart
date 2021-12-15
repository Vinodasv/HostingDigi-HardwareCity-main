import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../constants.dart' as Constants;
import '../customicons.dart';
import '../models/HomeScreenModels.dart';
import '../services/firebaseStorage.dart';
import '../states/customerProfileState.dart';
import '../states/myCartState.dart';
import '../styles.dart' as styles;

class MyCartScreen extends StatefulWidget {
  @override
  _MyCartScreenState createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  bool isBrandLoading = false;
  List<CartDataType> stateItems = [];
  double gst = 0.0;
  double? total;
  double subtotal = 0.0;
  int? customerId;
  String productId = "";
  bool isBottomTab = true;
  String customerName = '';

  removeCartItem(itemId) async {
    List<CartDataType> itemsTemp = [];
    final CartState cartItems = Provider.of<CartState>(context, listen: false);
    var cartList = cartItems.cart;
    cartList.removeWhere((item) => item["itemId"] == itemId);
    cartItems.saveCart(cartList);
    if (customerId == 0) {
      cartModify(cartList.length, 'null', customerName);
    } else {
      cartModify(cartList.length, customerId.toString(), customerName);
    }

    getItems();
  }

  clearCartItems() async {
    List<CartDataType> itemsTemp = [];
    final CartState cartItems = Provider.of<CartState>(context, listen: false);
    var cartList = cartItems.cart;
    cartList = [];
    cartItems.saveCart(cartList);
    if (customerId == 0) {
      cartModify(cartList.length, 'null', customerName);
    } else {
      cartModify(cartList.length, customerId.toString(), customerName);
    }
    getItems();
  }

  updateItem(itemId, count) async {
    final CartState cartItems = Provider.of<CartState>(context, listen: false);
    var cartList = cartItems.cart;
    cartList[cartList.indexWhere((item) => item["itemId"] == itemId)]["count"] =
        count;
    cartList[cartList.indexWhere((item) => item["itemId"] == itemId)]["total"] =
        cartList[cartList.indexWhere((item) => item["itemId"] == itemId)]
                ["price"] *
            count;
    cartItems.saveCart(cartList);
    if (customerId == 0) {
      cartModify(cartList.length, 'null', customerName);
    } else {
      cartModify(cartList.length, customerId.toString(), customerName);
    }
    getItems();
  }

  getItems() async {
    try {
      print("called2");
      setState(() {
        isBrandLoading = true;
      });
      List<CartDataType> itemsTemp = [];
      final CartState cartItems =
          Provider.of<CartState>(context, listen: false);
      var cartList = cartItems.cart;
      print(cartList.length);
      print(cartList);
      if (cartList.length > 0) {
        for (var u in cartList) {
          print("ID : " + u["itemId"].toString());
          print(u["itemId"].runtimeType.toString());

          print("Name" + u["itemName"].runtimeType.toString());

          print("count : " + u["count"].runtimeType.toString());
          print("price : " + u["price"].runtimeType.toString());

          print("total" + u["total"].runtimeType.toString());

          print("img : " + u["imgPath"].runtimeType.toString());
          // if (customerId.toString() == u["custid"]) {
          CartDataType data = CartDataType(
              u["option"],
              u["itemId"].toString(),
              u["itemName"].toString(),
              int.parse(u["count"].toString()),
              u["custQty"],
              double.parse(u["price"].toString()),
              double.parse(u["total"].toString()),
              u["imgPath"],
              u);

          itemsTemp.add(data);
          print(u["option"]);
          // }
        }
        print("called3");
      }
      setState(() {
        stateItems = itemsTemp;
        calculation();
        isBrandLoading = false;
      });
    } catch (e) {}
  }

  // deleteAllItems() async {
  //   try {
  //     print("called");

  //     var body = json.encode({"customerid": customerId});
  //     print(body);
  //     print(Constants.clearCart);
  //     var result = await http.get(
  //       Constants.App_url + Constants.clearCart + customerId.toString(),
  //       headers: {
  //         "Content-Type": "application/json",
  //       },
  //     );
  //     print(result);

  //     Map<String, dynamic> response = json.decode(result.body);
  //     if (response["response"] == "success") {
  //       Fluttertoast.showToast(
  //         msg: "Cart Cleared",
  //         toastLength: Toast.LENGTH_SHORT,
  //         webBgColor: "#e74c3c",
  //         timeInSecForIosWeb: 5,
  //       );
  //     }
  //   } catch (e) {}
  // }

  // deleteItem() async {
  //   try {
  //     print("called");

  //     var body =
  //         json.encode({"productid": productId, "customerid": customerId});
  //     print(body);
  //     print(Constants.removeItem);
  //     var result = await http.get(
  //       Constants.App_url +
  //           Constants.removeItem +
  //           productId +
  //           "&customerid=" +
  //           customerId.toString(),
  //       headers: {
  //         "Content-Type": "application/json",
  //       },
  //     );
  //     print(result);

  //     Map<String, dynamic> response = json.decode(result.body);
  //     if (response["response"] == "success") {
  //       Fluttertoast.showToast(
  //         msg: "Item Deleted",
  //         toastLength: Toast.LENGTH_SHORT,
  //         webBgColor: "#e74c3c",
  //         timeInSecForIosWeb: 5,
  //       );
  //     }
  //   } catch (e) {}
  // }

  _initLoad() async {
    print("called");
    this._checkLogin();

    this.getItems();
    this.calculation();
  }

  _checkLogin() {
    print("called");
    final AuthState authState = Provider.of<AuthState>(context, listen: false);
    dynamic loginuserResponse = authState.getLoginUser;
    print(loginuserResponse);
    print(loginuserResponse['isLogin']);

    if (loginuserResponse['isLogin']) {
      setState(() {
        customerId = loginuserResponse["customerInfo"]["cust_id"];
        customerName =
            loginuserResponse["customerInfo"]["cust_firstname"].toString();
      });
    } else {
      customerId = 0;
    }
  }

  calculation() {
    int len = stateItems.length;
    subtotal = 0.0;
    total = 0.0;
    for (int i = 0; i < len; i++) {
      subtotal = (subtotal + stateItems[i].total);
      total = subtotal + gst;
    }
    gst = (subtotal / 100) * 7;
    total = subtotal + gst;
    gst = double.parse(gst.toStringAsFixed(2));
    subtotal = double.parse(subtotal.toStringAsFixed(2));
    total = double.parse(total!.toStringAsFixed(2));
  }

  _onRemovePressed(itemId) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Do you really want to remove item from cart?',
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
                    removeCartItem(itemId);
                    Navigator.pop(context, false);
                  },
                )
              ],
            ));
  }

  _onClearPressed() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Do you really want to clear all items from cart?',
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
                    clearCartItems();
                    Navigator.pop(context, false);
                  },
                )
              ],
            ));
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10), () {
      _initLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    var pageWidth = MediaQuery.of(context).size.width;
    var pageHeight = MediaQuery.of(context).size.height;
    final Map<String, Object> rcvdData =
        ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    if (rcvdData != null) {
      if (rcvdData["route"] == "push") {
        setState(() {
          isBottomTab = false;
        });
      }
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(Constants.logocolor),
          automaticallyImplyLeading: isBottomTab,
          leading: isBottomTab
              ? SizedBox()
              : IconButton(
                  icon: Icon(CustomIcons.backarrow,
                      color: Color(Constants.primaryYellow)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),

          //backgroundColor: Color(0x44ffffff),
          elevation: 16,
          title: Text(
            "My cart",
            style: styles.ThemeText.appbarTextStyles2,
          ),
          actions: <Widget>[
            // add the icon to this list
            // StatusWidget(),
            if (stateItems.length != 0)
              Container(
                width: pageWidth * 0.15,
                margin: EdgeInsets.all(10),
                child: RaisedButton(
                  color: Color(Constants.primaryYellow),
                  shape: styles.ThemeText.borderRaidus1,
                  onPressed: () {
                    _onClearPressed();
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete,
                          color: Color(Constants.blackColor),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
              //color: Colors.white,
              child: isBrandLoading
                  ? SpinKitThreeBounce(
                      color: Color(Constants.logocolor),
                      size: 20.0,
                    )
                  : stateItems == null || stateItems.length == 0
                      ? Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                padding: const EdgeInsets.only(top: 150),
                                child: Image(
                                  image: AssetImage(
                                      'assets/images/shopbagempty.png'),
                                  fit: BoxFit.fill,
                                  height: 150.0,
                                )),
                            Text("Your cart is empty",
                                style: styles.ThemeText.leftTextstyles)
                          ],
                        ))
                      : Column(
                          children: [
                            // Align(
                            //   alignment: Alignment.centerRight,
                            //   child: Container(
                            //     width: pageWidth * 0.40,
                            //     height: 50,
                            //     margin: EdgeInsets.all(10),
                            //     child: FlatButton(
                            //       color: Color(Constants.primaryYellow),
                            //       shape: styles.ThemeText.borderRaidus1,
                            //       onPressed: () {
                            //         _onClearPressed();
                            //       },
                            //       child: Align(
                            //         alignment: Alignment.center,
                            //         child: Row(
                            //           mainAxisAlignment: MainAxisAlignment.center,
                            //           children: [
                            //             Icon(
                            //               Icons.delete,
                            //               color: Color(Constants.blackColor),
                            //               size: 20,
                            //             ),
                            //             Text(
                            //               'Clear Cart',
                            //               style:
                            //                   styles.ThemeText.buttonTextStyles,
                            //               textAlign: TextAlign.center,
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            ListView.builder(
                                itemCount:
                                    stateItems == null ? 0 : stateItems.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return
                                      // IconButton(
                                      //   icon: Icon(Icons.close_rounded),
                                      //   color: Colors.black,
                                      //   iconSize: 18,
                                      //   onPressed: () {
                                      //     _onRemovePressed(
                                      //         stateItems[index].itemId);
                                      //   },
                                      // ),
                                      GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/productDetails',
                                          arguments: {
                                            "productId":
                                                stateItems[index].itemId,
                                          });
                                    },
                                    child: Container(
                                      width: pageWidth,
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)),
                                          border: Border.all(
                                              color: Color(
                                                  Constants.borderGreyColor))),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                child: ClipRRect(
                                                    borderRadius: BorderRadius
                                                        .all(Radius.circular(
                                                            30.0)),
                                                    child: stateItems[index]
                                                                    .imgPath ==
                                                                null ||
                                                            stateItems[index]
                                                                    .imgPath ==
                                                                ""
                                                        ? Image(
                                                            image: AssetImage(
                                                                'assets/images/placeholder-logo.png'),
                                                            fit: BoxFit.fill,
                                                            height: 60.0,
                                                            width: 60.0)
                                                        : FadeInImage
                                                            .assetNetwork(
                                                                image: stateItems[
                                                                        index]
                                                                    .imgPath,
                                                                placeholder:
                                                                    "assets/images/placeholder-logo.png", // your assets image path
                                                                fit:
                                                                    BoxFit.fill,
                                                                height: 60.0,
                                                                width: 60.0)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 5),
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.40,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      stateItems[index]
                                                                  .option !=
                                                              null
                                                          ? Text(
                                                              stateItems[index]
                                                                      .itemName +
                                                                  " - " +
                                                                  stateItems[
                                                                          index]
                                                                      .option,
                                                              style: styles
                                                                  .ThemeText
                                                                  .buttonTextStyles,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 5,
                                                            )
                                                          : Text(
                                                              stateItems[index]
                                                                  .itemName,
                                                              style: styles
                                                                  .ThemeText
                                                                  .buttonTextStyles,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 5,
                                                            ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "price : ",
                                                            style: styles
                                                                .ThemeText
                                                                .itemsTextStyle,
                                                            textAlign:
                                                                TextAlign.left,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2,
                                                          ),
                                                          Text(
                                                            "\$" +
                                                                stateItems[
                                                                        index]
                                                                    .price
                                                                    .toStringAsFixed(
                                                                        2),
                                                            style: styles
                                                                .ThemeText
                                                                .itemsTextStyle,
                                                            textAlign:
                                                                TextAlign.left,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Text(
                                                    '\$' +
                                                        stateItems[index]
                                                            .total
                                                            .toStringAsFixed(2)
                                                            .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: styles.ThemeText
                                                        .leftTextstyles,
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10),
                                                    width: 88,
                                                    height: 35,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Color(Constants
                                                              .borderGreyColor),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        15),
                                                                topRight: Radius
                                                                    .circular(
                                                                        15),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        15),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        15))),
                                                    child: Stack(
                                                      children: [
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: stateItems[
                                                                          index]
                                                                      .count !=
                                                                  1
                                                              ? IconButton(
                                                                  icon: Icon(Icons
                                                                      .remove),
                                                                  iconSize: 14,
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  onPressed:
                                                                      () {
                                                                    if (stateItems[index]
                                                                            .count !=
                                                                        1) {
                                                                      setState(
                                                                          () {
                                                                        stateItems[index]
                                                                            .count--;
                                                                        updateItem(
                                                                            stateItems[index].itemId,
                                                                            stateItems[index].count);
                                                                        stateItems[index]
                                                                            .total = (stateItems[index]
                                                                                .price *
                                                                            stateItems[index].count);

                                                                        calculation();
                                                                      });
                                                                    }
                                                                  },
                                                                )
                                                              : IconButton(
                                                                  icon: Icon(Icons
                                                                      .delete),
                                                                  iconSize: 14,
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      _onRemovePressed(
                                                                          stateItems[index]
                                                                              .itemId);
                                                                      calculation();
                                                                    });
                                                                  },
                                                                ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            stateItems[index]
                                                                .count
                                                                .toString(),
                                                            style: styles
                                                                .ThemeText
                                                                .buttonTextStyles,
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: IconButton(
                                                            icon:
                                                                Icon(Icons.add),
                                                            iconSize: 14,
                                                            alignment: Alignment
                                                                .centerRight,
                                                            onPressed: () {
                                                              if (stateItems[
                                                                          index]
                                                                      .count !=
                                                                  stateItems[
                                                                          index]
                                                                      .custQty) {
                                                                setState(() {
                                                                  stateItems[
                                                                          index]
                                                                      .count++;
                                                                  updateItem(
                                                                      stateItems[
                                                                              index]
                                                                          .itemId,
                                                                      stateItems[
                                                                              index]
                                                                          .count);
                                                                  stateItems[
                                                                          index]
                                                                      .total = (stateItems[
                                                                              index]
                                                                          .price *
                                                                      stateItems[
                                                                              index]
                                                                          .count);

                                                                  calculation();
                                                                });
                                                              } else {
                                                                Fluttertoast
                                                                    .showToast(
                                                                  msg:
                                                                      "Maximum quantity limit reached",
                                                                  toastLength: Toast
                                                                      .LENGTH_SHORT,
                                                                  webBgColor:
                                                                      "#e74c3c",
                                                                  timeInSecForIosWeb:
                                                                      5,
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // IconButton(
                                              //   icon: Icon(Icons.close),
                                              //   iconSize: 14,
                                              //   onPressed: () {
                                              //     _onRemovePressed(
                                              //         stateItems[index].itemId);
                                              //   },
                                              // ),
                                            ],
                                          ),
                                          Divider(),
                                          Container(
                                            height: 25,
                                            alignment: Alignment.centerRight,
                                            child: FlatButton(
                                              onPressed: () {
                                                _onRemovePressed(
                                                    stateItems[index].itemId);
                                              },
                                              child: Text("Remove",
                                                  style: TextStyle(
                                                      decoration: TextDecoration
                                                          .underline,
                                                      fontSize: 13,
                                                      color: Color(
                                                          Constants.redColor),
                                                      fontFamily:
                                                          "AvenirLTProHeavy")),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                            Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: pageWidth / 3),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 20, top: 10, bottom: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Subtotal : ",
                                              style: styles.ThemeText.carttext1,
                                            ),
                                            Text(
                                                "\$" +
                                                    subtotal.toStringAsFixed(2),
                                                style:
                                                    styles.ThemeText.carttext2),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 20, top: 10, bottom: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "GST(7%) : ",
                                              style: styles.ThemeText.carttext1,
                                            ),
                                            Text("\$" + gst.toStringAsFixed(2),
                                                style:
                                                    styles.ThemeText.carttext2),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Color(Constants
                                                          .borderGreyColor),
                                                      width: 1.0))),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 20, top: 10, bottom: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Grand total : ",
                                              style: styles.ThemeText.carttext1,
                                            ),
                                            Text(
                                                "\$" +
                                                    total!.toStringAsFixed(2),
                                                style:
                                                    styles.ThemeText.carttext2),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: pageWidth,
                                  height: 50,
                                  margin: EdgeInsets.all(10),
                                  child: RaisedButton(
                                    color: Color(Constants.primaryYellow),
                                    shape: styles.ThemeText.borderRaidus1,
                                    onPressed: () {
                                      if (customerId != 0) {
                                        Navigator.pushNamed(
                                            context, '/checkoutScreen');
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: "Please login to continue",
                                          toastLength: Toast.LENGTH_SHORT,
                                          webBgColor: "#e74c3c",
                                          timeInSecForIosWeb: 5,
                                        );
                                      }
                                    },
                                    child: Align(
                                      child: Text(
                                        'Proceed to checkout',
                                        style:
                                            styles.ThemeText.buttonTextStyles,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
        ));
  }
}

class AllItemsDataType {
  final int itemId;
  final String itemName;
  // final double size;
  // final String shortDesc;
  // final String color;
  // final String specification;
  // final String urlKey;
  int quantity;
  final String price;
  // final String gstBox;
  // final Float weight;
  // final double qty;
  // final double custqty;
  // final double dimension;
  // final double catId;
  // final double brand;
  final String imgPath;
  // final String largeImgPath;
  // final String description;
  // final String videoPath;

  final Object Obj;

  AllItemsDataType(
      this.itemId,
      this.itemName,
      // this.size,
      // this.shortDesc,
      // this.color,
      // this.specification,
      // this.urlKey,
      this.quantity,
      this.price,
      // this.gstBox,
      // this.weight,
      // this.qty,
      // this.custqty,
      // this.dimension,
      // this.catId,
      // this.brand,
      this.imgPath,
      // this.largeImgPath,
      // this.description,
      // this.videoPath,
      this.Obj);
}
