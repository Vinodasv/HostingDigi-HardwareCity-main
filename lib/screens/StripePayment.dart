import 'dart:convert';
import 'dart:developer';

import 'package:HardwareCity/screens/myOrders.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripePayment extends StatefulWidget {
  final String cartAmmount;
  final String? merchantCountyCode;
  final String customerId;
  final String orderId;
  StripePayment(
      {required this.customerId,
      required this.orderId,
      this.merchantCountyCode,
      required this.cartAmmount,
      Key? key})
      : super(key: key);

  @override
  _StripePaymentState createState() => _StripePaymentState();
}

class _StripePaymentState extends State<StripePayment> {
  bool onPaymentSucess = false;
  bool onPayemntFailed = false;
  Map<String, dynamic>? paymentIntentData;
  Future<void> checkout(String Ammount) async {
    Map<String, dynamic> body = {
      'amount': Ammount,
      'currency': "sgd",
    };

    final response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: body,
        headers: {
          'Authorization':
              "Bearer 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",
          // "Bearer sk_test_51H41xgIstCqISsuzlpqDSmVXJzah1N64AhQoio33cNdGd0Hiy3k3E2r52EbRyFsUbHAaXKcLtiy3Sem71P4fdrab00ORClf0uZ",
          'Content-Type': 'application/x-www-form-urlencoded'
        });
    if (response.statusCode == 200) {
      paymentIntentData = json.decode(response.body);

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        applePay: true,
        googlePay: true,
        style: ThemeMode.dark,
        testEnv: false,
        //kReleaseMode == true ? false : true,
        merchantCountryCode: 'SG',
        merchantDisplayName: 'HardwareCity',
        customerId: "Customer id",
        paymentIntentClientSecret: paymentIntentData!['client_secret'],
      ));
      try {
        await Stripe.instance.presentPaymentSheet(
            // ignore: deprecated_member_use
            parameters: PresentPaymentSheetParameters(
          clientSecret: paymentIntentData!['client_secret'],
          confirmPayment: true,
        ));

        final response = http.post(Uri.parse(
            "https://www.hardwarecity.com.sg/successorder?orderid=${widget.orderId}&transactionid="));
        paymentIntentData = null;
        print(response);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("paid successfully")));
        setState(() {
          onPaymentSucess = true;
        });

        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MyOrdersScreen()),
              (route) => false);
          // payment done navigation goes here
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => const HomeScreen()));
        });
      } catch (e) {
        log(e.toString());
        final httpresponse = await http.post(Uri.parse(
            "https://hardwarecity.com.sg/cancelorder?orderid=${widget.orderId}"));
        // paymentIntentData = null;
        //log("$httpresponse");
        final failedresponse = json.decode(httpresponse.body);
        if (failedresponse != null) {
          print("------------------------------------------------");
          print("failed response is :$failedresponse");
          print("${failedresponse["messgage"]}");
        }
        //https://hardwarecity.com.sg/cancelorder?orderid=15505
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Payment Canceled.")));
        setState(() {
          onPayemntFailed = true;
        });
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop();
        });
      }
      //Stripe.instance.confirmPayment(paymentIntentClientSecret, data)
    }
  }

  String getCalculatedAmmount(String ammount) {
    //int? tempPrice;
    // var cartPrise = int.parse(ammount);
    // var finalPrice = cartPrise.floor();
    // return finalPrice.toString();
    var Calculatedprice = double.parse(ammount) * 100;
    return Calculatedprice.floor().toString();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      checkout(getCalculatedAmmount(widget.cartAmmount));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: UniqueKey(),
      body: onPayemntFailed
          ? const Center(
              child: Text("Payment Failed."),
            )
          : Center(
              child: onPaymentSucess
                  ? const Text("Payment successfull..!")
                  : const CircularProgressIndicator(),
            ),
    );
  }
}
