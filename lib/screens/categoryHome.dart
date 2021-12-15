import 'package:flutter/material.dart';
import '../styles.dart' as styles;
import '../constants.dart' as Constants;
import 'package:flutter_spinkit/flutter_spinkit.dart';
//import 'package:flappy_search_bar/flappy_search_bar.dart';

class CategoryHomeScreen extends StatefulWidget {
  @override
  _CategoryHomeScreenState createState() => _CategoryHomeScreenState();
}

class _CategoryHomeScreenState extends State<CategoryHomeScreen> {
  @override
  void initState() {
    super.initState();
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

          //backgroundColor: Color(0x44ffffff),
          elevation: 16,
          title: Text(
            "My History",
            style: styles.ThemeText.appbarTextStyles2,
          ),
        ),
        body: SpinKitThreeBounce(
          color: Color(Constants.logocolor),
          size: 20.0,
        ));
  }
}
