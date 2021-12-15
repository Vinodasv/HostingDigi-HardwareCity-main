import '../customicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
import '../styles.dart' as styles;
import '../constants.dart' as Constants;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_html/flutter_html.dart';
//import 'package:flappy_search_bar/flappy_search_bar.dart';

class TermsAndConditions extends StatefulWidget {
  @override
  _TermsAndConditionsState createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  String terms = '';
  bool isLoading = false;
  getTerms() async {
    try {
      print("called");
      String termsTemp;

      setState(() {
        isLoading = true;
      });
      print(Constants.App_url + Constants.terms);
      var result = await http.get(
        Uri.parse(Constants.App_url + Constants.terms),
        headers: {
          "Content-Type": "application/json",
        },
      );
      // var answers = result.body[0]['answers'] as List<Map<String, Object>>;
      for (var u in json.decode(result.body)) {
        print(u);
        setState(() {
          terms = u["termsandconditions"];
        });
      }
      print(terms);

      // print(response);
      // print(response[0]["termsandconditions"]);
      // terms = response[0]["termsandconditions"];
      // data
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    this.getTerms();
  }

  @override
  Widget build(BuildContext context) {
    var pageWidth = MediaQuery.of(context).size.width;
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
            "Terms & Conditions",
            style: styles.ThemeText.appbarTextStyles2,
          ),
        ),
        body: isLoading
            ? SpinKitThreeBounce(
                color: Color(Constants.logocolor),
                size: 20.0,
              )
            : SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Html(
                    data: terms,
                    style: {
                      "html": Style(
                          color: Colors.black, textAlign: TextAlign.justify),
                    },
                  ),
                ),
              ));
  }
}
