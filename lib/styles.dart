import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import './constants.dart' as Constants;

abstract class ThemeText {
  static const EdgeInsets InputTextProperties =
      EdgeInsets.symmetric(vertical: 20.0, horizontal: 20);

  static const EdgeInsets topMargin = EdgeInsets.only(
    top: 15.0,
  );

  static const EdgeInsets DefautlLeftRightPadding =
      EdgeInsets.only(left: 25.0, right: 25.0);

  static const OutlineInputBorder inputOutlineBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      const Radius.circular(35.0),
    ),
  );
  static const OutlineInputBorder inputOutlineBorder2 = OutlineInputBorder(
    borderRadius: const BorderRadius.all(
      const Radius.circular(20.0),
    ),
  );
  static const TextStyle subtitleTinyRed =
      TextStyle(fontSize: 11, color: Color(Constants.textredColor));

  static RoundedRectangleBorder borderRaidus1 = RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15)));
  static const TextStyle titleStyles =
      TextStyle(fontSize: 20, color: Color(Constants.primaryBlack));

  static const TextStyle leftTextstyles = TextStyle(
      fontSize: 19,
      color: Color(Constants.black),
      fontFamily: "AvenirLTProBlack");
  static const TextStyle outOfOrder = TextStyle(
      fontSize: 14,
      color: Color(Constants.white),
      fontFamily: "AvenirLTProBlack");

  static const TextStyle rightTextstyles = TextStyle(
      fontSize: 19,
      color: Color(Constants.orange),
      fontFamily: "AvenirLTProMedium");

  static const TextStyle appbarTextStyles = TextStyle(
      fontSize: 16,
      color: Color(Constants.black),
      fontFamily: "AvenirLTProMedium");
  static const TextStyle appbarTextStyles2 = TextStyle(
      fontSize: 20,
      color: Color(Constants.primaryYellow),
      fontFamily: "AvenirLTProBlack");

  static const TextStyle productTextStyles = TextStyle(
      fontSize: 20,
      color: Color(Constants.black),
      fontFamily: "AvenirLTProMedium");

  static const TextStyle priceBold = TextStyle(
      fontSize: 16,
      color: Color(Constants.black),
      fontWeight: FontWeight.bold,
      fontFamily: "AvenirLTProMedium");
  static const TextStyle pricegrey = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: Color(Constants.grey),
      fontFamily: "AvenirLTProMedium");
  static const TextStyle priceBoldStrikethrough = TextStyle(
      fontSize: 13,
      decoration: TextDecoration.lineThrough,
      fontWeight: FontWeight.bold,
      color: Color(Constants.grey),
      fontFamily: "AvenirLTProMedium");
  static const TextStyle priceBoldredthrough = TextStyle(
      fontSize: 13,
      decoration: TextDecoration.lineThrough,
      fontWeight: FontWeight.bold,
      color: Color(Constants.redColor),
      fontFamily: "AvenirLTProMedium");

  static const TextStyle brandName = TextStyle(
      fontSize: 13,
      color: Color(Constants.black),
      fontFamily: "AvenirLTProMedium");
  static const TextStyle offerbrandName = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Color(Constants.white),
      fontFamily: "AvenirLTProMedium");
  static const TextStyle orderStatus = TextStyle(
      fontSize: 14,
      color: Color(Constants.green),
      fontFamily: "AvenirLTProMedium");
  static const TextStyle orderStatus2 = TextStyle(
      fontSize: 14,
      color: Color(Constants.redColor),
      fontFamily: "AvenirLTProMedium");

  static const TextStyle brandNameStrikethrough = TextStyle(
      fontSize: 13,
      decoration: TextDecoration.lineThrough,
      color: Color(Constants.black),
      fontFamily: "AvenirLTProMedium");
  static const TextStyle statusName = TextStyle(
      fontSize: 12,
      color: Color(Constants.black),
      fontFamily: "AvenirLTProMedium");
  static const TextStyle logoTextStyles = TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: Color(Constants.primaryYellow));

  static ThemeData textInputThemeData = ThemeData(
    primaryColor: Color(Constants.primaryBlack),
    //primaryColorDark: Colors.red,
  );

  static TextStyle profileTitlesStyles = TextStyle(
      color: Color(Constants.blackColor),
      fontSize: 16,
      fontFamily: "ProximaNovaSBold");

  static TextStyle normalTextStyle = TextStyle(
      fontSize: 13, fontWeight: FontWeight.normal, color: Colors.black);

  static InputDecoration searchBarStyle = InputDecoration(
    hintText: 'Search Product',
    prefixIcon: Icon(Icons.search),
    hintStyle: TextStyle(color: Colors.grey),
    filled: true,
    fillColor: Colors.white70,
    //   contentPadding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 19),
    //   contentPadding: const EdgeInsets.all(16.0),
    contentPadding: const EdgeInsets.all(5.0),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide(color: Color(0xFFC1C1C1), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide(color: Color(0xFFC1C1C1), width: 1),
    ),
  );
  static const TextStyle categoryTextStyles = TextStyle(
      fontSize: 18,
      color: Color(Constants.white),
      fontFamily: "AvenirLTProHeavy");
  static const TextStyle carttext2 = TextStyle(
      fontSize: 18,
      color: Color(Constants.black),
      fontFamily: "AvenirLTProHeavy");
  static const EdgeInsets margins =
      EdgeInsets.only(top: 15.0, left: 25.0, right: 25.0);
  static const EdgeInsets margin1 =
      EdgeInsets.only(top: 23, left: 25.0, right: 25.0, bottom: 15);

  static const TextStyle inputFieldText = TextStyle(
      fontSize: 14,
      color: Color(Constants.blackColor),
      fontFamily: "AvenirLTProRoman");

  static const TextStyle editProfileText = TextStyle(
      fontSize: 16,
      color: Color(Constants.blackColor),
      fontFamily: "AvenirLTProHeavy");

  static const TextStyle bannerCaptionText = TextStyle(
      fontSize: 14,
      color: Color(Constants.white),
      fontFamily: "AvenirLTProHeavy");

  static const TextStyle bannerHeadText = TextStyle(
      fontSize: 24,
      color: Color(Constants.white),
      fontFamily: "AvenirLTProBlack");

  static const TextStyle loginTextStyle = TextStyle(
      fontSize: 24,
      color: Color(Constants.blackColor),
      fontFamily: "AvenirLTProBlack");

  static const TextStyle buttonTextStyles = TextStyle(
      fontSize: 14,
      color: Color(Constants.blackColor),
      fontFamily: "AvenirLTProBlack");
  static const TextStyle offerTextStyles = TextStyle(
      fontSize: 12, color: Colors.black, fontFamily: "AvenirLTProBlack");
  static const TextStyle buttonTextStyles2 = TextStyle(
      fontSize: 14,
      color: Color(Constants.blackColor),
      fontFamily: "AvenirLTProMedium");
  static const TextStyle carttext1 = TextStyle(
      fontSize: 18,
      color: Color(Constants.black),
      fontFamily: "AvenirLTProMedium");
  static const TextStyle editProfileText2 = TextStyle(
      fontSize: 14,
      color: Color(Constants.blackColor),
      fontFamily: "AvenirLTProRoman");
  static const TextStyle itemsTextStyle = TextStyle(
      fontSize: 14,
      color: Color(Constants.itemgrey),
      fontFamily: "AvenirLTProRoman");
  static const TextStyle dateStyle = TextStyle(
      fontSize: 13,
      color: Color(Constants.itemgrey),
      fontFamily: "AvenirLTProRoman");
  static const TextStyle orderStyle = TextStyle(
      fontSize: 13,
      color: Color(Constants.orderOrange),
      fontFamily: "AvenirLTProMedium");
  static const TextStyle orderStyle2 = TextStyle(
      fontSize: 13,
      color: Color(Constants.green),
      fontFamily: "AvenirLTProHeavy");
  static const TextStyle editbutton = TextStyle(
      fontSize: 14,
      color: Color(Constants.editblue),
      fontFamily: "AvenirLTProRoman");

  static RoundedRectangleBorder borderRadiusOutLine = RoundedRectangleBorder(
      side: BorderSide(
          color: Color(Constants.primaryBlack),
          width: 1,
          style: BorderStyle.solid),
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15)));
  static RoundedRectangleBorder alphabetNotSelected = RoundedRectangleBorder(
      side: BorderSide(
          color: Color(Constants.primaryBlack),
          width: 1,
          style: BorderStyle.solid),
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15)));
  static RoundedRectangleBorder alphabetSelected = RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15)));
}
