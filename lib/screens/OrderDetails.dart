import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart' as Constants;
import '../customicons.dart';
import '../styles.dart' as styles;
//import 'package:flappy_search_bar/flappy_search_bar.dart';

class OrderDetails extends StatefulWidget {
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  bool isLoading = false;
  String trackId = "";
  int? orderId;
  String shipCost = '';
  String packageFee = '';
  String shipMethod = '';
  String tax = '';
  String amountPayable = '';
  String payMethod = '';
  String status = '';
  String billFname = '';
  String billLname = '';
  String billAddress1 = '';
  String billAddress2 = '';
  String billCity = '';
  String billState = '';
  String billCountry = '';
  String billZipcode = '';
  String shipFname = '';
  String shipLname = '';
  String shipAddress1 = '';
  String shipAddress2 = '';
  String shipCity = '';
  String shipState = '';
  String shipCountry = '';
  String shipZipcode = '';
  double? subTotal;
  String email = '';
  String phone = '';
  String ship = "Ninja Van Delivery (Up To 5 Days)";
  List<Product> products = [];
  List<DeliveryDetail> deliveryDetails = [];
  String imgPath = '';
  int items = 0;
  String productName = "";
  getItems() async {
    List<Product> itemsTemp = [];
    List<DeliveryDetail> itemsTemp2 = [];
    setState(() {
      isLoading = true;
    });
    var body = json.encode({"orderid": orderId});
    print(body);
    print(Constants.orderDetails);
    var result =
        await http.post(Uri.parse(Constants.App_url + Constants.orderDetails),
            headers: {
              "Content-Type": "application/json",
              'Accept': 'application/json',
            },
            body: body);
    print(result);

    Map<String, dynamic> response = json.decode(result.body);
    print(response);
    print(response["orderinfo"][0]["products"][0]["name"]);
    if (response["response"] == "success") {
      orderId = response["orderinfo"][0]["order_id"];
      shipCost = response["orderinfo"][0]["shippingcost"];
      packageFee = response["orderinfo"][0]["packagingfee"];
      shipMethod = response["orderinfo"][0]["shipmethod"];
      tax = response["orderinfo"][0]["tax_collected"];
      amountPayable = response["orderinfo"][0]["payable_amount"];
      payMethod = response["orderinfo"][0]["paymethod"];
      status = response["orderinfo"][0]["order_status"];
      billFname = response["orderinfo"][0]["bill_fname"];
      billLname = response["orderinfo"][0]["bill_lname"];
      billAddress1 = response["orderinfo"][0]["bill_address1"];
      billAddress2 = response["orderinfo"][0]["bill_address2"];
      billCity = response["orderinfo"][0]["bill_city"];
      billState = response["orderinfo"][0]["bill_state"];
      billCountry = response["orderinfo"][0]["bill_country"];
      billZipcode = response["orderinfo"][0]["bill_zip"];
      shipFname = response["orderinfo"][0]["ship_fname"];
      shipLname = response["orderinfo"][0]["ship_lname"];
      shipAddress1 = response["orderinfo"][0]["ship_address1"];
      shipAddress2 = response["orderinfo"][0]["ship_address2"];
      shipCity = response["orderinfo"][0]["ship_city"];
      shipState = response["orderinfo"][0]["ship_state"];
      shipCountry = response["orderinfo"][0]["ship_country"];
      shipZipcode = response["orderinfo"][0]["ship_zip"];
      subTotal = double.parse(amountPayable) -
          (double.parse(tax) +
              double.parse(shipCost) +
              double.parse(packageFee));
      for (var u in response["orderinfo"][0]["products"]) {
        print(u["id"]);
        Product data = Product(u["id"], u["name"], u["option"],
            u["quantity"].toString(), u["price"], u["image"], u);
        items = items + 1;
        itemsTemp.add(data);
      }
      if (shipMethod == ship) {
        if (response["orderinfo"][0]["deliverydetails"] != null) {
          for (var u in response["orderinfo"][0]["deliverydetails"]) {
            DeliveryDetail data = DeliveryDetail(u["productname"], u["status"],
                u["nextdeliverydate"], u["trackingnumber"], u["quantity"], u);
            itemsTemp2.add(data);
          }
        }
      }
      print(itemsTemp2);
    }
    setState(() {
      products = itemsTemp;
      deliveryDetails = itemsTemp2;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10), () {
      final Map<String, Object> rcvdData =
          ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
      if (rcvdData != null) {
        setState(() {
          orderId = int.parse(rcvdData["orderid"].toString());
        });
      }
      this.getItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    var pageWidth = MediaQuery.of(context).size.width;
    List<DeliveryDetail> temp = [];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Color(Constants.logocolor),
        leading: IconButton(
          icon: Icon(CustomIcons.backarrow,
              color: Color(Constants.primaryYellow)),
          onPressed: () => Navigator.of(context).pop(),
        ),

        //backgroundColor: Color(0x44ffffff),
        elevation: 16,
        title: Text(
          "Order Details",
          style: styles.ThemeText.appbarTextStyles2,
        ),
      ),
      body: isLoading
          ? SpinKitThreeBounce(
              color: Color(Constants.logocolor),
              size: 20.0,
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  width: pageWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Text(
                            "Order No : $orderId",
                            style: styles.ThemeText.editProfileText,
                          )),
                      Container(
                        color: Color(Constants.bggrey),
                        margin: EdgeInsets.only(top: 20, bottom: 30),
                        padding: EdgeInsets.only(
                            left: 10, top: 20, right: 10, bottom: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Order Items : $items",
                                  style: styles.ThemeText.editProfileText,
                                ),
                              ],
                            ),
                            ListView.builder(
                                itemCount: products.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      print("pressed");
                                      Navigator.pushNamed(
                                          context, '/productDetails',
                                          arguments: {
                                            "productId": products[index].id,
                                          });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(top: 20),
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)),
                                          border: Border.all(
                                              color: Color(
                                                  Constants.borderGreyColor))),
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 20),
                                                child: ClipRRect(
                                                    // borderRadius:
                                                    //     BorderRadius.all(Radius.circular(30.0)),
                                                    child: products[index]
                                                                    .imgpath ==
                                                                null ||
                                                            products[index]
                                                                    .imgpath ==
                                                                ""
                                                        ? Image(
                                                            image: AssetImage(
                                                                'assets/images/placeholder-logo.png'),
                                                            fit: BoxFit.fill,
                                                            height: 70.0,
                                                            width: 70.0)
                                                        : FadeInImage
                                                            .assetNetwork(
                                                                image: products[
                                                                        index]
                                                                    .imgpath,
                                                                placeholder:
                                                                    "assets/images/placeholder-logo.png", // your assets image path
                                                                fit:
                                                                    BoxFit.fill,
                                                                height: 70.0,
                                                                width: 70.0)),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.45,
                                                    child: Text(
                                                      products[index].name,
                                                      style: styles.ThemeText
                                                          .appbarTextStyles,
                                                      textAlign: TextAlign.left,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 5,
                                                    ),
                                                  ),
                                                  Text(
                                                    products[index]
                                                            .qty
                                                            .toString() +
                                                        " x " +
                                                        "\$" +
                                                        double.parse(
                                                                products[index]
                                                                    .price)
                                                            .toStringAsFixed(2),
                                                    style: styles.ThemeText
                                                        .itemsTextStyle,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 5,
                                                  ),
                                                ],
                                              ),
                                              // Text(
                                              //   '\$' +
                                              //       (double.parse(
                                              //                   products[index].price) *
                                              //               double.parse(
                                              //                   products[index].qty))
                                              //           .toStringAsFixed(2),
                                              //   textAlign: TextAlign.center,
                                              //   style: styles.ThemeText.leftTextstyles,
                                              // ),
                                            ],
                                          ),
                                          if (shipMethod == ship)
                                            Container(
                                                margin: EdgeInsets.only(
                                                    top: 10, bottom: 10),
                                                child: Row(
                                                  children: [
                                                    // Text(
                                                    //   "Track order : ",
                                                    //   style: styles.ThemeText.editProfileText,
                                                    // ),
                                                    Container(
                                                      //padding: EdgeInsets.only(left: 5),
                                                      width: 110,
                                                      height: 30,
                                                      alignment:
                                                          Alignment.center,
                                                      child: RaisedButton(
                                                        color: Color(Constants
                                                            .primaryYellow),
                                                        shape: styles.ThemeText
                                                            .borderRaidus1,
                                                        onPressed: () {
                                                          temp = [];
                                                          setState(() {
                                                            productName =
                                                                products[index]
                                                                    .name;
                                                            for (var u
                                                                in deliveryDetails) {
                                                              if (productName ==
                                                                  u.name) {
                                                                temp.add(u);
                                                              }
                                                            }
                                                            print("temp:" +
                                                                temp.toString());
                                                            Dialog trackOrder =
                                                                Dialog(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                10.0)),
                                                                    child:
                                                                        Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              10),
                                                                      width:
                                                                          350,
                                                                      child:
                                                                          SingleChildScrollView(
                                                                        child: Center(
                                                                            child: Column(
                                                                          //crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              "Tracking ID",
                                                                              style: styles.ThemeText.appbarTextStyles,
                                                                            ),
                                                                            for (var u
                                                                                in temp)
                                                                              //if (u.name == productName)
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(bottom: 10),
                                                                                child: Column(
                                                                                  children: [
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          u.trackId,
                                                                                          style: styles.ThemeText.leftTextstyles,
                                                                                        ),
                                                                                        IconButton(
                                                                                          icon: Icon(Icons.copy),
                                                                                          color: Color(Constants.green),
                                                                                          onPressed: () {
                                                                                            FlutterClipboard.copy(u.trackId).then((result) {
                                                                                              Fluttertoast.showToast(
                                                                                                msg: "Copied to clipboard",
                                                                                                toastLength: Toast.LENGTH_SHORT,
                                                                                                webBgColor: "#e74c3c",
                                                                                                //timeInSecForIosWeb: 2,
                                                                                              );
                                                                                            });
                                                                                          },
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    Row(
                                                                                      children: [
                                                                                        Text(
                                                                                          "Status: ",
                                                                                          style: styles.ThemeText.buttonTextStyles,
                                                                                        ),
                                                                                        Text(u.status),
                                                                                      ],
                                                                                    ),
                                                                                    if (u.nextDeliveryDate != null)
                                                                                      Row(
                                                                                        children: [
                                                                                          Text(
                                                                                            "Next Delivery date: ",
                                                                                            style: styles.ThemeText.buttonTextStyles,
                                                                                          ),
                                                                                          Text(u.nextDeliveryDate),
                                                                                        ],
                                                                                      ),
                                                                                    Row(
                                                                                      children: [
                                                                                        Text(
                                                                                          "Quantity: ",
                                                                                          style: styles.ThemeText.buttonTextStyles,
                                                                                        ),
                                                                                        Text(u.quantity.toString()),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            Row(
                                                                              children: [
                                                                                new InkWell(
                                                                                    child: new Text(
                                                                                      'click here ',
                                                                                      style: TextStyle(color: Colors.blue, fontSize: 12),
                                                                                    ),
                                                                                    onTap: () => launch('https://www.google.com')),
                                                                                Text(
                                                                                  "to go to ninja van tracking website.",
                                                                                  style: TextStyle(color: Colors.black, fontSize: 12),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          ],
                                                                        )),
                                                                      ),
                                                                    ));
                                                            if (temp
                                                                .isNotEmpty) {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      trackOrder);
                                                            } else {
                                                              Fluttertoast
                                                                  .showToast(
                                                                msg:
                                                                    "Not available",
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                webBgColor:
                                                                    "#e74c3c",
                                                                //timeInSecForIosWeb: 2,
                                                              );
                                                            }
                                                          });
                                                        },
                                                        child: Align(
                                                          child: Center(
                                                            child: Text(
                                                              'Track order',
                                                              style: styles
                                                                  .ThemeText
                                                                  .buttonTextStyles,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          child: Row(
                            children: [
                              Text(
                                "Status : ",
                                style: styles.ThemeText.editProfileText,
                              ),
                              status != "Payment Pending"
                                  ? Text(
                                      "$status",
                                      style: styles.ThemeText.orderStatus,
                                    )
                                  : Text(
                                      "$status",
                                      style: styles.ThemeText.orderStatus2,
                                    ),
                            ],
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          child: Row(
                            children: [
                              Text(
                                "Shipped Date :",
                                style: styles.ThemeText.editProfileText,
                              ),
                              Text(
                                " Not yet",
                                style: styles.ThemeText.itemsTextStyle,
                              ),
                            ],
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          child: Row(
                            children: [
                              Text(
                                "Shipping Method : ",
                                style: styles.ThemeText.editProfileText,
                              ),
                              SizedBox(
                                width: pageWidth / 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Text(
                                    "$shipMethod",
                                    style: styles.ThemeText.itemsTextStyle,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 4,
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          child: Row(
                            children: [
                              Text(
                                "Payment Method : ",
                                style: styles.ThemeText.editProfileText,
                              ),
                              Text(
                                payMethod == "Native Pay"
                                    ? Platform.isAndroid
                                        ? "Google Pay"
                                        : "Apple Pay"
                                    : "$payMethod",
                                style: styles.ThemeText.itemsTextStyle,
                              ),
                            ],
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 25),
                          child: Text(
                            "Order Total",
                            style: styles.ThemeText.editProfileText,
                          )),
                      Container(
                        color: Color(Constants.bggrey),
                        margin: EdgeInsets.only(top: 20, bottom: 30),
                        padding: EdgeInsets.only(
                            left: 10, top: 20, right: 10, bottom: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Subtotal :",
                                    textAlign: TextAlign.left,
                                    style: styles.ThemeText.editProfileText,
                                  ),
                                  Text(
                                    "\$" + subTotal!.toStringAsFixed(2),
                                    textAlign: TextAlign.left,
                                    style: styles.ThemeText.leftTextstyles,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Tax :",
                                    textAlign: TextAlign.left,
                                    style: styles.ThemeText.editProfileText,
                                  ),
                                  Text(
                                    "\$" + tax,
                                    textAlign: TextAlign.left,
                                    style: styles.ThemeText.leftTextstyles,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Shipping Fee :",
                                    textAlign: TextAlign.left,
                                    style: styles.ThemeText.editProfileText,
                                  ),
                                  Text(
                                    "\$" + shipCost,
                                    textAlign: TextAlign.left,
                                    style: styles.ThemeText.leftTextstyles,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Package Fee :",
                                    textAlign: TextAlign.left,
                                    style: styles.ThemeText.editProfileText,
                                  ),
                                  Text(
                                    "\$" + packageFee,
                                    textAlign: TextAlign.left,
                                    style: styles.ThemeText.leftTextstyles,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Grand Total :",
                                    textAlign: TextAlign.left,
                                    style: styles.ThemeText.editProfileText,
                                  ),
                                  Text(
                                    "\$" + amountPayable,
                                    textAlign: TextAlign.left,
                                    style: styles.ThemeText.leftTextstyles,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: pageWidth / 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Billing Address",
                                      textAlign: TextAlign.left,
                                      style: styles.ThemeText.editProfileText,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: Text(
                                        billFname + " $billLname",
                                        textAlign: TextAlign.left,
                                        style: styles.ThemeText.itemsTextStyle,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 4,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Text(
                                        "$billAddress1\n$billAddress2",
                                        textAlign: TextAlign.left,
                                        style: styles.ThemeText.itemsTextStyle,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 4,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Text(
                                        billCity,
                                        textAlign: TextAlign.left,
                                        style: styles.ThemeText.itemsTextStyle,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 4,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Text(
                                        billState + " - " + billZipcode,
                                        textAlign: TextAlign.left,
                                        style: styles.ThemeText.itemsTextStyle,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 4,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Text(
                                        billCountry,
                                        textAlign: TextAlign.left,
                                        style: styles.ThemeText.itemsTextStyle,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 4,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                )),
                            Expanded(
                              child: Container(
                                  width: pageWidth / 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Shipping Address",
                                        textAlign: TextAlign.left,
                                        style: styles.ThemeText.editProfileText,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 15),
                                        child: Text(
                                          shipFname + " $shipLname",
                                          textAlign: TextAlign.left,
                                          style:
                                              styles.ThemeText.itemsTextStyle,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 4,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 7),
                                        child: Text(
                                          "$shipAddress1\n$shipAddress2",
                                          textAlign: TextAlign.left,
                                          style:
                                              styles.ThemeText.itemsTextStyle,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 4,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 7),
                                        child: Text(
                                          shipCity,
                                          textAlign: TextAlign.left,
                                          style:
                                              styles.ThemeText.itemsTextStyle,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 4,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 7),
                                        child: Text(
                                          shipState + " - " + shipZipcode,
                                          textAlign: TextAlign.left,
                                          style:
                                              styles.ThemeText.itemsTextStyle,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 4,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 7),
                                        child: Text(
                                          shipCountry,
                                          textAlign: TextAlign.left,
                                          style:
                                              styles.ThemeText.itemsTextStyle,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 4,
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 20),
                      //   child: Text(
                      //     "Contact",
                      //     textAlign: TextAlign.left,
                      //     style: styles.ThemeText.editProfileText,
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 15),
                      //   child: Text(
                      //     email,
                      //     textAlign: TextAlign.left,
                      //     style: styles.ThemeText.itemsTextStyle,
                      //     overflow: TextOverflow.ellipsis,
                      //     maxLines: 4,
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 15),
                      //   child: Text(
                      //     phone,
                      //     textAlign: TextAlign.left,
                      //     style: styles.ThemeText.itemsTextStyle,
                      //     overflow: TextOverflow.ellipsis,
                      //     maxLines: 4,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class Product {
  final int id;
  final String name;
  final String option;
  final String qty;
  final String price;
  final String imgpath;
  final Object obj;
  Product(this.id, this.name, this.option, this.qty, this.price, this.imgpath,
      this.obj);
}

class DeliveryDetail {
  final String name;
  final String status;
  final String nextDeliveryDate;
  final String trackId;
  final int quantity;
  final Object obj;
  DeliveryDetail(this.name, this.status, this.nextDeliveryDate, this.trackId,
      this.quantity, this.obj);
}
