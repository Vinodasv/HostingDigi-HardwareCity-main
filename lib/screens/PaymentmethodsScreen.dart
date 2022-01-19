import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';

import '../constants.dart' as Constants;
import '../customicons.dart';
// import './paymentStripe.dart';
// import 'package:flutter_stripe_payment/flutter_stripe_payment.dart';
import '../models/HomeScreenModels.dart';
import '../services/firebaseStorage.dart';
import '../states/customerProfileState.dart';
import '../states/myCartState.dart';
import '../styles.dart' as styles;
import 'StripePayment.dart';
import 'myOrders.dart';
//import 'package:flutter_stripe_payments/payment-service.dart';

//import 'package:flappy_search_bar/flappy_search_bar.dart';
String cardNumber = '';
String expiryDate = '';
String cardHolderName = '';
String cvvCode = '';
String expMonth = "";
String expYear = "";

class PaymentmethodsScreen extends StatefulWidget {
  @override
  _PaymentmethodsScreenState createState() => _PaymentmethodsScreenState();
}

class _PaymentmethodsScreenState extends State<PaymentmethodsScreen> {
  String option = '';
  final fieldText = TextEditingController();
   var _paymentItems = [
    PaymentItem(
      label: 'Total',
      amount: '99.99',
      status: PaymentItemStatus.final_price,
    )
  ];
  // final _stripePayment = FlutterStripePayment();
  List<Payment> stateItems = [];
  List<CartDataType> stateItems2 = [];
  List<dynamic> products = [];
  List<dynamic> products2 = [];
  List<dynamic> products3 = [];
  bool isLoading = false;
  int? customerId;
  String couponCode = '';
  int? couponId;
  String? discountString = null;
  int discount = 0;
  double discountamt = 0;
  bool couponApplied = false;
  double? subTotal;
  String customerName = '';
  double? gst;
  var ship;
  double? grandTotal;
  double? package;
  bool isShow = false;
  String company = '';
  String billEmail = '';
  String billAddress1 = '';
  String billAddress2 = '';
  String zipCode = '';
  String delOption = '';
  String itemOption = '';
  String billPhone = '';
  String billFname = '';
  String billLname = '';
  String shipFname = '';
  String shipLname = '';
  String shipEmail = '';
  String shipPhone = '';
  String shippaddress1 = '';
  String shippaddress2 = '';
  String shipcity = '';
  String shipstate = '';
  String shipzipcode = '';
  String shipCountry = '';
  String billcity = '';
  String billstate = '';
  String billzipcode = '';
  String billCountry = '';
  double? packageFee;
  String apiKey = '';
  String apiSignature = '';
  String _paymentMethodId = '';
  String token = "";
  String? orderId;

