import '../customicons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../styles.dart' as styles;
import '../constants.dart' as Constants;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
//import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../states/customerProfileState.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../models/HomeScreenModels.dart';
import '../states/myCartState.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isBrandLoading = false;
  List<CartDataType> stateItems = [];
  String company = "";
  String billEmail = '';
  String billAddress1 = '';
  String billAddress2 = '';
  String zipCode = '';
  String option = '';
  String option2 = '';
  double ship = 0;
  double? grandtotal;
  double subtotal = 0;
  double? gst;
  bool isSelected = true;
  bool isLoading = true;
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
  int? customerId;
  double packageFee = 0.00;
  String countryCode = "SG";
  String taxName = "Tax";
  String taxPercentage = "0";
  List<String> countryName = [];
  List<CountryData> countries = [];

  List<Deliverydata> delItems = [];
  List<Deliverydata> delItems2 = [];

  orderCreation() async {
    var params = {
      "orderinfo": [
        {
          "customer_id": customerId,
          "shippingcost": ship,
          "subtotal": subtotal,
          "packagingfee": packageFee, // static
          "shipmethod": "6",
          "tax_collected": gst,
          "payable_amount": grandtotal,
          "paymethod": "Stripe Pay",
          "if_items_unavailabel": "1",
          "billing": [
            {
              "bill_fname": billFname, // need to change
              "bill_lname": billLname, // need to change
              "bill_email": "balamurugan.sk@gmail.com",
              "bill_mobile": "9003830094",
              "bill_compname": "HWC",
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
              "ship_fname": billFname,
              "ship_lname": billLname,
              "ship_email": "balamurugan.sk@gmail.com",
              "ship_mobile": "9003830094",
              "ship_address1": shippaddress1,
              "ship_address2": shippaddress2,
              "ship_city": shipcity,
              "ship_state": shipstate,
              "ship_country": shipCountry,
              "ship_zip": shipzipcode
            }
          ],
          "products": [
            {
              "id": 14,
              "name": "Weicon 500GM Plastic Metal A",
              "option": "",
              "quantity": 1,
              "price": "200.00",
              "weight": null,
              "code": null,
              "total": "200.00"
            }
          ]
        }
      ]
    };

    var result = await http.post(
      Uri.parse(Constants.App_url + Constants.orderCreate),
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(params),
    );
    print(result);

    Map<String, dynamic> response = json.decode(result.body);
    print(response);

    if (response["response"] == "success") {
      Fluttertoast.showToast(
        msg: response['message'],
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: "#e74c3c",
        timeInSecForIosWeb: 5,
      );
    } else {
      Fluttertoast.showToast(
        msg: response['message'],
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: "#e74c3c",
        timeInSecForIosWeb: 5,
      );
    }
  }

  getCountry() async {
    List<CountryData> itemsTemp = [];
    List<String> itemsTemp2 = [];
    setState(() {
      isLoading = true;
    });
    var result = await http.get(
      Uri.parse(Constants.App_url + Constants.country),
      headers: {
        "Content-Type": "application/json",
      },
    );
    Map<String, dynamic> response = json.decode(result.body);
    if (response["response"] == "success") {
      for (var u in response["countries"]) {
        print("Country called");
        // print(u["countryid"]);
        // print(u["countryname"]);
        // print(u["countrycode"]);
        // print(u["taxtitle"]);
        // print(u["taxpercentage"]);
        CountryData data = CountryData(u["countryid"], u["countryname"],
            u["countrycode"], u["taxtitle"], u["taxpercentage"], u);
        itemsTemp.add(data);
        itemsTemp2.add(u["countryname"]);
      }
      // print(itemsTemp2);

      setState(() {
        countries = itemsTemp;
        countryName = itemsTemp2;
        isLoading = false;
      });
    }
  }

  getdelmethods() async {
    print("called");
    List<Deliverydata> itemstemp = [];
    List<Deliverydata> itemstemp2 = [];

    setState(() {
      isLoading = true;
    });

    var result = await http.get(
      Uri.parse(Constants.App_url + Constants.delmethods),
      headers: {
        "Content-Type": "application/json",
      },
    );

    Map<String, dynamic> response = json.decode(result.body);
    print(response);
    if (response["response"] == "success") {
      // print('saved $value');
      print(response["shippingmethods"]);
      print(response["shippingmethods"].length);
      if (response["shippingmethods"].length > 0) {
        print("called");
        for (var u in response["shippingmethods"]) {
          if (u["id"] != 7) {
            Deliverydata data = Deliverydata(u["id"], u["name"], u["price"], u);
            itemstemp.add(data);
          } else {
            Deliverydata data = Deliverydata(u["id"], u["name"], u["price"], u);
            itemstemp2.add(data);
          }
        }

        // print(imageSliderTemp);
        setState(() {
          delItems = itemstemp;
          delItems2 = itemstemp2;
          ship = double.parse(delItems[0].price);
        });
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
      isLoading = false;
    });
  }

  calculation() {
    int len = stateItems.length;
    subtotal = 0.0;
    grandtotal = 0.0;
    gst = 0.0;
    for (int i = 0; i < len; i++) {
      subtotal = (subtotal + stateItems[i].price);
    }
    for (int i = 0; i < countries.length; i++) {
      if (shipCountry == countries[i].countryCode) {
        gst = (subtotal / 100) * double.parse(countries[i].taxPercentage);
        if (countries[i].taxTitle != null) {
          taxName = countries[i].taxTitle;
          taxPercentage = countries[i].taxPercentage;
        } else {
          taxName = "Tax";
          print(taxName);
        }

        print(taxName);
        break;
      }
    }
    grandtotal = subtotal + gst!;
    gst = double.parse(gst!.toStringAsFixed(2));
    subtotal = double.parse(subtotal.toStringAsFixed(2));
    grandtotal = double.parse(grandtotal!.toStringAsFixed(2));
    packageFee = double.parse(packageFee.toStringAsFixed(2));
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
      if (cartList.length > 0) {
        for (var u in cartList) {
          print("ID : " + u["itemId"].toString());
          print(u["itemId"].runtimeType.toString());

          print("Name" + u["itemName"].runtimeType.toString());

          print("count : " + u["count"].runtimeType.toString());
          print("total : " + u["total"].runtimeType.toString());

          print("price" + u["price"].runtimeType.toString());

          print("img : " + u["imgPath"].runtimeType.toString());
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
          print("1234");
        }
        print("called3");
        print(itemsTemp);
      }
      setState(() {
        stateItems = itemsTemp;
        isBrandLoading = false;
      });
    } catch (e) {}
  }

  bool validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  _checkLogin() {
    print("called");
    final AuthState authState = Provider.of<AuthState>(context, listen: false);
    dynamic loginuserResponse = authState.getLoginUser;
    print(loginuserResponse);
    print(loginuserResponse['isLogin']);

    if (loginuserResponse['isLogin']) {
      print("no error");
      setState(() {
        print(loginuserResponse['customerInfo']["cust_address1"]);
        billAddress1 = loginuserResponse['customerInfo']["cust_address1"];
        billAddress2 = loginuserResponse['customerInfo']["cust_address2"];
        billFname = loginuserResponse['customerInfo']["cust_firstname"];
        billLname = loginuserResponse['customerInfo']["cust_lastname"];
        billEmail = loginuserResponse['customerInfo']["cust_email"];
        billPhone = loginuserResponse['customerInfo']["cust_phone"];
        company = loginuserResponse['customerInfo']["cust_company"];
        zipCode = loginuserResponse['customerInfo']["cust_zip"];
        customerId = loginuserResponse["customerInfo"]["cust_id"];
        print(billFname);
        print(billLname);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    this.getdelmethods();
    this.getCountry();
    Future.delayed(const Duration(milliseconds: 10), () {
      print("called");
      this._checkLogin();
      this.getItems();
      this.calculation();
    });
    option2 = '1';
  }

  @override
  Widget build(BuildContext context) {
    var pageWidth = MediaQuery.of(context).size.width;
    var pageHeight = MediaQuery.of(context).size.height;
    setState(() {
      if (isSelected) {
        shipFname = billFname;
        shipLname = billLname;
        shipEmail = billEmail;
        shipPhone = billPhone;
        shippaddress1 = billAddress1;
        shippaddress2 = billAddress2;
        shipcity = billcity;
        shipstate = billstate;
        shipCountry = billCountry;
        shipzipcode = billzipcode;

        calculation();
        print(shipCountry);
      }
    });

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(Constants.logocolor),

          //backgroundColor: Color(0x44ffffff),
          elevation: 16,
          title: Text(
            "Order Summary",
            style: styles.ThemeText.appbarTextStyles2,
          ),
          leading: IconButton(
            icon: Icon(CustomIcons.backarrow,
                color: Color(Constants.primaryYellow)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: isLoading
            ? SpinKitThreeBounce(
                color: Color(Constants.logocolor),
                size: 20.0,
              )
            : Form(
                key: _formKey,
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(top: 25, left: 25, right: 25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Item's",
                                    style: styles.ThemeText.editProfileText,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                isBrandLoading
                                    ? SpinKitThreeBounce(
                                        color: Color(Constants.logocolor),
                                        size: 20.0,
                                      )
                                    : ListView.builder(
                                        itemCount: stateItems.length,
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Container(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    width: pageWidth / 1.6,
                                                    child: stateItems[index]
                                                                .option !=
                                                            null
                                                        ? Text(
                                                            stateItems[index]
                                                                    .itemName +
                                                                " - " +
                                                                stateItems[
                                                                        index]
                                                                    .option +
                                                                "  x " +
                                                                stateItems[
                                                                        index]
                                                                    .count
                                                                    .toString() +
                                                                " Qty",
                                                            style: styles
                                                                .ThemeText
                                                                .itemsTextStyle,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 5,
                                                          )
                                                        : Text(
                                                            stateItems[index]
                                                                    .itemName +
                                                                "  x " +
                                                                stateItems[
                                                                        index]
                                                                    .count
                                                                    .toString() +
                                                                " Qty",
                                                            style: styles
                                                                .ThemeText
                                                                .itemsTextStyle,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 5,
                                                          ),
                                                  ),
                                                  Text(
                                                      "\$" +
                                                          stateItems[index]
                                                              .price
                                                              .toStringAsFixed(
                                                                  2),
                                                      style: styles.ThemeText
                                                          .itemsTextStyle)
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                Container(
                                  padding: EdgeInsets.only(top: 15),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Color(
                                                  Constants.borderGreyColor),
                                              width: 1.0))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Billing address",
                                          style:
                                              styles.ThemeText.editProfileText),
                                      FlatButton(
                                          onPressed: () {
                                            Navigator.pushNamed(context,
                                                    '/editProfileScreen')
                                                .then((value) {
                                              if (value == "edited") {
                                                _checkLogin();
                                              } // if true and you have come back to your Settings screen
                                            });
                                          },
                                          child: Text("Edit",
                                              style:
                                                  styles.ThemeText.editbutton)),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "$billAddress1\n$billAddress2\n$zipCode",
                                    style: styles.ThemeText.itemsTextStyle,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 5,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 15, bottom: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Country*",
                                                style: styles
                                                    .ThemeText.editProfileText,
                                              )),
                                          Container(
                                            width: pageWidth / 2.5,
                                            height: 80,
                                            padding: EdgeInsets.only(
                                                top: 3, bottom: 5),
                                            child: DropdownSearch<String>(
                                              mode: Mode.DIALOG,
                                              showSelectedItem: true,
                                              validator: (dynamic value) {
                                                if (value == null) {
                                                  return "Please choose Country";
                                                }
                                                return null;
                                              },
                                              items: countryName,
                                              dropdownSearchDecoration:
                                                  InputDecoration(
                                                contentPadding: EdgeInsets.only(
                                                    left: 20,
                                                    top: 5,
                                                    bottom: 5),
                                                border: styles.ThemeText
                                                    .inputOutlineBorder,
                                              ),
                                              hint: "Country",
                                              onChanged: (dynamic value) {
                                                setState(() {
                                                  for (int i = 0;
                                                      i < countries.length;
                                                      i++)
                                                    if (value ==
                                                        countries[i]
                                                            .countryName)
                                                      billCountry = countries[i]
                                                          .countryCode;
                                                  ship = 0.00;
                                                  option = "";
                                                  print(billCountry);
                                                });
                                              },
                                              showSearchBox: true,
                                              searchBoxDecoration:
                                                  InputDecoration(
                                                border: OutlineInputBorder(),
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        12, 12, 8, 0),
                                                hintText: "Search Country",
                                              ),
                                              popupTitle: Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Color(
                                                      Constants.primaryYellow),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text('Select Country',
                                                      style: styles.ThemeText
                                                          .appbarTextStyles),
                                                ),
                                              ),
                                              popupShape:
                                                  RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(24),
                                                  topRight: Radius.circular(24),
                                                  bottomLeft:
                                                      Radius.circular(24),
                                                  bottomRight:
                                                      Radius.circular(24),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 5),
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Town/City*",
                                                style: styles
                                                    .ThemeText.editProfileText,
                                              )),
                                          Container(
                                            width: pageWidth / 2.5,
                                            height: 80,
                                            child: Theme(
                                              data: styles
                                                  .ThemeText.textInputThemeData,
                                              child: TextFormField(
                                                // key: Key(billFname),
                                                // controller: TextEditingController(text: billFname),
                                                keyboardType:
                                                    TextInputType.text,
                                                style: styles
                                                    .ThemeText.normalTextStyle,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          left: 20,
                                                          top: 5,
                                                          bottom: 5),
                                                  hintText: 'Your city name',
                                                  border: styles.ThemeText
                                                      .inputOutlineBorder,
                                                ),
                                                validator: (value) {
                                                  String pattern =
                                                      r'(^[a-zA-Z ]*$)';
                                                  RegExp regExp =
                                                      new RegExp(pattern);
                                                  if (value!.isEmpty) {
                                                    return 'Please enter city name';
                                                  } else if (!regExp
                                                      .hasMatch(value)) {
                                                    return 'Please enter valid city name';
                                                  } else {
                                                    setState(() {
                                                      billcity = value;
                                                    });
                                                  }
                                                  return null;

                                                  //  return null;
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "State/Province*",
                                              style: styles
                                                  .ThemeText.editProfileText,
                                            )),
                                        Container(
                                          width: pageWidth / 2.5,
                                          height: 80,
                                          child: Theme(
                                            data: styles
                                                .ThemeText.textInputThemeData,
                                            child: TextFormField(
                                              // key: Key(billFname),
                                              // controller: TextEditingController(text: billFname),
                                              keyboardType: TextInputType.text,
                                              style: styles
                                                  .ThemeText.normalTextStyle,
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.only(
                                                    left: 20,
                                                    top: 5,
                                                    bottom: 5),
                                                hintText: 'Your state/province',
                                                border: styles.ThemeText
                                                    .inputOutlineBorder,
                                              ),
                                              validator: (value) {
                                                String pattern =
                                                    r'(^[a-zA-Z ]*$)';
                                                RegExp regExp =
                                                    new RegExp(pattern);
                                                if (value!.isEmpty) {
                                                  return 'Please enter state name';
                                                } else if (!regExp
                                                    .hasMatch(value)) {
                                                  return 'Please enter valid state name';
                                                } else {
                                                  setState(() {
                                                    billstate = value;
                                                  });
                                                }
                                                return null;

                                                //  return null;
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Postal/zip code*",
                                              style: styles
                                                  .ThemeText.editProfileText,
                                            )),
                                        Container(
                                          width: pageWidth / 2.5,
                                          height: 80,
                                          child: Theme(
                                            data: styles
                                                .ThemeText.textInputThemeData,
                                            child: TextFormField(
                                              initialValue: zipCode,
                                              key: Key(zipCode),
                                              // controller: TextEditingController(text: billFname),
                                              keyboardType: TextInputType.phone,
                                              style: styles
                                                  .ThemeText.normalTextStyle,
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.only(
                                                    left: 20,
                                                    top: 5,
                                                    bottom: 5),
                                                hintText: 'Your postal code',
                                                border: styles.ThemeText
                                                    .inputOutlineBorder,
                                              ),
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Please enter zipcode name';
                                                } else {
                                                  setState(() {
                                                    billzipcode = value;
                                                  });
                                                }
                                                return null;

                                                //  return null;
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      //padding: styles.ThemeText.DefautlLeftRightPadding,
                                      margin: const EdgeInsets.only(
                                          top: 10, bottom: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                              value: isSelected,
                                              activeColor:
                                                  Color(Constants.primaryBlack),
                                              onChanged: (newvalue) {
                                                setState(() {
                                                  isSelected = newvalue!;
                                                });
                                              }),
                                          Text(
                                            'Ship to same address?',
                                            style: styles
                                                .ThemeText.editProfileText,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,

                                            //style: styles.ThemeText.subRedTextStyles,
                                          )
                                        ],
                                      ),
                                    )),
                                if (!isSelected)
                                  Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Color(Constants
                                                        .borderGreyColor),
                                                    width: 1.0))),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 15, top: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Shipping address",
                                                style: styles
                                                    .ThemeText.editProfileText),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "First name*",
                                                      style: styles.ThemeText
                                                          .editProfileText,
                                                    )),
                                                Container(
                                                  width: pageWidth / 2.5,
                                                  height: 80,
                                                  child: Theme(
                                                    data: styles.ThemeText
                                                        .textInputThemeData,
                                                    child: TextFormField(
                                                      // key: Key(billFname),
                                                      // controller: TextEditingController(text: billFname),
                                                      keyboardType:
                                                          TextInputType.text,
                                                      style: styles.ThemeText
                                                          .normalTextStyle,
                                                      decoration:
                                                          InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                left: 20,
                                                                top: 5,
                                                                bottom: 5),
                                                        hintText:
                                                            ' Your first name',
                                                        border: styles.ThemeText
                                                            .inputOutlineBorder,
                                                      ),
                                                      validator: (value) {
                                                        String pattern =
                                                            r'(^[a-zA-Z ]*$)';
                                                        RegExp regExp =
                                                            new RegExp(pattern);
                                                        if (value!.isEmpty) {
                                                          return 'Please enter first name';
                                                        } else if (!regExp
                                                            .hasMatch(value)) {
                                                          return 'Please enter valid first name';
                                                        } else {
                                                          setState(() {
                                                            shipFname = value;
                                                          });
                                                        }
                                                        return null;

                                                        //  return null;
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "Last name*",
                                                      style: styles.ThemeText
                                                          .editProfileText,
                                                    )),
                                                Container(
                                                  width: pageWidth / 2.5,
                                                  height: 80,
                                                  child: Theme(
                                                    data: styles.ThemeText
                                                        .textInputThemeData,
                                                    child: TextFormField(
                                                      // key: Key(billFname),
                                                      // controller: TextEditingController(text: billFname),
                                                      keyboardType:
                                                          TextInputType.text,
                                                      style: styles.ThemeText
                                                          .normalTextStyle,
                                                      decoration:
                                                          InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                left: 20,
                                                                top: 5,
                                                                bottom: 5),
                                                        hintText:
                                                            'Your last name',
                                                        border: styles.ThemeText
                                                            .inputOutlineBorder,
                                                      ),
                                                      validator: (value) {
                                                        String pattern =
                                                            r'(^[a-zA-Z ]*$)';
                                                        RegExp regExp =
                                                            new RegExp(pattern);
                                                        if (value!.isEmpty) {
                                                          return 'Please enter last name';
                                                        } else if (!regExp
                                                            .hasMatch(value)) {
                                                          return 'Please enter valid last name';
                                                        } else {
                                                          setState(() {
                                                            shipLname = value;
                                                          });
                                                        }
                                                        return null;

                                                        //  return null;
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "Email address*",
                                                      style: styles.ThemeText
                                                          .editProfileText,
                                                    )),
                                                Container(
                                                  width: pageWidth / 2.5,
                                                  height: 80,
                                                  child: Theme(
                                                    data: styles.ThemeText
                                                        .textInputThemeData,
                                                    child: TextFormField(
                                                        // key: Key(billFname),
                                                        // controller: TextEditingController(text: billFname),
                                                        keyboardType:
                                                            TextInputType.text,
                                                        style: styles.ThemeText
                                                            .normalTextStyle,
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets.only(
                                                                  left: 20,
                                                                  top: 5,
                                                                  bottom: 5),
                                                          hintText:
                                                              ' Your email address',
                                                          border: styles
                                                              .ThemeText
                                                              .inputOutlineBorder,
                                                        ),
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return 'Please enter your email';
                                                          } else {
                                                            if (validateEmail(
                                                                value)) {
                                                              setState(() {
                                                                shipEmail =
                                                                    value;
                                                              });
                                                            } else {
                                                              return 'Incorrect Email Format';
                                                            }
                                                          }
                                                          return null;
                                                        }),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "Phone*",
                                                      style: styles.ThemeText
                                                          .editProfileText,
                                                    )),
                                                Container(
                                                  width: pageWidth / 2.5,
                                                  height: 80,
                                                  child: Theme(
                                                    data: styles.ThemeText
                                                        .textInputThemeData,
                                                    child: TextFormField(
                                                      // key: Key(billFname),
                                                      // controller: TextEditingController(text: billFname),
                                                      keyboardType:
                                                          TextInputType.phone,
                                                      style: styles.ThemeText
                                                          .normalTextStyle,
                                                      decoration:
                                                          InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                left: 20,
                                                                top: 5,
                                                                bottom: 5),
                                                        hintText: 'Your phone',
                                                        border: styles.ThemeText
                                                            .inputOutlineBorder,
                                                      ),
                                                      validator: (value) {
                                                        String patttern =
                                                            r'(^(?:[+0]9)?[0-9]{8,15}$)';
                                                        RegExp regExp =
                                                            new RegExp(
                                                                patttern);
                                                        if (value!.isEmpty) {
                                                          return 'Please enter phone number';
                                                        } else if (!regExp
                                                            .hasMatch(value)) {
                                                          return 'Please enter valid phone number';
                                                        } else {
                                                          setState(() {
                                                            shipPhone = value;
                                                          });
                                                        }

                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "Address line 1*",
                                                  style: styles.ThemeText
                                                      .editProfileText,
                                                )),
                                            Container(
                                              width: pageWidth,
                                              height: 80,
                                              child: Theme(
                                                data: styles.ThemeText
                                                    .textInputThemeData,
                                                child: TextFormField(
                                                    // key: Key(billFname),
                                                    // controller: TextEditingController(text: billFname),
                                                    keyboardType:
                                                        TextInputType.text,
                                                    style: styles.ThemeText
                                                        .normalTextStyle,
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              left: 20,
                                                              top: 5,
                                                              bottom: 5),
                                                      hintText:
                                                          'Your address line 1',
                                                      border: styles.ThemeText
                                                          .inputOutlineBorder,
                                                    ),
                                                    validator: (value) {
                                                      if (value!.isEmpty) {
                                                        return 'Please enter address line 1';
                                                      } else {
                                                        setState(() {
                                                          shippaddress1 = value;
                                                        });
                                                      }
                                                      return null;
                                                    }),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "Address line 2",
                                                  style: styles.ThemeText
                                                      .editProfileText,
                                                )),
                                            Container(
                                              width: pageWidth,
                                              height: 80,
                                              child: Theme(
                                                data: styles.ThemeText
                                                    .textInputThemeData,
                                                child: TextFormField(
                                                    // key: Key(billFname),
                                                    // controller: TextEditingController(text: billFname),
                                                    keyboardType:
                                                        TextInputType.text,
                                                    style: styles.ThemeText
                                                        .normalTextStyle,
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              left: 20,
                                                              top: 5,
                                                              bottom: 5),
                                                      hintText:
                                                          'Your address line 2',
                                                      border: styles.ThemeText
                                                          .inputOutlineBorder,
                                                    ),
                                                    validator: (value) {
                                                      if (value!.isEmpty) {
                                                        return 'Please enter address line 2';
                                                      } else {
                                                        setState(() {
                                                          shippaddress2 = value;
                                                        });
                                                      }
                                                      return null;
                                                    }),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 15, bottom: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "Country*",
                                                      style: styles.ThemeText
                                                          .editProfileText,
                                                    )),
                                                Container(
                                                  width: pageWidth / 2.5,
                                                  height: 80,
                                                  padding: EdgeInsets.only(
                                                      top: 3, bottom: 5),
                                                  child: DropdownSearch<String>(
                                                    mode: Mode.DIALOG,
                                                    showSelectedItem: true,
                                                    validator: (dynamic value) {
                                                      if (value == null) {
                                                        return "Please choose Country";
                                                      }
                                                      return null;
                                                    },
                                                    items: countryName,
                                                    dropdownSearchDecoration:
                                                        InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              left: 20,
                                                              top: 5,
                                                              bottom: 5),
                                                      border: styles.ThemeText
                                                          .inputOutlineBorder,
                                                    ),
                                                    hint: "Country",
                                                    onChanged: (dynamic value) {
                                                      setState(() {
                                                        for (int i = 0;
                                                            i <
                                                                countries
                                                                    .length;
                                                            i++)
                                                          if (value ==
                                                              countries[i]
                                                                  .countryName)
                                                            shipCountry =
                                                                countries[i]
                                                                    .countryCode;

                                                        ship = 0.00;
                                                        option = "";
                                                        calculation();
                                                        print(shipCountry);
                                                      });
                                                    },
                                                    showSearchBox: true,
                                                    searchBoxDecoration:
                                                        InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      contentPadding:
                                                          EdgeInsets.fromLTRB(
                                                              12, 12, 8, 0),
                                                      hintText:
                                                          "Search Country",
                                                    ),
                                                    popupTitle: Container(
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        color: Color(Constants
                                                            .primaryYellow),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  20),
                                                          topRight:
                                                              Radius.circular(
                                                                  20),
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                            'Select Country',
                                                            style: styles
                                                                .ThemeText
                                                                .appbarTextStyles),
                                                      ),
                                                    ),
                                                    popupShape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(24),
                                                        topRight:
                                                            Radius.circular(24),
                                                        bottomLeft:
                                                            Radius.circular(24),
                                                        bottomRight:
                                                            Radius.circular(24),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Container(
                                                //   width: pageWidth / 2.5,
                                                //   child: Card(
                                                //     color: Color(
                                                //         Constants.lightgreycolor),
                                                //     semanticContainer: true,
                                                //     clipBehavior:
                                                //         Clip.antiAliasWithSaveLayer,
                                                //     shape: styles
                                                //         .ThemeText.inputOutlineBorder,
                                                //     child: ListTile(
                                                //       title: _buildCupertinoItem(
                                                //           _selectedCupertinoCountryshipping),
                                                //       onTap:
                                                //           _openCupertinoCountryPickershipping,
                                                //     ),
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        bottom: 5),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "Town/City*",
                                                      style: styles.ThemeText
                                                          .editProfileText,
                                                    )),
                                                Container(
                                                  width: pageWidth / 2.5,
                                                  height: 80,
                                                  child: Theme(
                                                    data: styles.ThemeText
                                                        .textInputThemeData,
                                                    child: TextFormField(
                                                        // key: Key(billFname),
                                                        // controller: TextEditingController(text: billFname),
                                                        keyboardType:
                                                            TextInputType.text,
                                                        style: styles.ThemeText
                                                            .normalTextStyle,
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets.only(
                                                                  left: 20,
                                                                  top: 5,
                                                                  bottom: 5),
                                                          hintText:
                                                              'Your city name',
                                                          border: styles
                                                              .ThemeText
                                                              .inputOutlineBorder,
                                                        ),
                                                        validator: (value) {
                                                          String pattern =
                                                              r'(^[a-zA-Z ]*$)';
                                                          RegExp regExp =
                                                              new RegExp(
                                                                  pattern);
                                                          if (value!.isEmpty) {
                                                            return 'Please enter Town/City';
                                                          } else if (!regExp
                                                              .hasMatch(
                                                                  value)) {
                                                            return 'Please enter a valid Town/City';
                                                          } else {
                                                            setState(() {
                                                              shipcity = value;
                                                            });
                                                          }
                                                          return null;
                                                        }),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(bottom: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "State/Province*",
                                                      style: styles.ThemeText
                                                          .editProfileText,
                                                    )),
                                                Container(
                                                  width: pageWidth / 2.5,
                                                  height: 80,
                                                  child: Theme(
                                                    data: styles.ThemeText
                                                        .textInputThemeData,
                                                    child: TextFormField(
                                                        // key: Key(billFname),
                                                        // controller: TextEditingController(text: billFname),
                                                        keyboardType:
                                                            TextInputType.text,
                                                        style: styles.ThemeText
                                                            .normalTextStyle,
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets.only(
                                                                  left: 20,
                                                                  top: 5,
                                                                  bottom: 5),
                                                          hintText:
                                                              'Your state/province',
                                                          border: styles
                                                              .ThemeText
                                                              .inputOutlineBorder,
                                                        ),
                                                        validator: (value) {
                                                          String pattern =
                                                              r'(^[a-zA-Z ]*$)';
                                                          RegExp regExp =
                                                              new RegExp(
                                                                  pattern);
                                                          if (value!.isEmpty) {
                                                            return 'Please enter State/Province';
                                                          } else if (!regExp
                                                              .hasMatch(
                                                                  value)) {
                                                            return 'Please enter a valid State/Province';
                                                          } else {
                                                            setState(() {
                                                              shipstate = value;
                                                            });
                                                          }
                                                          return null;
                                                        }),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "Postal/zip code*",
                                                      style: styles.ThemeText
                                                          .editProfileText,
                                                    )),
                                                Container(
                                                  width: pageWidth / 2.5,
                                                  height: 80,
                                                  child: Theme(
                                                    data: styles.ThemeText
                                                        .textInputThemeData,
                                                    child: TextFormField(
                                                        // key: Key(billFname),
                                                        // controller: TextEditingController(text: billFname),
                                                        keyboardType:
                                                            TextInputType.phone,
                                                        style: styles.ThemeText
                                                            .normalTextStyle,
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets.only(
                                                                  left: 20,
                                                                  top: 5,
                                                                  bottom: 5),
                                                          hintText:
                                                              'Your postal code',
                                                          border: styles
                                                              .ThemeText
                                                              .inputOutlineBorder,
                                                        ),
                                                        validator: (value) {
                                                          String pattern =
                                                              r'(^[A-Z0-9 ]*$)';
                                                          RegExp regExp =
                                                              new RegExp(
                                                                  pattern);
                                                          if (value!.isEmpty) {
                                                            return 'Please enter postal code';
                                                          } else if (!regExp
                                                              .hasMatch(
                                                                  value)) {
                                                            return 'Please enter a valid postal code';
                                                          } else {
                                                            setState(() {
                                                              shipzipcode =
                                                                  value;
                                                            });
                                                          }
                                                          return null;
                                                        }),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Color(
                                                  Constants.borderGreyColor),
                                              width: 1.0))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Delivery methods",
                                      style: styles.ThemeText.editProfileText,
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isLoading)
                            SpinKitThreeBounce(
                              color: Color(Constants.logocolor),
                              size: 20.0,
                            )
                          else if (shipCountry == "SG")
                            for (int i = 0; i < delItems.length; i++)
                              RadioListTile(
                                groupValue: option,
                                title: Text(
                                  delItems[i].delmethod,
                                  style: styles.ThemeText.itemsTextStyle,
                                ),
                                value: delItems[i].id.toString(),
                                onChanged: (val) {
                                  setState(() {
                                    option = val.toString();
                                    ship = double.parse(
                                        double.parse(delItems[i].price)
                                            .toStringAsFixed(2));
                                    calculation();
                                    print(val);
                                  });
                                },
                              )
                          else
                            for (int i = 0; i < delItems2.length; i++)
                              RadioListTile(
                                groupValue: option,
                                title: Text(
                                  delItems2[i].delmethod,
                                  style: styles.ThemeText.itemsTextStyle,
                                ),
                                value: delItems2[i].id.toString(),
                                onChanged: (val) {
                                  setState(() {
                                    option = val.toString();
                                    ship = double.parse(
                                        double.parse(delItems2[i].price)
                                            .toStringAsFixed(2));
                                    calculation();
                                    print(val);
                                  });
                                },
                              ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: Container(
                              padding: EdgeInsets.only(top: 20),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color:
                                              Color(Constants.borderGreyColor),
                                          width: 1.0))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 25, left: 25),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "If item's unavailable",
                                style: styles.ThemeText.editProfileText,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          RadioListTile(
                            groupValue: option2,
                            title: Text('Call me',
                                style: styles.ThemeText.itemsTextStyle),
                            value: '1',
                            onChanged: (val) {
                              setState(() {
                                option2 = val.toString();
                              });
                            },
                          ),
                          RadioListTile(
                            groupValue: option2,
                            title: Text('Do not replace',
                                style: styles.ThemeText.itemsTextStyle),
                            value: '2',
                            onChanged: (val) {
                              setState(() {
                                option2 = val.toString();
                              });
                            },
                          ),
                          RadioListTile(
                            groupValue: option2,
                            title: Text('Replace with similar item(s)',
                                style: styles.ThemeText.itemsTextStyle),
                            value: '3',
                            onChanged: (val) {
                              setState(() {
                                option2 = val.toString();
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: Container(
                              padding: EdgeInsets.only(top: 15),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color:
                                              Color(Constants.borderGreyColor),
                                          width: 1.0))),
                            ),
                          ),
                          Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                padding:
                                    styles.ThemeText.DefautlLeftRightPadding,
                                margin:
                                    const EdgeInsets.only(bottom: 5, top: 10),
                                child: Text(
                                    "* Shipping fee will be calculated based on country",
                                    style: styles.ThemeText.subtitleTinyRed),
                              )),
                          Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                padding:
                                    styles.ThemeText.DefautlLeftRightPadding,
                                margin: const EdgeInsets.only(bottom: 5),
                                child: Text(
                                    "* package fee will be calculated based on weight & country",
                                    style: styles.ThemeText.subtitleTinyRed),
                              )),
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: pageWidth / 4),
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
                                            Text("\$$subtotal",
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
                                            Container(
                                              width: pageWidth * 0.50,
                                              child: Text(
                                                "$taxName($taxPercentage%) : ",
                                                style:
                                                    styles.ThemeText.carttext1,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 5,
                                              ),
                                            ),
                                            Text("\$" + gst!.toStringAsFixed(2),
                                                style:
                                                    styles.ThemeText.carttext2),
                                          ],
                                        ),
                                      ),
                                      // Padding(
                                      //   padding: const EdgeInsets.only(
                                      //       right: 20, top: 10, bottom: 20),
                                      //   child: Row(
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.spaceBetween,
                                      //     children: [
                                      //       Container(
                                      //         width: pageWidth*0.50,
                                      //         child: Text(
                                      //           "Shipping fee (will be calculated based on country) : ",
                                      //           style: styles.ThemeText.carttext1,
                                      //           overflow: TextOverflow.ellipsis,
                                      //             maxLines: 5,
                                      //         ),
                                      //       ),
                                      //       Text("\$" + ship.toStringAsFixed(2),
                                      //           style:
                                      //               styles.ThemeText.carttext2),
                                      //     ],
                                      //   ),
                                      // ),
                                      // Padding(
                                      //   padding: const EdgeInsets.only(
                                      //       right: 20, top: 10, bottom: 20),
                                      //   child: Row(
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.spaceBetween,
                                      //     children: [
                                      //       Container(
                                      //         width: pageWidth*0.50,
                                      //         child: Text(
                                      //           "Package fee (will be calculated based on weight): ",
                                      //           overflow: TextOverflow.ellipsis,
                                      //             maxLines: 5,
                                      //           style: styles.ThemeText.carttext1,
                                      //         ),
                                      //       ),
                                      //       Text(
                                      //           "\$" +
                                      //               packageFee.toStringAsFixed(2),
                                      //           style:
                                      //               styles.ThemeText.carttext2),
                                      //     ],
                                      //   ),
                                      // ),
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
                                              style: styles
                                                  .ThemeText.leftTextstyles,
                                            ),
                                            Text("\$$grandtotal",
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
                                      if (_formKey.currentState!.validate()) {
                                        if (isSelected) {
                                          shipFname = billFname;
                                          shipLname = billLname;
                                          shipEmail = billEmail;
                                          shipPhone = billPhone;
                                          shippaddress1 = billAddress1;
                                          shippaddress2 = billAddress2;
                                          shipcity = billcity;
                                          shipstate = billstate;
                                          shipCountry = billCountry;
                                          shipzipcode = billzipcode;

                                          calculation();
                                          print(shipCountry);
                                        }
                                        if (option != '') {
                                          Navigator.pushNamed(
                                              context, '/paymentmethods',
                                              arguments: {
                                                "custId": customerId,
                                                "shipMethod": option,
                                                "itemsunavail": option2,
                                                "subtotal": subtotal,
                                                "gst": gst,
                                                "shipping": ship,
                                                "package": packageFee,
                                                "total": grandtotal,
                                                "bfn": billFname,
                                                "bln": billLname,
                                                "bem": billEmail,
                                                "bmob": billPhone,
                                                "bcom": company,
                                                "badd1": billAddress1,
                                                "badd2": billAddress2,
                                                "bcit": billcity,
                                                "bstate": billstate,
                                                "bcoun": billCountry,
                                                "bzip": billzipcode,
                                                "sfn": shipFname,
                                                "sln": shipLname,
                                                "sem": shipEmail,
                                                "smob": shipPhone,
                                                "sadd1": shippaddress1,
                                                "sadd2": shippaddress2,
                                                "scit": shipcity,
                                                "sstate": shipstate,
                                                "scoun": shipCountry,
                                                "szip": shipzipcode
                                              });
                                        } else {
                                          Fluttertoast.showToast(
                                            msg:
                                                "Please choose a delivery option",
                                            toastLength: Toast.LENGTH_SHORT,
                                            webBgColor: "#e74c3c",
                                            timeInSecForIosWeb: 5,
                                          );
                                        }
                                      }
                                    },
                                    child: Align(
                                      child: Text(
                                        'Place order',
                                        style:
                                            styles.ThemeText.buttonTextStyles,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
  }
}

class AllItemsDataType {
  final String itemName;
  final String price;
  final Object Obj;

  AllItemsDataType(this.itemName, this.price, this.Obj);
}

class Deliverydata {
  final String delmethod;
  final int id;
  final String price;
  final Object obj;

  Deliverydata(this.id, this.delmethod, this.price, this.obj);
}

class CountryData {
  final int countryId;
  final String countryName;
  final String countryCode;
  final String taxTitle;
  final String taxPercentage;
  final Object obj;

  CountryData(this.countryId, this.countryName, this.countryCode, this.taxTitle,
      this.taxPercentage, this.obj);
}
