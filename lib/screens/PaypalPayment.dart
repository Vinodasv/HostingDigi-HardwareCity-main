import 'dart:core';

import 'package:HardwareCity/services/PaypalServices.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'PaymentmethodsScreen.dart';

class PaypalPayment extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PaypalPaymentState();
  }
}

class PaypalPaymentState extends State<PaypalPayment> {
  PaymentmethodsScreen payment = new PaymentmethodsScreen();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? checkoutUrl;
  String? executeUrl;
  String? accessToken;
  PaypalServices services = PaypalServices();

  // you can change default currency according to your need
  Map<dynamic, dynamic> defaultCurrency = {
    "symbol": "SGD",
    "decimalDigits": 2,
    "symbolBeforeTheNumber": true,
    "currency": "SGD"
  };

  String returnURL = 'return.example.com';
  String cancelURL = 'cancel.example.com';
  String apiKey = "";
  String secret = "";
  String total = "";
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10), () {
      final Map<String, Object> rcvdData =
          ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
      if (rcvdData != null) {
        setState(() {
          apiKey = rcvdData['apiKey'].toString();
          secret = rcvdData['secret'].toString();
          total = rcvdData['total'].toString();
        });
      }

      Future.delayed(Duration.zero, () async {
        try {
          accessToken = await services.getAccessToken(apiKey, secret);
          //print(accessToken);
          final transactions = getOrderParams();
          //print(transactions);
          final res =
              await services.createPaypalPayment(transactions, accessToken);
          print("createPaypalPayment");
          if (res != null) {
            setState(() {
              checkoutUrl = res["approvalUrl"];
              executeUrl = res["executeUrl"];
            });
          }
        } catch (e) {
          print('exception: ' + e.toString());
          final snackBar = SnackBar(
            content: Text(e.toString()),
            duration: Duration(seconds: 10),
            action: SnackBarAction(
              label: 'Close',
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          );
          _scaffoldKey.currentState!.showSnackBar(snackBar);
        }
      });
    });
  }

  Map<String, dynamic> getOrderParams() {
    Map<String, dynamic> temp = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": total.toString(),
            "currency": defaultCurrency["currency"],
          },
          "description": "Thank you for purchasing from HardwareCity",
          "payment_options": {
            "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
          },
        }
      ],
      "note_to_payer": "Contact us for any questions on your order.",
      "redirect_urls": {"return_url": returnURL, "cancel_url": cancelURL}
    };
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    print(checkoutUrl);

    if (checkoutUrl != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          leading: GestureDetector(
            child: Icon(Icons.arrow_back_ios),
            onTap: () => Navigator.of(context).pop("nil"),
          ),
        ),
        body: Stack(
          children: [
            WebView(
              initialUrl: checkoutUrl,
              javascriptMode: JavascriptMode.unrestricted,
              navigationDelegate: (NavigationRequest request) {
                if (request.url.contains(returnURL)) {
                  final uri = Uri.parse(request.url);
                  final payerID = uri.queryParameters['PayerID'];
                  if (payerID != null) {
                    services
                        .executePayment(executeUrl, payerID, accessToken)
                        .then((id) {
                      print(id.toString());
                      //widget.onFinish(id);
                      Navigator.of(context).pop(id);
                    });
                  } else {
                    Navigator.of(context).pop("nil");
                  }
                }
                if (request.url.contains(cancelURL)) {
                  Navigator.of(context).pop("nil");
                }
                return NavigationDecision.navigate;
              },
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop("nil");
              }),
          backgroundColor: Colors.black12,
          elevation: 0.0,
        ),
        body: Center(child: Container(child: CircularProgressIndicator())),
      );
    }
  }
}