  //Stripe payment
  stripePayInitOrder() async {
    var billIndex = billPhone.indexOf(" ");
    var shipIndex = shipPhone.indexOf(" ");
    //Loader.show(context, progressIndicator: CupertinoActivityIndicator());
    var body = json.encode({
      "orderinfo": [
        {
          "customer_id": customerId,
          "shippingcost": ship.toString(),
          "subtotal": subTotal.toString(),
          "packagingfee": package.toString(),
          "shipmethod": delOption,
          "tax_collected": gst.toString(),
          "payable_amount": grandTotal!.toStringAsFixed(2),
          "discount": discount.toString(),
          "couponid": couponId,
          "discounttext": discountString,
          "paymethod": option,
          "if_items_unavailabel": itemOption,
          "token": token,
          "billing": [
            {
              "bill_fname": billFname,
              "bill_lname": billLname,
              "bill_email": billEmail,
              "bill_mobile":
                  billPhone.substring(billIndex + 1, billPhone.length),
              "bill_compname": company,
              "bill_address1": billAddress1,
              "bill_address2": billAddress2,
              "bill_city": billcity,
              "bill_state": billstate,
              "bill_country": billCountry,
              "bill_zip": billzipcode
            }
          ],
          "shipping": [
            {
              "ship_fname": shipFname,
              "ship_lname": shipLname,
              "ship_email": shipEmail,
              "ship_mobile":
                  shipPhone.substring(shipIndex + 1, shipPhone.length),
              "ship_address1": shippaddress1,
              "ship_address2": shippaddress2,
              "ship_city": shipcity,
              "ship_state": shipstate,
              "ship_country": shipCountry,
              "ship_zip": shipzipcode
            }
          ],
          "products": products
        }
      ]
    });
    print(body);

    final result = await http.post(
      Uri.parse(Constants.App_url + Constants.orderCreate),
      headers: {
        "Content-Type": "application/json",
      },
      body: body,
    );
    log("${Constants.App_url + Constants.orderCreate}");
    // print(result);
    //print("this is result ...................$result");
    final response = json.decode(result.body);
    log("$result");
    //log(response);
    if (response != null && response["response"] == "success") {
      final CartState cartItems =
          Provider.of<CartState>(context, listen: false);
      var cartList = cartItems.cart;
      cartList = [];
      cartItems.saveCart(cartList);
      cartModify(0, customerId.toString(), customerName);
      Fluttertoast.showToast(
        msg: response["message"],
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: "#e74c3c",
        timeInSecForIosWeb: 5,
      );
      int _orderId = response["orderid"];
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => StripePayment(
                  customerId: customerId.toString(),
                  orderId: _orderId.toString(),
                  cartAmmount: grandTotal.toString())));
    }
  }


  String _orderid="";
  //Order creation API
  orderCreation() async {
    var billIndex = billPhone.indexOf(" ");
    var shipIndex = shipPhone.indexOf(" ");
    Loader.show(context, progressIndicator: CupertinoActivityIndicator());

    var body = json.encode({
      "orderinfo": [
        {
          "customer_id": customerId,
          "shippingcost": ship.toString(),
          "subtotal": subTotal.toString(),
          "packagingfee": package.toString(),
          "shipmethod": delOption,
          "tax_collected": gst.toString(),
          "payable_amount": grandTotal!.toStringAsFixed(2),
          "discount": discount.toString(),
          "couponid": couponId,
          "discounttext": discountString,
          "paymethod": option,
          "if_items_unavailabel": itemOption,
          "token": token,
          "billing": [
            {
              "bill_fname": billFname,
              "bill_lname": billLname,
              "bill_email": billEmail,
              "bill_mobile":
                  billPhone.substring(billIndex + 1, billPhone.length),
              "bill_compname": company,
              "bill_address1": billAddress1,
              "bill_address2": billAddress2,
              "bill_city": billcity,
              "bill_state": billstate,
              "bill_country": billCountry,
              "bill_zip": billzipcode
            }
          ],
          "shipping": [
            {
              "ship_fname": shipFname,
              "ship_lname": shipLname,
              "ship_email": shipEmail,
              "ship_mobile":
                  shipPhone.substring(shipIndex + 1, shipPhone.length),
              "ship_address1": shippaddress1,
              "ship_address2": shippaddress2,
              "ship_city": shipcity,
              "ship_state": shipstate,
              "ship_country": shipCountry,
              "ship_zip": shipzipcode
            }
          ],
          "products": products
        }
      ]
    });
    log(body);

    var result = await http.post(
      Uri.parse(Constants.App_url + Constants.orderCreate),
      headers: {
        "Content-Type": "application/json",
      },
      body: body,
    );
    log("result");
    Map<String, dynamic> response = json.decode(result.body);
    print(response);
    if (response["response"] == "success") {
      final CartState cartItems =
          Provider.of<CartState>(context, listen: false);
      var cartList = cartItems.cart;
      cartList = [];
      cartItems.saveCart(cartList);
      cartModify(0, customerId.toString(), customerName);
      Fluttertoast.showToast(
        msg: response["message"],
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: "#e74c3c",
        timeInSecForIosWeb: 5,
      );
      // if (option == "Hoolah") {
      //   await canLaunch(response["hoolahpaymenturl"])
      //       ? await launch(response["hoolahpaymenturl"])
      //       : throw 'Could not launch';
      // }
      if (option == "Paypal") {
        Loader.hide();
        print(option + " : paypal");
        Navigator.pushNamed(context, '/paypal', arguments: {
          'apiKey': apiKey,
          'secret': apiSignature,
          'total': grandTotal
        }).then((value) async {
          var transactionId = value;
          var orderId = response["orderid"];
          if (value == "nil") {
            final httpresponse = await http.post(Uri.parse(
                "https://hardwarecity.com.sg/cancelorder?orderid=${orderId}"));
            // paymentIntentData = null;
            //log("$httpresponse");
            final failedresponse = json.decode(httpresponse.body);
            if (failedresponse != null) {
              print("------------------------------------------------");
              print("failed response is :$failedresponse");
              print("${failedresponse["messgage"]}");
            }
            //https://hardwarecity.com.sg/cancelorder?orderid=15505
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Payment Canceled.")));
            setState(() {
              //  onPayemntFailed = true;
            });
            Future.delayed(const Duration(seconds: 3), () {
              //  Navigator.of(context).pop();
            });
            // Fluttertoast.showToast(
            //   msg: "Your order not completed",
            //   toastLength: Toast.LENGTH_SHORT,
            //   webBgColor: "#e74c3c",
            //   timeInSecForIosWeb: 5,
            // );
          } else {
            final response = http.post(Uri.parse(
                "https://www.hardwarecity.com.sg/successorder?orderid=${orderId}&transactionid="));
            print(response);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("paid successfully")));
            Future.delayed(const Duration(seconds: 3), () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MyOrdersScreen()),
                  (route) => false);
              // payment done navigation goes here
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => const HomeScreen()));
            });

            // var result2 = await http.post(
            //   Uri.parse(Constants.App_url +
            //       Constants.payapalSuccess +
            //       "?orderid=$orderId&transactionid=$transactionId"),
            //   headers: {
            //     "Content-Type": "application/json",
            //   },
            // );
            // print(result);
            // Map<String, dynamic> response2 = json.decode(result2.body);
            // print(response);
            // if (response2["response"] == "success") {
            //   Fluttertoast.showToast(
            //     msg: response2["message"],
            //     toastLength: Toast.LENGTH_SHORT,
            //     webBgColor: "#e74c3c",
            //     timeInSecForIosWeb: 5,
            //   );
            // }
          }
          Navigator.pushNamed(context, '/bottomTab');
        });
        return;
      }
    }else if(option=="Native Pay"){
      Loader.hide();
      print(option + " : Native");
      // Navigator.pushNamed(context, '/paypal', arguments: {
      //   'apiKey': apiKey,
      //   'secret': apiSignature,
      //   'total': grandTotal
      // }).then((value) async {
      //   var transactionId = value;
        var orderId = response["orderid"];

      _orderid=response["orderid"];
      //   if (nativepay_error) {
      //     final httpresponse = await http.post(Uri.parse(
      //         "https://hardwarecity.com.sg/cancelorder?orderid=${orderId}"));
      //     // paymentIntentData = null;
      //     //log("$httpresponse");
      //     final failedresponse = json.decode(httpresponse.body);
      //     if (failedresponse != null) {
      //       print("------------------------------------------------");
      //       print("failed response is :$failedresponse");
      //       print("${failedresponse["messgage"]}");
      //     }
      //     //https://hardwarecity.com.sg/cancelorder?orderid=15505
      //     ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(content: Text("Payment Canceled.")));
      //     setState(() {
      //       //  onPayemntFailed = true;
      //     });
      //     Future.delayed(const Duration(seconds: 3), () {
      //       //  Navigator.of(context).pop();
      //     });
      //     // Fluttertoast.showToast(
      //     //   msg: "Your order not completed",
      //     //   toastLength: Toast.LENGTH_SHORT,
      //     //   webBgColor: "#e74c3c",
      //     //   timeInSecForIosWeb: 5,
      //     // );
      //   }
      //   else {
      //     final response = http.post(Uri.parse(
      //         "https://www.hardwarecity.com.sg/successorder?orderid=${orderId}&transactionid="));
      //     print(response);
      //     ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(content: Text("paid successfully")));
      //     Future.delayed(const Duration(seconds: 3), () {
      //       Navigator.pushAndRemoveUntil(
      //           context,
      //           MaterialPageRoute(builder: (context) => MyOrdersScreen()),
      //               (route) => false);
      //       // payment done navigation goes here
      //       // Navigator.push(context,
      //       //     MaterialPageRoute(builder: (context) => const HomeScreen()));
      //     });
      //
      //     // var result2 = await http.post(
      //     //   Uri.parse(Constants.App_url +
      //     //       Constants.payapalSuccess +
      //     //       "?orderid=$orderId&transactionid=$transactionId"),
      //     //   headers: {
      //     //     "Content-Type": "application/json",
      //     //   },
      //     // );
      //     // print(result);
      //     // Map<String, dynamic> response2 = json.decode(result2.body);
      //     // print(response);
      //     // if (response2["response"] == "success") {
      //     //   Fluttertoast.showToast(
      //     //     msg: response2["message"],
      //     //     toastLength: Toast.LENGTH_SHORT,
      //     //     webBgColor: "#e74c3c",
      //     //     timeInSecForIosWeb: 5,
      //     //   );
      //     // }
      //   }
      //   Navigator.pushNamed(context, '/bottomTab');
      // // });
      // return;
    } else {
      Fluttertoast.showToast(
        msg: response["message"],
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: "#e74c3c",
        timeInSecForIosWeb: 5,
      );
    }
    Loader.hide();
    Navigator.pushNamed(context, '/bottomTab');
  }


  createOrderNative(String orderid)async{
    var orderId = orderid;
    if (nativepay_error) {
      final httpresponse = await http.post(Uri.parse(
          "https://hardwarecity.com.sg/cancelorder?orderid=${orderId}"));
      // paymentIntentData = null;
      //log("$httpresponse");
      final failedresponse = json.decode(httpresponse.body);
      if (failedresponse != null) {
        print("------------------------------------------------");
        print("failed response is :$failedresponse");
        print("${failedresponse["messgage"]}");
      }
      //https://hardwarecity.com.sg/cancelorder?orderid=15505
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment Canceled.")));
      setState(() {
        //  onPayemntFailed = true;
      });
      Future.delayed(const Duration(seconds: 3), () {
        //  Navigator.of(context).pop();
      });
      Fluttertoast.showToast(
        msg: "Your order not completed",
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: "#e74c3c",
        timeInSecForIosWeb: 5,
      );
    }
    else {
      final response = http.post(Uri.parse(
          "https://www.hardwarecity.com.sg/successorder?orderid=${orderId}&transactionid="));
      print(response);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("paid successfully")));
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyOrdersScreen()),
                (route) => false);
        // payment done navigation goes here
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => const HomeScreen()));
      });

      // var result2 = await http.post(
      //   Uri.parse(Constants.App_url +
      //       Constants.payapalSuccess +
      //       "?orderid=$orderId&transactionid=$transactionId"),
      //   headers: {
      //     "Content-Type": "application/json",
      //   },
      // );
      // print(result);
      // Map<String, dynamic> response2 = json.decode(result2.body);
      // print(response);
      // if (response2["response"] == "success") {
      //   Fluttertoast.showToast(
      //     msg: response2["message"],
      //     toastLength: Toast.LENGTH_SHORT,
      //     webBgColor: "#e74c3c",
      //     timeInSecForIosWeb: 5,
      //   );
      // }
    }
    Loader.hide();
    Navigator.pushNamed(context, '/bottomTab');
    // });
    return;
  }

  // _makeNativePay() async {
  //   // double subtotal = double.parse(subTotal.toStringAsFixed(2)) +
  //   //     double.parse(package.toStringAsFixed(2)) +
  //   //     double.parse(ship.toStringAsFixed(2));
  //   StripeNative.setCurrencyKey("SGD");
  //   StripeNative.setCountryKey("SG");
  //   //subtotal, tax, tip, merchant name
  //   var order = Order(grandTotal, 0, 0.0, "HardwareCity");
  //   var temptoken = await StripeNative.useNativePay(order);
  //   //var wasCharged = await AppAPI.charge(temptoken, subtotal + gst);
  //   setState(() {
  //     token = temptoken;
  //   });
  //   orderCreation();
  //   StripeNative.confirmPayment(true);
  // }

  //Package calculatiom API response
  packagefeecalc() async {
    setState(() {
      isLoading = true;
    });
    var params = {
      "orderinfo": [
        {
          "subtotal": subTotal.toString(),
          "shipmethod": delOption.toString(),
          "tax_collected": gst.toString(),
          "country": shipCountry,
          "couponcode": "",
          "products": products2
        }
      ]
    };
    print(params);

    var result = await http.post(
      Uri.parse(Constants.App_url + Constants.packageFee),
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(params),
    );
    print(result);
    Map<String, dynamic> response = json.decode(result.body);
    print(response);
    if (response["response"] == "success") {
      setState(() {
        ship = response["shippingprice"];
        package = double.parse(response["packagingprice"]);
        grandTotal = double.parse(response["grandtotal"]);
        isLoading = false;
      });
    }
  }

  late bool nativepay_error;

  //
  getItems() async {
    try {
      print("called2");
      print("getItems");
      setState(() {
        isLoading = true;
      });
      List<CartDataType> itemsTemp = [];
      final AuthState authState =
          Provider.of<AuthState>(context, listen: false);
      dynamic loginuserResponse = authState.getLoginUser;
      final CartState cartItems =
          Provider.of<CartState>(context, listen: false);
      print("login");
      if (loginuserResponse['isLogin']) {
        print(loginuserResponse["customerInfo"]["cust_id"]);
        customerId = loginuserResponse["customerInfo"]["cust_id"];
        customerName =
            loginuserResponse["customerInfo"]["cust_firstname"].toString();
        print(customerId);
      }
      var cartList = cartItems.cart;
      print(cartList.length);
      if (cartList.length > 0) {
        for (var u in cartList) {
          products.add({
            "id": u["itemId"],
            "name": u["itemName"],
            "option": "",
            "quantity": u["count"],
            "price": u["price"],
            "weight": u["weight"],
            "code": null,
            "total": u["total"]
          });
          products2.add({
            "id": u["itemId"],
            "quantity": u["count"],
            "price": u["price"],
            "weight": u["weight"],
            "shippingbox": u["shipbox"],
            "total": u["total"]
          });
          products3.add({"id": u["itemid"]});

          print("12345");
          CartDataType data = CartDataType(
              u["option"],
              u["itemId"].toString(),
              u["itemName"].toString(),
              int.parse(u["count"].toString()),
              u["custQty"],
              double.parse(u["total"].toString()),
              double.parse(u["price"].toString()),
              u["imgPath"],
              u);

          itemsTemp.add(data);
        }

        print("called3");
        print(itemsTemp);
      }
      setState(() {
        stateItems2 = itemsTemp;
        isLoading = false;
      });
    } catch (e) {}
  }

  couponCodeValidate() async {
    Loader.show(context, progressIndicator: CupertinoActivityIndicator());
    var body = json.encode({
      "orderinfo": [
        {
          "customer_id": customerId,
          "couponcode": couponCode,
          "products": products3
        }
      ]
    });
    print(body);
    var result =
        await http.post(Uri.parse(Constants.App_url + Constants.coupon),
            headers: {
              "Content-Type": "application/json",
              'Accept': 'application/json',
            },
            body: body);
    Map<String, dynamic> response = json.decode(result.body);
    print(response);
    if (response["response"] == "success") {
      if (response["message"] == "Valid Coupon Code") {
        setState(() {
          discountamt = (grandTotal! / 100) * (response["discount"]);
          grandTotal = grandTotal! - discountamt;
          discount = response["discount"];
          discountString = response["discounttext"];
          couponApplied = true;
          couponId = response["couponid"];
        });
        Fluttertoast.showToast(
          msg: "Coupon applied",
          toastLength: Toast.LENGTH_SHORT,
          webBgColor: "#e74c3c",
          timeInSecForIosWeb: 5,
        );
      } else {
        Fluttertoast.showToast(
          msg: response["message"],
          toastLength: Toast.LENGTH_SHORT,
          webBgColor: "#e74c3c",
          timeInSecForIosWeb: 5,
        );
      }
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

  //Payment method API respond

  getPaymentMethods() async {
    setState(() {
      isLoading = true;
      _paymentItems = [
        PaymentItem(
          label: 'Total',
          amount: "99",
          status: PaymentItemStatus.final_price,
        )
      ];
    });
    print(Constants.paymentMethods);
    List<Payment> itemsTemp = [];
    var result = await http.get(
      Uri.parse(Constants.App_url + Constants.paymentMethods),
      headers: {
        "Content-Type": "application/json",
        'Accept': 'application/json',
      },
    );
    print(result);
    Map<String, dynamic> response = json.decode(result.body);
    print(response);
    if (response["response"] == "success") {
      for (var u in response["paymentmenthods"]) {
        Payment data = Payment(u["name"], u["mode"], u["testing_url"],
            u["live_url"], u["api_key"], u["api_signature"], u["obj"]);
        itemsTemp.add(data);
      }
    }

    setState(() {
      stateItems = itemsTemp;
      isLoading = false;
    });
  }

  // payViaNewCard(BuildContext context) async {
  //   // ProgressDialog dialog = new ProgressDialog(context);
  //   // dialog.style(message: 'Please wait...');
  //   // await dialog.show();
  //
  //   var response = await StripeService.payWithNewCard(
  //       amount: grandTotal.toString(), currency: 'SGD', sk: apiSignature);
  //   // await dialog.hide();
  //   if (response.success!) {
  //     setState(() {
  //       _paymentMethodId = response.paymentIntentId!;
  //       isLoading = false;
  //     });
  //     Fluttertoast.showToast(
  //         msg: response.message!,
  //         toastLength: Toast.LENGTH_LONG,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 10,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.white,
  //         fontSize: 16.0);
  //
  //     print("payment end");
  //     this.orderCreation();
  //   } else {
  //     Fluttertoast.showToast(
  //         msg: response.message!,
  //         toastLength: Toast.LENGTH_LONG,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 10,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.white,
  //         fontSize: 16.0);
  //   }
  // }

  // nativeStripeInit() {
  //   StripeNative.setPublishableKey(apiKey);
  //   if (Platform.isIOS) {
  //     StripeNative.setMerchantIdentifier("merchant.hardwarecity.hardwarecity");
  //   }
  //   // else {
  //   //   StripeNative.setMerchantIdentifier("BCR2DN6T27QIBV2T");
  //   // }
  // }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10), () {
      final Map<String, Object> rcvdData =
          ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
      if (rcvdData != null) {
        setState(() {
          subTotal = double.parse(rcvdData["subtotal"].toString());
          gst = double.parse(rcvdData["gst"].toString());
          ship = rcvdData["shipping"];
          package = double.parse(rcvdData["package"].toString());
          grandTotal = double.parse(rcvdData["total"].toString());

          customerId = int.parse(rcvdData["custId"].toString());
          delOption = rcvdData["shipMethod"].toString();
          itemOption = rcvdData["itemsunavail"].toString();
          billFname = rcvdData["bfn"].toString();
          billLname = rcvdData["bln"].toString();
          billEmail = rcvdData["bem"].toString();
          billPhone = rcvdData["bmob"].toString();
          company = rcvdData["bcom"].toString();
          billAddress1 = rcvdData["badd1"].toString();
          billAddress2 = rcvdData["badd2"].toString();
          billcity = rcvdData["bcit"].toString();
          billstate = rcvdData["bstate"].toString();
          billCountry = rcvdData["bcoun"].toString();
          billzipcode = rcvdData["bzip"].toString();
          shipFname = rcvdData["sfn"].toString();
          shipLname = rcvdData["sln"].toString();
          shipEmail = rcvdData["sem"].toString();
          shipPhone = rcvdData["smob"].toString();
          shippaddress1 = rcvdData["sadd1"].toString();
          shippaddress2 = rcvdData["sadd2"].toString();
          shipcity = rcvdData["scit"].toString();
          shipstate = rcvdData["sstate"].toString();
          shipCountry = rcvdData["scoun"].toString();
          shipzipcode = rcvdData["szip"].toString();
          this.packagefeecalc();
        });
      }
    });

    //print()
    this.getItems();
    this.getPaymentMethods();
  }




  void onApplePayResult(paymentResult) {
    nativepay_error=false;
    createOrderNative(_orderid);

    // Send the resulting Apple Pay token to your server / PSP
  }
  void onApplePayErrorResult(paymentResult) {
    nativepay_error=true;
    createOrderNative(_orderid);

    // Send the resulting Apple Pay token to your server / PSP
  }

  void onGooglePayResult(paymentResult) {
print("result"+paymentResult.toString());
nativepay_error=false;
createOrderNative(_orderid);

    // Send the resulting Google Pay token to your server / PSP
  }
  void onGooglePayErrorResult(paymentResult) {
    print("result"+paymentResult.toString());
    nativepay_error=true;
    createOrderNative(_orderid);

    // Send the resulting Google Pay token to your server / PSP
  }
  @override
  Widget build(BuildContext context) {
    String native = "Google Pay";
    if (Platform.isIOS) {
      native = "Apple Pay";
    }
    var pageWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
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
            "Payment methods",
            style: styles.ThemeText.appbarTextStyles2,
          ),
          actions: <Widget>[
            // add the icon to this list
            // StatusWidget(),
          ],
        ),
        body: isLoading
            ? SpinKitThreeBounce(
                color: Color(Constants.logocolor),
                size: 20.0,
              )
            : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 10, top: 30, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Order summary :",
                                style: styles.ThemeText.editProfileText),
                          ],
                        ),
                        // if (isShow)
                        Container(
                          color: Color(Constants.bggrey),
                          margin: EdgeInsets.only(top: 20, bottom: 20),
                          padding: EdgeInsets.only(
                              left: 10, top: 20, right: 10, bottom: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Products",
                                    style: styles.ThemeText.editProfileText,
                                  ),
                                  Text(
                                    "Total",
                                    style: styles.ThemeText.editProfileText,
                                  ),
                                ],
                              ),
                              ListView.builder(
                                  itemCount: stateItems2.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      margin: EdgeInsets.only(top: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10, top: 20),
                                            child: ClipRRect(
                                                // borderRadius:
                                                //     BorderRadius.all(Radius.circular(30.0)),
                                                child: stateItems2[index]
                                                                .imgPath ==
                                                            null ||
                                                        stateItems2[index]
                                                                .imgPath ==
                                                            ""
                                                    ? Image(
                                                        image: AssetImage(
                                                            'assets/images/placeholder-logo.png'),
                                                        fit: BoxFit.fill,
                                                        height: 70.0,
                                                        width: 70.0)
                                                    : FadeInImage.assetNetwork(
                                                        image: stateItems2[
                                                                index]
                                                            .imgPath,
                                                        placeholder:
                                                            "assets/images/placeholder-logo.png", // your assets image path
                                                        fit: BoxFit.fill,
                                                        height: 70.0,
                                                        width: 70.0)),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  child: stateItems2[index]
                                                              .option !=
                                                          null
                                                      ? Text(
                                                          stateItems2[index]
                                                                  .itemName +
                                                              " - " +
                                                              stateItems2[index]
                                                                  .option,
                                                          style: styles
                                                              .ThemeText
                                                              .appbarTextStyles,
                                                          textAlign:
                                                              TextAlign.left,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 5,
                                                        )
                                                      : Text(
                                                          stateItems2[index]
                                                              .itemName,
                                                          style: styles
                                                              .ThemeText
                                                              .appbarTextStyles,
                                                          textAlign:
                                                              TextAlign.left,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 5,
                                                        ),
                                                ),
                                                Text(
                                                  stateItems2[index]
                                                          .count
                                                          .toString() +
                                                      " x " +
                                                      stateItems2[index]
                                                          .total
                                                          .toStringAsFixed(2)
                                                          .toString(),
                                                  style: styles
                                                      .ThemeText.itemsTextStyle,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 5,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '\$' +
                                                stateItems2[index]
                                                    .price
                                                    .toStringAsFixed(2)
                                                    .toString(),
                                            textAlign: TextAlign.center,
                                            style:
                                                styles.ThemeText.leftTextstyles,
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
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
                                      "Tax collected :",
                                      textAlign: TextAlign.left,
                                      style: styles.ThemeText.editProfileText,
                                    ),
                                    Text(
                                      "\$" + gst!.toStringAsFixed(2),
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
                                      "Shipping fee :",
                                      textAlign: TextAlign.left,
                                      style: styles.ThemeText.editProfileText,
                                    ),
                                    Text(
                                      "\$" + ship.toStringAsFixed(2),
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
                                      "Package fee :",
                                      textAlign: TextAlign.left,
                                      style: styles.ThemeText.editProfileText,
                                    ),
                                    Text(
                                      "\$" + package!.toStringAsFixed(2),
                                      textAlign: TextAlign.left,
                                      style: styles.ThemeText.leftTextstyles,
                                    ),
                                  ],
                                ),
                              ),
                              if (couponApplied)
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Discount ($discountString) :",
                                        textAlign: TextAlign.left,
                                        style: styles.ThemeText.editProfileText,
                                      ),
                                      Text(
                                        "-\$" + discountamt.toStringAsFixed(2),
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
                                      "Grand total :",
                                      textAlign: TextAlign.left,
                                      style: styles.ThemeText.editProfileText,
                                    ),
                                    Text(
                                      "\$" + grandTotal!.toStringAsFixed(2),
                                      textAlign: TextAlign.left,
                                      style: styles.ThemeText.leftTextstyles,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!couponApplied)
                          Text(
                            "Discount coupon :",
                            style: styles.ThemeText.editProfileText,
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            couponApplied
                                ? Container(
                                    width: pageWidth * 0.80,
                                    child: Text(
                                      "\"$couponCode\" couponcode is Applied, you will get $discountString discount",
                                      style: styles.ThemeText.orderStatus,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  )
                                : Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    width: pageWidth * 0.75,
                                    height: 50,
                                    child: TextField(
                                      controller: fieldText,
                                      onChanged: (text) {
                                        setState(() {
                                          couponCode = text;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Enter coupon code',
                                        // prefixIcon: Icon(Icons.search),
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        filled: true,
                                        fillColor: Colors.white70,
                                        //   contentPadding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 19),
                                        //   contentPadding: const EdgeInsets.all(16.0),
                                        contentPadding:
                                            const EdgeInsets.all(5.0),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)),
                                          borderSide: BorderSide(
                                              color: Colors.grey, width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1),
                                        ),
                                      ),
                                    )),
                            Container(
                                decoration: BoxDecoration(
                                  color: Color(Constants.primaryYellow),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                ),
                                width: 50,
                                height: 50,
                                child: IconButton(
                                    icon: couponApplied
                                        ? Icon(
                                            Icons.close,
                                            size: 30,
                                          )
                                        : Icon(
                                            Icons.keyboard_arrow_right,
                                            size: 30,
                                          ),
                                    onPressed: () {
                                      if (couponApplied) {
                                        setState(() {
                                          couponApplied = false;
                                          couponCode = "";
                                          grandTotal =
                                              grandTotal! + discountamt;
                                          discountamt = 0;
                                          discount = 0;
                                          couponId = 0;
                                          fieldText.clear();
                                          Fluttertoast.showToast(
                                            msg: "Couponcode removed",
                                            toastLength: Toast.LENGTH_SHORT,
                                            webBgColor: "#e74c3c",
                                            timeInSecForIosWeb: 5,
                                          );
                                        });
                                      } else if (couponCode != null ||
                                          couponCode != "") {
                                        couponCodeValidate();
                                        fieldText.clear();
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: "Couponcode is empty",
                                          toastLength: Toast.LENGTH_SHORT,
                                          webBgColor: "#e74c3c",
                                          timeInSecForIosWeb: 5,
                                        );
                                      }
                                    }))
                          ],
                        ),
                        Text(
                          "Choose a payment method : ",
                          style: styles.ThemeText.editProfileText,
                        ),
                        for (int i = 0; i < stateItems.length; i++)
                          if (i != 2 && i != 0)
                            RadioListTile(
                              groupValue: option,
                              title: Text(stateItems[i].name,
                                  style: styles.ThemeText.editProfileText2),
                              value: stateItems[i].name,
                              onChanged: (val) {
                                setState(() {
                                  option = val.toString();
                                  apiKey = stateItems[i].apiKey;
                                  apiSignature = stateItems[i].apiSignature;
                                });
                              },
                            ),
                        RadioListTile(
                          groupValue: option,
                          title: Text("Credit & Debit Card",
                              style: styles.ThemeText.editProfileText2),
                          value: "Stripe Pay",
                          onChanged: (val) {
                            setState(() {
                              option = val.toString();
                              apiKey = stateItems[1].apiKey;
                              apiSignature = stateItems[1].apiSignature;
                            });
                          },
                        ),

                        // NATIVE PAYMENT RADIO BUTTON
                        // RadioListTile(
                        //   groupValue: option,
                        //   title: Text(native,
                        //       style: styles.ThemeText.editProfileText2),
                        //   value: "Native Pay",
                        //   onChanged: (val) {
                        //     setState(() {
                        //       option = val.toString();
                        //       apiKey = stateItems[1].apiKey;
                        //       apiSignature = stateItems[1].apiSignature;
                        //     });
                        //   },
                        // ),
    Platform.isIOS ?
    Center(
      child: ApplePayButton(
      paymentConfigurationAsset: 'json/apple_pay.json',
      paymentItems: _paymentItems,
      style: ApplePayButtonStyle.black,
      type: ApplePayButtonType.buy,
      margin: const EdgeInsets.only(top: 15.0),
      onPaymentResult: onApplePayResult,
      onError: onApplePayErrorResult,
      onPressed: (){
        option == "Native Pay";
        orderCreation();
      },
      loadingIndicator: const Center(
      child: CircularProgressIndicator(),
      ),
      ),
    ):
    Center(
      child: GooglePayButton(
      paymentConfigurationAsset: 'json/google_pay.json',
      paymentItems: _paymentItems,
      style: GooglePayButtonStyle.white,
      type: GooglePayButtonType.pay,
      width: 200,
      height:50,
      margin: const EdgeInsets.only(top: 15.0),
      onPaymentResult: onGooglePayResult,
      onError: onGooglePayErrorResult,
      onPressed: (){
        option == "Native Pay";
        orderCreation();
      },
      loadingIndicator: const Center(
      child: CircularProgressIndicator(),
      ),
      ),
    ),

                        Container(
                          margin: EdgeInsets.only(bottom: 10,top: 20),
                          width: pageWidth,
                          height: 50,
                          child: RaisedButton(
                            color: Color(Constants.primaryYellow),
                            shape: styles.ThemeText.borderRaidus1,
                            onPressed: () {
                              try {
                                if (option != null) {
                                  if (option == "Stripe Pay") {
                                    stripePayInitOrder();
                                  }
                                  if (option == "Paypal") {
                                    orderCreation();
                                  }
                                  // //TODO NATIVE PAYMENT
                                  if (option == "Native Pay") {

                                  }
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "Please choose any payment option",
                                    toastLength: Toast.LENGTH_SHORT,
                                    webBgColor: "#e74c3c",
                                    timeInSecForIosWeb: 5,
                                  );
                                }
                              } catch (e) {
                                Loader.hide();
                                Fluttertoast.showToast(
                                  msg: e.toString(),
                                  toastLength: Toast.LENGTH_SHORT,
                                  webBgColor: "#e74c3c",
                                  timeInSecForIosWeb: 5,
                                );
                              }
                            },
                            child: Align(
                              child: Text(
                                'Pay now',
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

class Payment {
  final String name;
  final String mode;
  final String testingUrl;
  final String liveUrl;
  final String apiKey;
  final String apiSignature;
  final Object obj;

  Payment(this.name, this.mode, this.testingUrl, this.liveUrl, this.apiKey,
      this.apiSignature, this.obj);
}

class OrderProducts {
  int id;
  String name;
  String option;
  String qty;
  String price;
  String weight;
  String code;
  String total;

  OrderProducts(this.id, this.name, this.option, this.qty, this.price,
      this.weight, this.code, this.total);
}
