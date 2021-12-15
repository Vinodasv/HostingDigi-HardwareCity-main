import 'package:flutter/material.dart';
import '../styles.dart' as styles;
import '../constants.dart' as Constants;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../states/customerProfileState.dart';
import '../customicons.dart';

class MyOrdersScreen extends StatefulWidget {
  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool isBrandLoading = false;
  List<OrderListDataType> stateOrders = [];
  double shipping = 8.88;
  double total = 0;
  double subtotal = 0;
  bool isBrandAvailable = true;
  int? count;
  int? customerId;
  String from = "";

  getItems() async {
    try {
      print("called");
      List<OrderListDataType> ordersTemp = [];
      List<ProductList> productsTemp = [];
      final AuthState authState =
          Provider.of<AuthState>(context, listen: false);
      dynamic loginuserResponse = authState.getLoginUser;
      if (loginuserResponse['isLogin']) {
        setState(() {
          customerId = loginuserResponse["customerInfo"]["cust_id"];
        });
      }
      setState(() {
        isBrandLoading = true;
      });
      print(customerId);
      var body = json.encode({"customerid": customerId});
      print(body);
      print(Constants.orderList);
      var result =
          await http.post(Uri.parse(Constants.App_url + Constants.orderList),
              headers: {
                "Content-Type": "application/json",
                'Accept': 'application/json',
              },
              body: body);
      print(result);

      Map<String, dynamic> response = json.decode(result.body);
      if (response["response"] == "success") {
        // print('saved $value');
        print(response["orderlist"].length);
        if (response["orderlist"].length > 0) {
          for (var u in response["orderlist"]) {
            isBrandAvailable = false;
            print(u["order_id"]);
            print(u["payable_amount"]);
            print(u["paymethod"]);
            print(u["order_status"]);
            print(u["products"]);
            print(u["products"][0]["id"]);
            productsTemp = [];
            count = 0;
            for (int i = 0; i < u["products"].length; i++) {
              count = count! + 1;
              ProductList data2 = ProductList(
                  u["order_id"],
                  u["products"][i]["id"],
                  u["products"][i]["image"],
                  u["products"][i]["option"],
                  u["products"][i]["quantity"],
                  u["products"][i]["price"],
                  u);
              productsTemp.add(data2);
            }
            OrderListDataType data = OrderListDataType(
                u["order_id"],
                u["payable_amount"],
                u["paymethod"],
                u["order_status"],
                productsTemp,
                count!,
                u);
            print(data);
            // for (int i = 0; i < u["products"].length; i++) {
            //   ProductList data2 = ProductList(
            //       u["order_id"],
            //       u["products"][i]["id"],
            //       u["products"][i]["name"],
            //       u["products"][i]["option"],
            //       u["products"][i]["quantity"],
            //       u["products"][i]["price"],
            //       u);
            //   productsTemp.add(data2);
            //   print(productsTemp);
            //   print("Product");
            // }
            ordersTemp.add(data);
            print(ordersTemp);
            print("Order");
          }
          setState(() {
            stateOrders = ordersTemp;
          });
          // print(stateOrders[0]);

        }
      } else {
        Fluttertoast.showToast(
          msg: response['message'],
          toastLength: Toast.LENGTH_SHORT,
          webBgColor: "#e74c3c",
          timeInSecForIosWeb: 5,
        );
      }
      setState(() {
        isBrandLoading = false;
      });
    } catch (e) {
      setState(() {
        isBrandLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
        Future.delayed(const Duration(milliseconds: 20), () {
      final Map<String, Object> rcvdData =
          ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
      if (rcvdData != null) {
        setState(() {
          from = rcvdData["from"].toString();
        });
      }
    });
    this.getItems();
  }

  @override
  Widget build(BuildContext context) {
    var pageWidth = MediaQuery.of(context).size.width;
    total = shipping + subtotal;
    print(stateOrders.length);
    setState(() {
      if (stateOrders.length > 0) {
        isBrandAvailable = false;
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(Constants.logocolor),
        leading: from == "123"?IconButton(
            icon: Icon(CustomIcons.backarrow,
                color: Color(Constants.primaryYellow)),
            onPressed: () => Navigator.pop(context, "edited"),
          ):SizedBox(),
        //backgroundColor: Color(0x44ffffff),
        elevation: 16,
        title: Text(
          "My Orders",
          style: styles.ThemeText.appbarTextStyles2,
        ),
        actions: <Widget>[
          // add the icon to this list
          // StatusWidget(),
        ],
      ),
      body: isBrandLoading
          ? SpinKitThreeBounce(
              color: Color(Constants.logocolor),
              size: 20.0,
            )
          : SafeArea(
              child: SingleChildScrollView(
                //color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      color: Color(Constants.white),
                      child: Column(
                        children: [
                          Row(children: <Widget>[
                            Expanded(
                              child: new Container(
                                  margin: const EdgeInsets.only(right: 15.0),
                                  child: Divider(
                                    color: Color(Constants.blackColor),
                                    height: 50,
                                  )),
                            ),
                            Text(
                              "Upcoming",
                              style: styles.ThemeText.editProfileText,
                            ),
                            Expanded(
                              child: new Container(
                                  margin: const EdgeInsets.only(left: 15.0),
                                  child: Divider(
                                    color: Color(Constants.blackColor),
                                    height: 50,
                                  )),
                            ),
                          ]),
                          isBrandAvailable
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(40),
                                    child: Text("No Orders Placed"),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: stateOrders.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Column(children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/orderDetails',
                                              arguments: {
                                                "orderid":
                                                    stateOrders[index].orderId
                                              });
                                        },
                                        child: Container(
                                          width: pageWidth,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0)),
                                              border: Border.all(
                                                  color: Color(Constants
                                                      .borderGreyColor))),
                                          margin: EdgeInsets.only(
                                              bottom: 25, top: 15),
                                          padding: EdgeInsets.all(15),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 15),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                        "OR NO : " +
                                                            stateOrders[index]
                                                                .orderId
                                                                .toString(),
                                                        style: styles.ThemeText
                                                            .brandName),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "(shipment) ",
                                                          style: styles
                                                              .ThemeText
                                                              .orderStyle,
                                                        ),
                                                        Text(
                                                          ": Not yet",
                                                          style: styles
                                                              .ThemeText
                                                              .dateStyle,
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      for (int i = 0;
                                                          i <
                                                              stateOrders[index]
                                                                  .products
                                                                  .length;
                                                          i++)
                                                        if (i < 2)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 10),
                                                            child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.all(
                                                                        Radius.circular(
                                                                            30.0)),
                                                                child: stateOrders[index].products[i].itemName ==
                                                                            null ||
                                                                        stateOrders[index].products[i].itemName ==
                                                                            ""
                                                                    ? Image(
                                                                        image: AssetImage(
                                                                            'assets/images/placeholder-logo.png'),
                                                                        fit: BoxFit
                                                                            .fill,
                                                                        height:
                                                                            60.0,
                                                                        width:
                                                                            60.0)
                                                                    : FadeInImage.assetNetwork(
                                                                        image: stateOrders[index].products[i].itemName,
                                                                        placeholder: "assets/images/placeholder-logo.png", // your assets image path
                                                                        fit: BoxFit.fill,
                                                                        height: 60.0,
                                                                        width: 60.0)),
                                                          ),
                                                      if (stateOrders[index]
                                                              .products
                                                              .length >
                                                          2)
                                                        Text(
                                                          "+" +
                                                              (stateOrders[index]
                                                                          .count -
                                                                      2)
                                                                  .toString() +
                                                              " more\nitems",
                                                          style: styles
                                                              .ThemeText
                                                              .itemsTextStyle,
                                                        )
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 10),
                                                        child: Text(
                                                          '\$' +
                                                              stateOrders[index]
                                                                  .payAmount
                                                                  .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: styles
                                                              .ThemeText
                                                              .leftTextstyles,
                                                        ),
                                                      ),
                                                      Text(
                                                        stateOrders[index]
                                                                .count
                                                                .toString() +
                                                            " Products",
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: styles.ThemeText
                                                            .itemsTextStyle,
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 25),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text("Status : ",
                                                            style: styles
                                                                .ThemeText
                                                                .brandName),
                                                        stateOrders[index]
                                                                    .orderStatus !=
                                                                "Payment Pending"
                                                            ? Text(
                                                                stateOrders[
                                                                        index]
                                                                    .orderStatus,
                                                                style: styles
                                                                    .ThemeText
                                                                    .orderStatus)
                                                            : Text(
                                                                stateOrders[
                                                                        index]
                                                                    .orderStatus,
                                                                style: styles
                                                                    .ThemeText
                                                                    .orderStatus2),
                                                      ],
                                                    ),
                                                    // Container(
                                                    //   width: 120,
                                                    //   height: 35,
                                                    //   alignment: Alignment.center,
                                                    //   child: RaisedButton(
                                                    //     color: Color(Constants
                                                    //         .primaryYellow),
                                                    //     shape: styles.ThemeText
                                                    //         .borderRaidus1,
                                                    //     onPressed: () {
                                                    //       //Status screen
                                                    //     },
                                                    //     child: Align(
                                                    //       child: Center(
                                                    //         child: Row(
                                                    //           children: [
                                                    //             Text(
                                                    //               'Track Order',
                                                    //               style: styles
                                                    //                   .ThemeText
                                                    //                   .statusName,
                                                    //               textAlign:
                                                    //                   TextAlign
                                                    //                       .center,
                                                    //             ),
                                                    //             Icon(
                                                    //                 Icons
                                                    //                     .keyboard_arrow_right_sharp,
                                                    //                 size: 20),
                                                    //           ],
                                                    //         ),
                                                    //       ),
                                                    //     ),
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]);
                                  }),
                        ],
                      ),
                    ),
                    // Container(
                    //     color: Color(Constants.bggrey),
                    //     child: Column(
                    //       children: [
                    //         Row(children: <Widget>[
                    //           Expanded(
                    //             child: new Container(
                    //                 margin: const EdgeInsets.only(
                    //                     right: 15.0, left: 25),
                    //                 child: Divider(
                    //                   color: Color(Constants.blackColor),
                    //                   height: 50,
                    //                 )),
                    //           ),
                    //           Text(
                    //             "Previous Orders",
                    //             style: styles.ThemeText.editProfileText,
                    //           ),
                    //           Expanded(
                    //             child: new Container(
                    //                 margin: const EdgeInsets.only(
                    //                     left: 15.0, right: 25),
                    //                 child: Divider(
                    //                   color: Color(Constants.blackColor),
                    //                   height: 50,
                    //                 )),
                    //           ),
                    //         ]),
                    //         isBrandAvailable
                    //             ? Center(
                    //                 child: Padding(
                    //                   padding: const EdgeInsets.all(40),
                    //                   child: Text("No Orders Placed"),
                    //                 ),
                    //               )
                    //             : Center(
                    //                 child: Padding(
                    //                   padding: const EdgeInsets.all(40),
                    //                   child: Text("No Orders Placed"),
                    //                 ),
                    //               )
                    //         // : ListView.builder(
                    //         //     itemCount: stateOrders.length,
                    //         //     shrinkWrap: true,
                    //         //     physics: NeverScrollableScrollPhysics(),
                    //         //     itemBuilder:
                    //         //         (BuildContext context, int index) {
                    //         //       return Container(
                    //         //         margin: EdgeInsets.only(
                    //         //             left: 20, right: 20, bottom: 10),
                    //         //         padding: EdgeInsets.only(
                    //         //             left: 15,
                    //         //             right: 15,
                    //         //             top: 0,
                    //         //             bottom: 0),
                    //         //         decoration: BoxDecoration(
                    //         //             color: Color(Constants.white),
                    //         //             borderRadius: BorderRadius.all(
                    //         //                 Radius.circular(15.0)),
                    //         //             border: Border.all(
                    //         //                 color: Color(
                    //         //                     Constants.borderGreyColor))),
                    //         //         child: Column(children: [
                    //         //           Container(
                    //         //             width: pageWidth,
                    //         //             padding: EdgeInsets.only(
                    //         //                 bottom: 25, top: 15),
                    //         //             child: Column(
                    //         //               children: [
                    //         //                 Padding(
                    //         //                   padding: const EdgeInsets.only(
                    //         //                       bottom: 15),
                    //         //                   child: Row(
                    //         //                     mainAxisAlignment:
                    //         //                         MainAxisAlignment
                    //         //                             .spaceBetween,
                    //         //                     children: [
                    //         //                       Text("OR NO: 1234567890",
                    //         //                           style: styles.ThemeText
                    //         //                               .brandName),
                    //         //                       Text(
                    //         //                         "05/12/2020 (6.00 PM)",
                    //         //                         style: styles
                    //         //                             .ThemeText.dateStyle,
                    //         //                       )
                    //         //                     ],
                    //         //                   ),
                    //         //                 ),
                    //         //                 Row(
                    //         //                   mainAxisAlignment:
                    //         //                       MainAxisAlignment
                    //         //                           .spaceBetween,
                    //         //                   children: [
                    //         //                     Padding(
                    //         //                       padding:
                    //         //                           const EdgeInsets.only(
                    //         //                               right: 10),
                    //         //                       child: ClipRRect(
                    //         //                           borderRadius:
                    //         //                               BorderRadius.all(
                    //         //                                   Radius.circular(
                    //         //                                       30.0)),
                    //         //                           child: stateOrders[index]
                    //         //                                           .imgPath ==
                    //         //                                       null ||
                    //         //                                   stateOrders[index]
                    //         //                                           .imgPath ==
                    //         //                                       ""
                    //         //                               ? Image(
                    //         //                                   image: AssetImage(
                    //         //                                       'assets/images/placeholder-logo.png'),
                    //         //                                   fit:
                    //         //                                       BoxFit.fill,
                    //         //                                   height: 60.0,
                    //         //                                   width: 60.0)
                    //         //                               : FadeInImage
                    //         //                                   .assetNetwork(
                    //         //                                       image: stateOrders[
                    //         //                                               index]
                    //         //                                           .imgPath,
                    //         //                                       placeholder:
                    //         //                                           "assets/images/placeholder-logo.png", // your assets image path
                    //         //                                       fit: BoxFit
                    //         //                                           .fill,
                    //         //                                       height:
                    //         //                                           60.0,
                    //         //                                       width:
                    //         //                                           60.0)),
                    //         //                     ),
                    //         //                     Padding(
                    //         //                       padding:
                    //         //                           const EdgeInsets.only(
                    //         //                               right: 15),
                    //         //                       child: Text(
                    //         //                         stateOrders[index]
                    //         //                             .itemName,
                    //         //                         style: styles.ThemeText
                    //         //                             .appbarTextStyles,
                    //         //                         textAlign: TextAlign.left,
                    //         //                         overflow:
                    //         //                             TextOverflow.ellipsis,
                    //         //                         maxLines: 5,
                    //         //                       ),
                    //         //                     ),
                    //         //                     Column(
                    //         //                       crossAxisAlignment:
                    //         //                           CrossAxisAlignment.end,
                    //         //                       children: [
                    //         //                         Padding(
                    //         //                           padding:
                    //         //                               const EdgeInsets
                    //         //                                       .only(
                    //         //                                   bottom: 10),
                    //         //                           child: Text(
                    //         //                             '\$' +
                    //         //                                 stateOrders[index]
                    //         //                                     .price
                    //         //                                     .toString(),
                    //         //                             textAlign:
                    //         //                                 TextAlign.center,
                    //         //                             style: styles
                    //         //                                 .ThemeText
                    //         //                                 .leftTextstyles,
                    //         //                           ),
                    //         //                         ),
                    //         //                         Text(
                    //         //                           "1 Qty",
                    //         //                           textAlign:
                    //         //                               TextAlign.right,
                    //         //                           style: styles.ThemeText
                    //         //                               .itemsTextStyle,
                    //         //                         )
                    //         //                       ],
                    //         //                     )
                    //         //                   ],
                    //         //                 ),
                    //         //                 Padding(
                    //         //                   padding: const EdgeInsets.only(
                    //         //                       top: 25),
                    //         //                   child: Row(
                    //         //                     children: [
                    //         //                       Text("Status : ",
                    //         //                           style: styles.ThemeText
                    //         //                               .brandName),
                    //         //                       Padding(
                    //         //                         padding:
                    //         //                             const EdgeInsets.only(
                    //         //                                 left: 10),
                    //         //                         child: Text(
                    //         //                           "Completed",
                    //         //                           style: styles.ThemeText
                    //         //                               .orderStyle2,
                    //         //                         ),
                    //         //                       ),
                    //         //                     ],
                    //         //                   ),
                    //         //                 ),
                    //         //               ],
                    //         //             ),
                    //         //           ),
                    //         //         ]),
                    //         //       );
                    //         //     }),
                    //       ],
                    //     ))
                  ],
                ),
              ),
            ),
    );
  }
}

class OrderListDataType {
  final int orderId;
  final String payAmount;
  final String payMethod;
  final String orderStatus;
  List<ProductList> products;
  int count;

  final Object Obj;

  OrderListDataType(this.orderId, this.payAmount, this.payMethod,
      this.orderStatus, this.products, this.count, this.Obj);
}

class ProductList {
  final int orderId;
  final int itemid;
  final String itemName;
  final String options;
  final int qty;
  final String price;
  final Object obj;
  ProductList(this.orderId, this.itemid, this.itemName, this.options, this.qty,
      this.price, this.obj);
}
