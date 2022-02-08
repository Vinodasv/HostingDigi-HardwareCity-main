import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../constants.dart' as Constants;
import '../customicons.dart';
import '../services/firebaseStorage.dart';
import '../states/customerProfileState.dart';
import '../states/myCartState.dart';
import '../styles.dart' as styles;
import '../widgets/Loader.dart';
import '../widgets/floatingCart.dart';

class SingleProductDetailsScreen extends StatefulWidget {
  @override
  _SingleProductDetailsScreenState createState() =>
      _SingleProductDetailsScreenState();
}

class _SingleProductDetailsScreenState
    extends State<SingleProductDetailsScreen> {
  final _pName = TextEditingController();
  final _pComment = TextEditingController();
  final _pEmail = TextEditingController();

  int _current = 0;
  List<OptionDataType> options = [];
  List stateGallery = [];
  int count = 1;
  bool inCart = false;
  double fixPadding = 10.0;
  int? optCount;
  bool isLoading = false;
  String imgLink = "";
  String productId = "";
  String firstName = '';
  String comments = '';
  String customerName = '';
  String productName = "";
  String shippingBox = "";
  String price = "";
  String gstprice = "";
  String standardgstprice = "";
  Widget? viewText;
  String standardprice = "";
  String desc = '';
  String spec = '';
  String down = '';
  String fq = '';
  String sdesc = "";
  String color = '';
  String size = '';
  String weight = '';
  List<Widget> imageList = [];
  String customerId = '';
  String pId = '';
  String pName = '';
  int? qty;
  int? custQty;
  double? qp;
  double? tp;
  String img = '';
  dynamic selectopt;
  double reviewRating = 0;
  int? reviewNumbers;
  String videoLink = '';
  int? optionId;
  List<String> optionName = [];
  bool iscartLoading = false;
  String baseprice = '';
  String option = '';
  List<Review> stateReview = [];
  int pressed = 1;
  final _formKey = GlobalKey<FormState>();
  String url1 = "";
  String url2 = "";

  changeByOptions(value) {
    for (var u in options) {
      if (value == u.name) {
        setState(() {
          price = (double.parse(baseprice) + double.parse(u.price)).toString();
          gstprice=u.gstprice.toString();
          weight = u.weight.toString();
          optionId = u.optionId;
          option = u.name;
          print(u.name);
        });
      }
    }
  }

  addtoCart(productId, count, custQty) async {
    setState(() {
      iscartLoading = true;
    });
    Loader.show(context, progressIndicator: CupertinoActivityIndicator());
    final AuthState authState = Provider.of<AuthState>(context, listen: false);
    dynamic loginuserResponse = authState.getLoginUser;
    final CartState cartItems = Provider.of<CartState>(context, listen: false);
    var cartList = cartItems.cart;

    setState(() {
      customerId = loginuserResponse["customerInfo"]["cust_id"].toString();
      customerName =
          loginuserResponse["customerInfo"]["cust_firstname"].toString();
    });
    // if (loginuserResponse['isLogin']) {
    var body = json.encode({
      "productid": productId,
      "qty": count,
      "optionid": optionId,
      "customerid": customerId
    });
    print(body);
    print(Constants.addToCart);
    var result =
        await http.post(Uri.parse(Constants.App_url + Constants.addToCart),
            headers: {
              "Content-Type": "application/json",
              'Accept': 'application/json',
            },
            body: body);

    Map<String, dynamic> response = json.decode(result.body);

    if (response["response"] == "success") {
      print("called");
      if (cartList.length > 0) {
        var isPresent = false;

        /*  If item already present in the list it wiill add to list */
        for (var i = 0; i < cartList.length; i++) {
          if (cartList[i]["itemId"] == productId) {
            print("already exist");
            isPresent = true;
            cartList[i]["count"] = count;
            cartList[i]["total"] = double.parse(
                response["cartdetails"][customerId][0]["total"].toString());
            cartList[i]["price"] = double.parse(
                response["cartdetails"][customerId][0]["price"].toString());
            cartList[i]["option"] = option;
            Fluttertoast.showToast(
              msg: "Item updated to cart",
              toastLength: Toast.LENGTH_SHORT,
              webBgColor: "#e74c3c",
              timeInSecForIosWeb: 5,
            );
          }
        }
        print("after");
        for (var u in cartList) {
          print("ID : " + u["itemId"].toString());

          print("Name" + u["itemName"].toString());

          print("count : " + u["count"].toString());
          print("total : " + u["total"].toString());

          print("price" + u["price"].toString());

          print("img : " + u["imgPath"].toString());
        }
        print("celled3");
        /* it will check whether given item present in list or not , if not will add to cart */
        if (!isPresent) {
          print("celled4");
          cartList.add({
            // "custid": customerId,
            "custQty": custQty,
            "itemId":
                response["cartdetails"][customerId][0]["productId"].toString(),
            "itemName": response["cartdetails"][customerId][0]["productName"]
                .toString(),
            "count": response["cartdetails"][customerId][0]["qty"],
            "price": double.parse(
                response["cartdetails"][customerId][0]["price"].toString()),
            "total": double.parse(
                response["cartdetails"][customerId][0]["total"].toString()),
            "imgPath":
                response["cartdetails"][customerId][0]["image"].toString(),
            "weight": weight,
            "shipbox": shippingBox,
            "option": option,
          });

          Fluttertoast.showToast(
            msg: "Item added to cart",
            toastLength: Toast.LENGTH_SHORT,
            webBgColor: "#e74c3c",
            timeInSecForIosWeb: 5,
          );
        }
      } else {
        print("celled5");
        cartList.add({
          // "custid": customerId,
          "custQty": custQty,
          "itemId":
              response["cartdetails"][customerId][0]["productId"].toString(),
          "itemName":
              response["cartdetails"][customerId][0]["productName"].toString(),
          "count": response["cartdetails"][customerId][0]["qty"],
          "price": double.parse(
              response["cartdetails"][customerId][0]["price"].toString()),
          "total": double.parse(
              response["cartdetails"][customerId][0]["total"].toString()),
          "imgPath": response["cartdetails"][customerId][0]["image"].toString(),
          "weight": weight,
          "shipbox": shippingBox,
          "option": option,
        });
        Fluttertoast.showToast(
          msg: "Item added to cart",
          toastLength: Toast.LENGTH_SHORT,
          webBgColor: "#e74c3c",
          timeInSecForIosWeb: 5,
        );
      }
      cartItems.saveCart(cartList);
      cartModify(cartList.length, customerId, customerName);
      setState(() {
        iscartLoading = false;
      });
    } else {
      Fluttertoast.showToast(
        msg: response["message"],
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: "#e74c3c",
        timeInSecForIosWeb: 5,
      );
    }
    // } else {
    //   setState(() {
    //     iscartLoading = false;
    //   });
    //   Fluttertoast.showToast(
    //     msg: "Please login to add",
    //     toastLength: Toast.LENGTH_SHORT,
    //     webBgColor: "#e74c3c",
    //     timeInSecForIosWeb: 5,
    //   );
    // }
    Loader.hide();
  }

  Future getDetails() async {
    try {
      List tempGallery = [];
      final AuthState authState =
          Provider.of<AuthState>(context, listen: false);
      dynamic loginuserResponse = authState.getLoginUser;
      setState(() {
        customerId = loginuserResponse["customerInfo"]["cust_id"].toString();
      });
      final CartState cartItems =
          Provider.of<CartState>(context, listen: false);
      var cartList = cartItems.cart;
      setState(() {
        isLoading = true;
      });
      var body = json.encode({"productid": productId});
      print(Constants.App_url + Constants.itemDetails);
      print(body);
      print(Constants.allItems);
      var result =
          await http.post(Uri.parse(Constants.App_url + Constants.itemDetails),
              headers: {
                "Content-Type": "application/json",
                'Accept': 'application/json',
              },
              body: body);
      print(result);

      Map<String, dynamic> response = json.decode(result.body);
      print(response);
      if (response["response"] == "success") {
        var temp = response["itemdetails"][0];
        List<Review> tempreview = [];
        var totalRating = 0.0;
        var avgRating = 0.0;
        int tempCount = 1;
        inCart = false;
        print(response["itemdetails"][0]["tempGallery"]);
        print("called 3");
        if (cartList.length > 0) {
          for (var i = 0; i < cartList.length; i++) {
            if (cartList[i]["itemId"] == productId) {
              tempCount = cartList[i]["count"];
              inCart = true;
              selectopt = cartList[i]["option"];
            }
          }
        }
        print(temp["gallerycount"]);
        if (temp["gallerycount"] != 0) {
          for (var u in temp["galleries"]) {
            tempGallery.add(u["Image"]);
          }
        } else {
          tempGallery.add(temp["image"]);
        }

        setState(() {
          count = tempCount;
          productName = temp["name"];
          price = temp["price"].toString();
          gstprice = temp["gstprice"].toString();
          baseprice = price;
          standardprice = temp["standardprice"].toString();
          standardgstprice = temp["gststandardprice"].toString();
          desc = temp["description"];
          shippingBox = temp["shippingbox"];
          spec = temp["specification"];
          down = temp["Download"];
          fq = temp["Q & A"];
          imgLink = temp["largeimage"];
          qty = temp["qty"];
          videoLink = temp["video"];
          sdesc = temp["shortdesc"];
          color = temp["color"];
          weight = temp["weight"];
          size = temp["size"];
          optCount = temp["optionscount"];
          reviewNumbers = temp["reviewcount"];
          custQty = temp["cust_qty"];
          viewText = _description();
          stateGallery = tempGallery;
          url1 = temp["tds"];
          url2 = temp["sds"];
        });
        print("options");
        print(optCount);
        print(temp["reviewcount"]);
        if (temp["reviewcount"] != 0) {
          print("calling");
          for (var u in temp["reviews"]) {
            totalRating = totalRating + double.parse(u["rating"]);
            Review data = Review(
                u["customer"].toString(),
                u["rating"].toString(),
                u["comments"].toString(),
                u["review_date"].toString(),
                u);
            tempreview.add(data);
          }
          avgRating = totalRating / reviewNumbers!;
          print(avgRating);
          print(tempreview);
          print(tempGallery);
          setState(() {
            stateReview = tempreview;
            reviewRating = avgRating;
          });
        }

        print("optionscalling");
        if (temp["optionscount"] != 0) {
          print("optionscalled");
          List<String> tempList = [];
          List<OptionDataType> tempDataList = [];
          print("options");
          for (var u in temp["options"]) {
            OptionDataType dt = OptionDataType(
                u["optionid"],
                u["name"].toString(),
                u["price"].toString(),
                u["qty"].toString(),
                u["cust_qty_per_day"].toString(),
                u["shippingbox"].toString(),
                u["weight"] == null
                    ? temp["weight"].toString()
                    : u["weight"].toString(),
                u,
                u['gstprice'].toString());
            print("options");
            tempDataList.add(dt);
            tempList.add(u["name"].toString());
            if (selectopt == u["optionid"]) {
              selectopt = u["name"];
            }
          }
          setState(() {
            options = tempDataList;
            optionName = tempList;
          });
        }
        print(stateReview);
        setState(() {
          isLoading = false;
        });
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
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  showRatingBar(pw) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: styles.ThemeText.borderRaidus1,
            content: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: CircleAvatar(
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close,
                          color: Color(Constants.primaryYellow)),
                    ),
                    backgroundColor: Color(Constants.black),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Center(
                          child: Text('Please provide ratings and reviews',
                              style: styles.ThemeText.brandName)),
                      RatingBar.builder(
                        glow: false,
                        initialRating: 3,
                        minRating: 0.2,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                      ),
                      Card(
                          color: Color(Constants.borderGreyColor),
                          child: Container(
                            width: pw * 0.7,
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                              maxLength: 250,
                              maxLines: 8,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please Say Something';
                                } else {
                                  setState(() {});
                                }
                                return null;
                              },
                              decoration: InputDecoration.collapsed(
                                  hintText: "Write Review"),
                            ),
                          )),
                      Container(
                        width: pw * 0.40,
                        height: 40,
                        margin: EdgeInsets.all(10),
                        child: RaisedButton(
                          color: Color(Constants.primaryYellow),
                          shape: styles.ThemeText.borderRaidus1,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CustomIcons.shoppingcart,
                                size: 16,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  'Submit',
                                  style: styles.ThemeText.buttonTextStyles,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  // addtoCart() async {
  //   final AuthState authState = Provider.of<AuthState>(context, listen: false);
  //   dynamic loginuserResponse = authState.getLoginUser;
  //   if (loginuserResponse['isLogin']) {
  //     setState(() {
  //       customerId = loginuserResponse["customerInfo"]["cust_id"];
  //     });

  //     var body = json.encode({
  //       "productid": productId,
  //       "qty": count,
  //       "optionid": 0,
  //       "customerid": customerId
  //     });
  //     print(body);
  //     print(Constants.addToCart);
  //     var result = await http.post(Constants.App_url + Constants.addToCart,
  //         headers: {
  //           "Content-Type": "application/json",
  //           'Accept': 'application/json',
  //         },
  //         body: body);
  //     print(result);
  //     Map<String, dynamic> response = json.decode(result.body);
  //     print(response);
  //     if (response["response"] == "success") {
  //       pId = response["cartdetails"][customerId.toString()][0]["productId"]
  //           .toString();
  //       pName = response["cartdetails"][customerId.toString()][0]["productName"]
  //           .toString();
  //       qty =
  //           response["cartdetails"][customerId.toString()][0]["qty"].toString();
  //       qp = response["cartdetails"][customerId.toString()][0]["price"]
  //           .toDouble();

  //       tp = response["cartdetails"][customerId.toString()][0]["total"]
  //           .toDouble();
  //       img = response["cartdetails"][customerId.toString()][0]["image"]
  //           .toString();

  //       // CartDataType data =
  //       //     CartDataType(pId, pName, int.parse(qty), 0, qp, tp, img);
  //       int len = Cart.cart.length;
  //       int flag = 0;
  //       for (int i = 0; i < len; i++) {
  //         if (Cart.cart[i].itemId == productId) {
  //           Fluttertoast.showToast(
  //             msg: "Item already added",
  //             toastLength: Toast.LENGTH_SHORT,
  //             webBgColor: "#e74c3c",
  //             timeInSecForIosWeb: 5,
  //           );
  //           flag = 1;
  //         }
  //       }

  //       if (flag == 0) {
  //         // Cart.cart.add(data);
  //         Fluttertoast.showToast(
  //           msg: "Item added to cart",
  //           toastLength: Toast.LENGTH_SHORT,
  //           webBgColor: "#e74c3c",
  //           timeInSecForIosWeb: 5,
  //         );
  //       }
  //     } else {
  //       Fluttertoast.showToast(
  //         msg: response["message"],
  //         toastLength: Toast.LENGTH_SHORT,
  //         webBgColor: "#e74c3c",
  //         timeInSecForIosWeb: 5,
  //       );
  //     }
  //   } else {
  //     Fluttertoast.showToast(
  //       msg: "Please login to add",
  //       toastLength: Toast.LENGTH_SHORT,
  //       webBgColor: "#e74c3c",
  //       timeInSecForIosWeb: 5,
  //     );
  //   }
  // }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 20), () {
      final Map<String, Object> rcvdData =
          ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
      if (rcvdData != null) {
        setState(() {
          productId = rcvdData["productId"].toString();
        });
      }
      this.getDetails();
    });
  }

  // _openWeb() async {
  //   flutterWebviewPlugin.launch(
  //     videoLink,
  //     rect: new Rect.fromLTWH(
  //       0.0,
  //       90,
  //       MediaQuery.of(context).size.width,
  //       200.0,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    var pageWidth = MediaQuery.of(context).size.width;
    final CartState cartItems = Provider.of<CartState>(context, listen: false);
    var cartList = cartItems.cart;
    List<Widget> imageSliders = [];
    setState(() {
      imageSliders = stateGallery
          .map((item) => GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return FullScreen(img: item);
                  }));
                },
                child: Container(
                  margin: EdgeInsets.all(5.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      child: Stack(
                        children: <Widget>[
                          qty! > 0
                              ? FadeInImage.assetNetwork(
                                  image: item,
                                  placeholder:
                                      "assets/images/placeholder-lands.png", // your assets image path
                                  fit: BoxFit.fill,

                                  height:
                                      MediaQuery.of(context).size.height * 0.30,
                                )
                              : Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    FadeInImage.assetNetwork(
                                      image: item,
                                      placeholder:
                                          "assets/images/placeholder-lands.png", // your assets image path
                                      fit: BoxFit.fill,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.30,
                                    ),
                                    Container(
                                      color: Colors.red.withOpacity(0.6),
                                      width: pageWidth,
                                      height: 50,
                                      padding: EdgeInsets.all(10),
                                      child: Center(
                                          child: Text(
                                        "Out of Stock",
                                        style: styles.ThemeText.outOfOrder,
                                      )),
                                    ),
                                  ],
                                ),
                        ],
                      )),
                ),
              ))
          .toList();
    });
    setState(() {
      if (cartList.length > 0) {
        for (var i = 0; i < cartList.length; i++) {
          if (cartList[i]["itemId"] == productId) {
            inCart = true;
          }
        }
      }
    });
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(Constants.logocolor),
          title: Image(
            height: 70,
            image: AssetImage('assets/images/HWCblack.jpg'),
          ),
          //backgroundColor: Color(0x44ffffff),
          elevation: 16,
          leading: IconButton(
            icon: Icon(CustomIcons.backarrow,
                color: Color(Constants.primaryYellow)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            // add the icon to this list
            // StatusWidget(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/myOrderScreen', arguments: {
              "route": "push",
            });
          },
          child: FloatingCartWidget(),
          backgroundColor: Color(Constants.black),
        ),
        bottomNavigationBar: Visibility(
            maintainSize: false,
            maintainAnimation: true,
            maintainState: true,
            child: isLoading
                ? SpinKitThreeBounce(
                    color: Color(Constants.logocolor),
                    size: 20.0,
                  )
                : qty! > 0
                    ? SafeArea(
                        child: Container(
                          width: pageWidth,
                          height: 50,
                          margin: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: pageWidth * 0.35,
                                        height: 40,
                                        margin: EdgeInsets.only(left: 10),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Color(
                                                  Constants.borderGreyColor),
                                            ),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15),
                                                bottomLeft: Radius.circular(15),
                                                bottomRight:
                                                    Radius.circular(15))),
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: IconButton(
                                                icon: Icon(Icons.remove),
                                                iconSize: 14,
                                                alignment: Alignment.centerLeft,
                                                onPressed: () {
                                                  if (count != 1) {
                                                    setState(() {
                                                      count--;
                                                    });
                                                  } else {
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          "Item quantity should not be empty",
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      webBgColor: "#e74c3c",
                                                      timeInSecForIosWeb: 5,
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                "$count",
                                                style: styles
                                                    .ThemeText.buttonTextStyles,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: IconButton(
                                                icon: Icon(Icons.add),
                                                iconSize: 14,
                                                alignment:
                                                    Alignment.centerRight,
                                                onPressed: () {
                                                  if (count != custQty) {
                                                    setState(() {
                                                      count++;
                                                    });
                                                  } else {
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          "Maximum quantity limit reached",
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      webBgColor: "#e74c3c",
                                                      timeInSecForIosWeb: 5,
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                              inCart
                                  ? Container(
                                      width: pageWidth * 0.40,
                                      height: 40,
                                      child: RaisedButton(
                                        color: Color(Constants.primaryYellow),
                                        shape: styles.ThemeText.borderRaidus1,
                                        onPressed: () {
                                          if (optionId != null ||
                                              options.length == 0) {
                                            addtoCart(
                                                productId, count, custQty);
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: "Please choose any option",
                                              toastLength: Toast.LENGTH_SHORT,
                                              webBgColor: "#e74c3c",
                                              timeInSecForIosWeb: 5,
                                            );
                                          }
                                        },
                                        child: iscartLoading
                                            ? SpinKitThreeBounce(
                                                color:
                                                    Color(Constants.logocolor),
                                                size: 18.0,
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    CustomIcons.shoppingcart,
                                                    size: 16,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Text(
                                                      'Update Cart',
                                                      style: styles.ThemeText
                                                          .buttonTextStyles,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    )
                                  : Container(
                                      width: pageWidth * 0.40,
                                      height: 40,
                                      child: RaisedButton(
                                        color: Color(Constants.primaryYellow),
                                        shape: styles.ThemeText.borderRaidus1,
                                        onPressed: () {
                                          if (optionId != null ||
                                              options.length == 0) {
                                            addtoCart(
                                                productId, count, custQty);
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: "Please choose any option",
                                              toastLength: Toast.LENGTH_SHORT,
                                              webBgColor: "#e74c3c",
                                              timeInSecForIosWeb: 5,
                                            );
                                          }
                                        },
                                        child: iscartLoading
                                            ? SpinKitThreeBounce(
                                                color:
                                                    Color(Constants.logocolor),
                                                size: 18.0,
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    CustomIcons.shoppingcart,
                                                    size: 16,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Text(
                                                      'Add To Cart',
                                                      style: styles.ThemeText
                                                          .buttonTextStyles,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        width: pageWidth,
                        height: 50,
                        margin: EdgeInsets.all(10),
                        child: RaisedButton(
                          color: Color(Constants.primaryYellow),
                          shape: styles.ThemeText.borderRaidus1,
                          onPressed: () {
                            Fluttertoast.showToast(
                              msg: "Sorry This item is Out of Stock",
                              toastLength: Toast.LENGTH_SHORT,
                              webBgColor: "#e74c3c",
                              timeInSecForIosWeb: 5,
                            );
                          },
                          child: iscartLoading
                              ? SpinKitThreeBounce(
                                  color: Color(Constants.logocolor),
                                  size: 18.0,
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Text(
                                        'Not Available',
                                        style:
                                            styles.ThemeText.buttonTextStyles,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      )),
        body: SafeArea(
          child: SingleChildScrollView(
              //color: Colors.white,
              child: isLoading
                  ? SpinKitThreeBounce(
                      color: Color(Constants.logocolor),
                      size: 20.0,
                    )
                  : Container(
                      child: Column(
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              aspectRatio: 2.0,
                              enableInfiniteScroll: false,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _current = index;
                                });
                              },
                              enlargeCenterPage: true,
                              scrollDirection: Axis.horizontal,
                              autoPlay: false,
                            ),
                            items: imageSliders,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: stateGallery.map((url) {
                              int index = stateGallery.indexOf(url);
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 5.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _current == index
                                      ? Color.fromRGBO(0, 0, 0, 0.9)
                                      : Color.fromRGBO(0, 0, 0, 0.4),
                                ),
                              );
                            }).toList(),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(top: 20, left: 20, right: 20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                productName,
                                style: styles.ThemeText.productTextStyles,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          if (sdesc != null)
                            Container(
                              margin:
                                  EdgeInsets.only(top: 10, left: 20, right: 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  sdesc,
                                  style: styles.ThemeText.itemsTextStyle,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10, left: 20, right: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Container(
                                //   child: Column(
                                //     mainAxisAlignment: MainAxisAlignment.start,
                                //     crossAxisAlignment: CrossAxisAlignment.start,
                                //     children: [
                                //       Align(
                                //         alignment: Alignment.centerLeft,
                                //         child: RatingBarIndicator(
                                //           rating: reviewRating,
                                //           itemBuilder: (context, index) => Icon(
                                //             Icons.star,
                                //             color: Colors.amber,
                                //           ),
                                //           itemCount: 5,
                                //           itemSize: 20.0,
                                //           direction: Axis.horizontal,
                                //         ),
                                //       ),
                                //       Padding(
                                //         padding: const EdgeInsets.only(
                                //             top: 5, left: 5),
                                //         child: Text(
                                //           "( $reviewNumbers reviews )",
                                //           style: styles.ThemeText.itemsTextStyle,
                                //         ),
                                //       )
                                //     ],
                                //   ),
                                // ),
                                optCount == 0
                                    ? SizedBox()
                                    : Container(
                                        width: pageWidth / 2,
                                        height: 50,
                                        child: DropdownSearch<String>(
                                          mode: Mode.DIALOG,
                                          showSelectedItem: true,
                                          items: optionName,
                                          selectedItem: selectopt,
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            contentPadding: EdgeInsets.only(
                                                left: 20, top: 5, bottom: 5),
                                            border: styles
                                                .ThemeText.inputOutlineBorder2,
                                          ),
                                          hint: " Select options",
                                          onChanged: (dynamic value) {
                                            setState(() {
                                              changeByOptions(value);
                                            });
                                          },
                                          showSearchBox: false,
                                          popupTitle: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Color(
                                                  Constants.primaryYellow),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text('Options',
                                                  style: styles.ThemeText
                                                      .appbarTextStyles),
                                            ),
                                          ),
                                          popupShape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(24),
                                              topRight: Radius.circular(24),
                                              bottomLeft: Radius.circular(24),
                                              bottomRight: Radius.circular(24),
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(top: 15, left: 20, right: 20),
                            child: Column(
                              children: [
                                if (standardprice != standardgstprice)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "\$" +
                                              double.parse(standardprice)
                                                  .toStringAsFixed(2),
                                          style: styles.ThemeText.pricegrey,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("[before GST / local tax ]"),
                                    ],
                                  ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 10),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "\$" +
                                            double.parse(standardgstprice)
                                                .toStringAsFixed(2),
                                        style: styles.ThemeText.pricegrey,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text("[ w/GST / local tax ]"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (standardprice != price)
                            Container(
                              margin:
                                  EdgeInsets.only(top: 15, left: 20, right: 20),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "\$" +
                                              double.parse(price)
                                                  .toStringAsFixed(2),
                                          style: styles.ThemeText.priceBold,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "[ w/GST / local tax ]",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                  if (price != gstprice)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 10),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "\$" +
                                                double.parse(gstprice)
                                                    .toStringAsFixed(2),
                                            style: styles.ThemeText.priceBold,
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "[ before GST / local tax ]",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          Container(
                            margin: EdgeInsets.only(left: 5, right: 5, top: 5),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width: 15.0,
                                  ),
                                  //Padding(
                                  //padding: const EdgeInsets.only(right: 5, left: 5),
                                  //child:
                                  OutlineButton(
                                      onPressed: () {
                                        if (desc == null || desc == "") {
                                          setState(() {
                                            viewText = Text("Not Available");
                                            pressed = 1;
                                          });
                                        } else {
                                          setState(() {
                                            viewText = _description();
                                            pressed = 1;
                                          });
                                        }
                                      },
                                      borderSide: pressed == 1
                                          ? BorderSide(
                                              color: Color(
                                                  Constants.primaryYellow),
                                              width: 2)
                                          : BorderSide(
                                              color: Color(
                                                  Constants.borderGreyColor),
                                            ),
                                      shape: styles.ThemeText.borderRaidus1,
                                      child: Text("Description",
                                          style: styles
                                              .ThemeText.appbarTextStyles)),

                                  SizedBox(
                                    width: 15.0,
                                  ),

                                  //),
                                  OutlineButton(
                                      onPressed: () {
                                        if (spec == null || spec == "") {
                                          setState(() {
                                            viewText = Text("Not Available");
                                            pressed = 2;
                                          });
                                        } else {
                                          setState(() {
                                            viewText = _specification();
                                            pressed = 2;
                                          });
                                        }
                                      },
                                      borderSide: pressed == 2
                                          ? BorderSide(
                                              color: Color(
                                                  Constants.primaryYellow),
                                              width: 2)
                                          : BorderSide(
                                              color: Color(
                                                  Constants.borderGreyColor),
                                            ),
                                      shape: styles.ThemeText.borderRaidus1,
                                      child: Text("specifications",
                                          style: styles
                                              .ThemeText.appbarTextStyles)),

                                  SizedBox(
                                    width: 15.0,
                                  ),
                                  if (url1 != "" || url2 != "")
                                    OutlineButton(
                                        onPressed: () {
                                          if (down == null || down == "") {
                                            setState(() {
                                              viewText = _download();
                                              pressed = 3;
                                            });
                                          } else {
                                            setState(() {
                                              viewText = _download();
                                              pressed = 3;
                                            });
                                          }
                                        },
                                        borderSide: pressed == 3
                                            ? BorderSide(
                                                color: Color(
                                                    Constants.primaryYellow),
                                                width: 2)
                                            : BorderSide(
                                                color: Color(
                                                    Constants.borderGreyColor),
                                              ),
                                        shape: styles.ThemeText.borderRaidus1,
                                        child: Text("Download",
                                            style: styles
                                                .ThemeText.appbarTextStyles)),
                                  if (url1 != "" || url2 != "")
                                    SizedBox(
                                      width: 15.0,
                                    ),

                                  OutlineButton(
                                      onPressed: () {
                                        if (fq == null || fq == "") {
                                          setState(() {
                                            viewText = _fandq();
                                            pressed = 4;
                                          });
                                        } else {
                                          setState(() {
                                            viewText = _fandq();
                                            pressed = 4;
                                          });
                                        }
                                      },
                                      borderSide: pressed == 4
                                          ? BorderSide(
                                              color: Color(
                                                  Constants.primaryYellow),
                                              width: 2)
                                          : BorderSide(
                                              color: Color(
                                                  Constants.borderGreyColor),
                                            ),
                                      shape: styles.ThemeText.borderRaidus1,
                                      child: Text("Q & A",
                                          style: styles
                                              .ThemeText.appbarTextStyles)),

                                  SizedBox(
                                    width: 15.0,
                                  ),

                                  // OutlineButton(
                                  //     onPressed: () {
                                  //       if (stateReview.length == 0) {
                                  //         setState(() {
                                  //           viewText = Column(
                                  //             children: [
                                  //               Text(
                                  //                   "Be the first Customer to review this item"),
                                  //               Container(
                                  //                 width: pageWidth * 0.40,
                                  //                 height: 40,
                                  //                 margin: EdgeInsets.all(10),
                                  //                 child: RaisedButton(
                                  //                   color: Color(
                                  //                       Constants.primaryYellow),
                                  //                   shape: styles
                                  //                       .ThemeText.borderRaidus1,
                                  //                   onPressed: () {
                                  //                     showRatingBar(pageWidth);
                                  //                   },
                                  //                   child: Row(
                                  //                     mainAxisAlignment:
                                  //                         MainAxisAlignment.center,
                                  //                     children: [
                                  //                       Icon(
                                  //                         Icons.edit,
                                  //                         size: 16,
                                  //                       ),
                                  //                       Padding(
                                  //                         padding:
                                  //                             const EdgeInsets.all(
                                  //                                 6.0),
                                  //                         child: Text(
                                  //                           'Write Review',
                                  //                           style: styles.ThemeText
                                  //                               .buttonTextStyles,
                                  //                           textAlign:
                                  //                               TextAlign.center,
                                  //                         ),
                                  //                       ),
                                  //                     ],
                                  //                   ),
                                  //                 ),
                                  //               )
                                  //             ],
                                  //           );
                                  //           pressed = 3;
                                  //         });
                                  //       } else {
                                  //         setState(() {
                                  //           viewText = _reviews(pageWidth);
                                  //           pressed = 3;
                                  //         });
                                  //       }
                                  //     },
                                  //     borderSide: pressed == 3
                                  //         ? BorderSide(
                                  //             color: Color(Constants.primaryYellow),
                                  //             width: 2)
                                  //         : BorderSide(
                                  //             color:
                                  //                 Color(Constants.borderGreyColor),
                                  //           ),
                                  //     shape: styles.ThemeText.borderRaidus1,
                                  //     child: Text("Reviews",
                                  //         style: styles.ThemeText.appbarTextStyles))
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(left: 20, right: 20, top: 20),
                            child: viewText,
                          ),
                        ],
                      ),
                    )),
        ));
  }

  Widget _description() {
    return Column(
      children: [
        Html(
          //data: videoLink,
          data: videoLink == null ? "" : videoLink,
        ),
        Html(
          data: desc == null ? "" : desc,
          style: {
            "html": Style(
                fontFamily: "AvenirLTProMedium",
                color: Colors.black,
                alignment: Alignment.center),
          },
        ),
        // Row(
        //   children: [
        //     Container(
        //       width: 90,
        //       height: 30,
        //       margin: EdgeInsets.all(10),
        //       child: RaisedButton(
        //         color: Color(Constants.primaryYellow),
        //         shape: styles.ThemeText.borderRaidus1,
        //         child: Text(
        //           "PDF 1",
        //           style: styles.ThemeText.buttonTextStyles,
        //           textAlign: TextAlign.center,
        //         ),
        //         onPressed: () {
        //           print("URL: $url1");
        //           if (url1 != "") {
        //             Navigator.pushNamed(context, '/pdfviewer', arguments: {
        //               "url": url1,
        //             });
        //           } else {
        //             Fluttertoast.showToast(
        //               msg: "File not found",
        //               toastLength: Toast.LENGTH_SHORT,
        //               webBgColor: "#e74c3c",
        //               timeInSecForIosWeb: 5,
        //             );
        //           }
        //         },
        //       ),
        //     ),
        //     Container(
        //       width: 90,
        //       height: 30,
        //       margin: EdgeInsets.all(10),
        //       child: RaisedButton(
        //         color: Color(Constants.primaryYellow),
        //         shape: styles.ThemeText.borderRaidus1,
        //         child: Text(
        //           "PDF 2",
        //           style: styles.ThemeText.buttonTextStyles,
        //           textAlign: TextAlign.center,
        //         ),
        //         onPressed: () {
        //           print("URL: $url2");
        //           if (url2 != "") {
        //             Navigator.pushNamed(context, '/pdfviewer', arguments: {
        //               "url": url2,
        //             });
        //           } else {
        //             Fluttertoast.showToast(
        //               msg: "File not found",
        //               toastLength: Toast.LENGTH_SHORT,
        //               webBgColor: "#e74c3c",
        //               timeInSecForIosWeb: 5,
        //             );
        //           }
        //         },
        //       ),
        //     ),
        //   ],
        // ),
        if (size != null)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Size : $size",
                    style: styles.ThemeText.buttonTextStyles2,
                    textAlign: TextAlign.left)),
          ),
        if (color != null)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Color : $color",
                    style: styles.ThemeText.buttonTextStyles2,
                    textAlign: TextAlign.left)),
          ),
        if (weight != null)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Weight : $weight",
                    style: styles.ThemeText.buttonTextStyles2,
                    textAlign: TextAlign.left)),
          ),
      ],
    );
  }

  Widget _specification() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Html(
        data: spec == null ? "" : spec,
        style: {
          "html": Style(
              fontFamily: "AvenirLTProMedium",
              color: Colors.black,
              alignment: Alignment.center),
        },
      ),
    );
  }

  Widget _download() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          if (url1 != "")
            Container(
              width: 90,
              height: 30,
              margin: EdgeInsets.all(10),
              child: RaisedButton(
                color: Color(Constants.primaryYellow),
                shape: styles.ThemeText.borderRaidus1,
                child: Text(
                  "TDS.pdf",
                  style: styles.ThemeText.buttonTextStyles,
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  print("URL: $url1");
                  if (url1 != "") {
                    Navigator.pushNamed(context, '/pdfviewer', arguments: {
                      "url": url1,
                    });
                  } else {
                    Fluttertoast.showToast(
                      msg: "File not found",
                      toastLength: Toast.LENGTH_SHORT,
                      webBgColor: "#e74c3c",
                      timeInSecForIosWeb: 5,
                    );
                  }
                },
              ),
            ),
          if (url2 != "")
            Container(
              width: 90,
              height: 30,
              margin: EdgeInsets.all(10),
              child: RaisedButton(
                color: Color(Constants.primaryYellow),
                shape: styles.ThemeText.borderRaidus1,
                child: Text(
                  "SDS.pdf",
                  style: styles.ThemeText.buttonTextStyles,
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  print("URL: $url2");
                  if (url2 != "") {
                    Navigator.pushNamed(context, '/pdfviewer', arguments: {
                      "url": url2,
                    });
                  } else {
                    Fluttertoast.showToast(
                      msg: "File not found",
                      toastLength: Toast.LENGTH_SHORT,
                      webBgColor: "#e74c3c",
                      timeInSecForIosWeb: 5,
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _fandq() {
    return Align(
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            enquiryDetails(),
            SizedBox(
              height: 10,
            ),
          ],
        ));
  }

  enquiryDetails() {
    var pageWidth = MediaQuery.of(context).size.width;
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(),
            margin: EdgeInsets.only(left: 15, right: 16),
            child: Column(
              children: <Widget>[
                Container(
                  margin: styles.ThemeText.topMargin,
                  child: Theme(
                    data: styles.ThemeText.textInputThemeData,
                    child: TextFormField(
                      controller: _pName,
                      validator: (value) {
                        String pattern = r'(^[a-zA-Z ]*$)';
                        RegExp regExp = new RegExp(pattern);
                        if (value!.isEmpty) {
                          return 'Please enter Name';
                        } else if (!regExp.hasMatch(value)) {
                          return 'Please enter valid name';
                        } else {
                          setState(() {
                            firstName = value;
                          });
                        }
                        return null;

                        //  return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: styles.ThemeText.normalTextStyle,
                      maxLines: 1,
                      decoration: InputDecoration(
                        contentPadding: styles.ThemeText.InputTextProperties,
                        hintText: 'Name',
                        border: styles.ThemeText.inputOutlineBorder,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: styles.ThemeText.topMargin,
                  child: Theme(
                    data: styles.ThemeText.textInputThemeData,
                    child: TextFormField(
                      controller: _pEmail,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Enter Email';
                        } else {
                          if (validateEmail(value)) {
                            setState(() {
                              //userName = value;
                            });
                          } else {
                            return 'Incorrect Email Format';
                          }
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: styles.ThemeText.normalTextStyle,
                      maxLines: 1,
                      decoration: InputDecoration(
                        //prefixIcon: Icon(Icons.mail_outline),
                        contentPadding: styles.ThemeText.InputTextProperties,
                        hintText: 'Email Address',
                        border: styles.ThemeText.inputOutlineBorder,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: styles.ThemeText.topMargin,
                  child: Theme(
                    data: styles.ThemeText.textInputThemeData,
                    child: TextFormField(
                      controller: _pComment,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your comments';
                        } else {
                          setState(() {
                            comments = value;
                          });
                        }
                        return null;
                        //  return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: styles.ThemeText.normalTextStyle,
                      maxLines: 5,
                      decoration: InputDecoration(
                        contentPadding: styles.ThemeText.InputTextProperties,
                        hintText: 'Enter your message here ',
                        border: styles.ThemeText.inputOutlineBorder,
                      ),
                    ),
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    margin: styles.ThemeText.topMargin,
                    child: RaisedButton(
                      color: Color(Constants.primaryYellow),
                      shape: styles.ThemeText.borderRaidus1,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _submitData();
                        }
                      },
                      child: isLoading
                          ? LoadingWidget()
                          : Text(
                              'Submit',
                              style: styles.ThemeText.buttonTextStyles,
                            ),
                    )),
              ],
            ),
          ),
        ));
  }

  bool validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  // enquiryDetails() {
  //   return Container(
  //     padding: EdgeInsets.symmetric(
  //       vertical: fixPadding + 10.0,
  //       horizontal: fixPadding,
  //     ),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(fixPadding),
  //       //color: Color(0xFFFFFFFF),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Name',
  //           style: TextStyle(
  //             color: Color(0xFF474849),
  //             fontSize: 12.0,
  //             fontWeight: FontWeight.w700,
  //
  //           ),
  //         ),
  //         SizedBox(
  //           height: 10,
  //         ),
  //         nameTextField(),
  //         SizedBox(
  //           height: 10,
  //         ),
  //         Text(
  //           'Email',
  //           style: TextStyle(
  //             color: Color(0xFF474849),
  //             fontSize: 12.0,
  //             fontWeight: FontWeight.w700,
  //
  //           ),
  //         ),
  //         SizedBox(
  //           height: 10,
  //         ),
  //         phoneNumberTextField(),
  //         SizedBox(
  //           height: 10,
  //         ),
  //         Text(
  //           'Message',
  //           style: TextStyle(
  //             color: Color(0xFF474849),
  //             fontSize: 12.0,
  //             fontWeight: FontWeight.w700,
  //
  //           ),
  //         ),
  //         SizedBox(
  //           height: 10,
  //         ),
  //         messageTextField(),
  //         SizedBox(
  //           height: 10,
  //         ),
  //         sendEnquiryButton(),
  //       ],
  //     ),
  //   );
  // }

  nameTextField() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(fixPadding),
        color: Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            spreadRadius: 2.0,
            blurRadius: 4.0,
            color: Color(Constants.black).withOpacity(0.5),
          ),
        ],
      ),
      child: TextField(
        cursorColor: Color(Constants.logocolor),
        style: TextStyle(
          color: Color(0xFF474849),
          fontSize: 12.0,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: 'Enter your name',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: fixPadding,
            vertical: fixPadding - 2.5,
          ),
          isDense: true,
        ),
      ),
    );
  }

  phoneNumberTextField() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(fixPadding),
        color: Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            spreadRadius: 2.0,
            blurRadius: 4.0,
            color: Color(Constants.black).withOpacity(0.5),
          ),
        ],
      ),
      child: TextField(
        cursorColor: Color(Constants.logocolor),
        style: TextStyle(
          color: Color(0xFF474849),
          fontSize: 12.0,
          fontWeight: FontWeight.w700,
        ),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Enter your Email',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: fixPadding,
            vertical: fixPadding - 2.5,
          ),
          isDense: true,
        ),
      ),
    );
  }

  messageTextField() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(fixPadding),
        color: Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            spreadRadius: 2.0,
            blurRadius: 4.0,
            color: Color(Constants.black).withOpacity(0.5),
          ),
        ],
      ),
      child: TextField(
        cursorColor: Color(Constants.logocolor),
        maxLines: 5,
        style: TextStyle(
          color: Color(0xFF474849),
          fontSize: 12.0,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: 'Enter your message here',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: fixPadding,
            vertical: fixPadding - 2.5,
          ),
          isDense: true,
        ),
      ),
    );
  }

  sendEnquiryButton() {
    return InkWell(
      //onTap: () => Navigator.pop(context),
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: fixPadding),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color(Constants.logocolor),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          'Send enquiry',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 12.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _submitData() async {
    try {
      setState(() {
        isLoading = true;
      });

      var body = json.encode({
        "productname": productName,
        "productcode": productId,
        "name": _pName.text.toString().trim(),
        "email": _pEmail.text.toString().trim(),
        "question": _pComment.text.toString().trim(),
      });
      print(body);
      var result =
          await http.post(Uri.parse(Constants.App_url + Constants.sendqa),
              headers: {
                "Content-Type": "application/json",
              },
              body: body);
      print(result);
      Map<String, dynamic> response = json.decode(result.body);
      print(response);
      if (response["response"] == "success") {
        _pName.clear();
        _pEmail.clear();
        _pComment.clear();

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
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

// Widget _reviews(pw) {
  //   return Column(
  //     children: [
  //       Container(
  //         width: pw * 0.40,
  //         height: 40,
  //         margin: EdgeInsets.all(10),
  //         child: RaisedButton(
  //           color: Color(Constants.primaryYellow),
  //           shape: styles.ThemeText.borderRaidus1,
  //           onPressed: () {
  //             showRatingBar(pw);
  //           },
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Icon(
  //                 Icons.edit,
  //                 size: 16,
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.all(6.0),
  //                 child: Text(
  //                   'Write Review',
  //                   style: styles.ThemeText.buttonTextStyles,
  //                   textAlign: TextAlign.center,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       Container(
  //         margin: EdgeInsets.only(bottom: 12),
  //         child: ListView.builder(
  //             itemCount: stateReview.length,
  //             shrinkWrap: true,
  //             physics: NeverScrollableScrollPhysics(),
  //             itemBuilder: (BuildContext context, int index) {
  //               return Column(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         stateReview[index].customer + " - ",
  //                         style: styles.ThemeText.buttonTextStyles,
  //                       ),
  //                       Text(
  //                         "(" + stateReview[index].date + ")",
  //                         style: styles.ThemeText.itemsTextStyle,
  //                       )
  //                     ],
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.only(top: 8),
  //                     child: Align(
  //                       alignment: Alignment.centerLeft,
  //                       child: RatingBarIndicator(
  //                         rating: double.parse(stateReview[index].rating),
  //                         itemBuilder: (context, index) => Icon(
  //                           Icons.star,
  //                           color: Colors.amber,
  //                         ),
  //                         itemCount: 5,
  //                         itemSize: 15.0,
  //                         direction: Axis.horizontal,
  //                       ),
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.only(top: 8),
  //                     child: Text(
  //                       stateReview[index].comments,
  //                       style: styles.ThemeText.brandName,
  //                     ),
  //                   )
  //                 ],
  //               );
  //             }),
  //       ),
  //     ],
  //   );
  // }
}

class FullScreen extends StatelessWidget {
  final String img;
  FullScreen({Key? key, required this.img})
      : assert(img != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    var pageWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(Constants.logocolor),
        title: Image(
          height: 70,
          image: AssetImage('assets/images/HWCblack.jpg'),
        ),
        //backgroundColor: Color(0x44ffffff),
        elevation: 16,
        leading: IconButton(
          icon: Icon(CustomIcons.backarrow,
              color: Color(Constants.primaryYellow)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          // add the icon to this list
          // StatusWidget(),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Image.network(
            img,
          ),
        ),
      ),
    );
  }
}

class OptionDataType {
  final int optionId;
  final String name;
  final String price;
  final String gstprice;

  final String qty;
  final String custqtyperday;
  final String shippingbox;
  final String weight;
  final Object Obj;

  OptionDataType(this.optionId, this.name, this.price, this.qty,
      this.custqtyperday, this.shippingbox, this.weight, this.Obj,this.gstprice);
}

class AllItemsDataType {
  final String itemId;
  final String itemName;
  // final double size;
  // final String shortDesc;
  // final String color;
  final String specification;
  // final String urlKey;
  final String price;
  // final String shippingBox;
  // final Float weight;
  // final double qty;
  // final double custqty;
  // final double dimension;
  // final double catId;
  // final double brand;
  //final String imgPath;
  final String largeImgPath;
  final String description;
  // final String videoPath;

  final Object Obj;

  AllItemsDataType(
      this.itemId,
      this.itemName,
      // this.size,
      // this.shortDesc,
      // this.color,
      this.specification,
      // this.urlKey,
      this.price,
      // this.shippingBox,
      // this.weight,
      // this.qty,
      // this.custqty,
      // this.dimension,
      // this.catId,
      // this.brand,
      //this.imgPath,
      this.largeImgPath,
      this.description,
      // this.videoPath,
      this.Obj);
}

class Review {
  String customer;
  String rating;
  String comments;
  String date;
  final Object Obj;

  Review(this.customer, this.rating, this.comments, this.date, this.Obj);
}
