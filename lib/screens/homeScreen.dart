import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart' as Constants;
import '../models/HomeScreenModels.dart';
import '../services/firebaseStorage.dart';
import '../states/customerProfileState.dart';
import '../states/myCartState.dart';
import '../styles.dart' as styles;
import '../widgets/ItemTile1.dart';
import '../widgets/OfferProductTile2.dart';

class Cart {
  static List<CartDataType> cart = [];
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool ad = false;
  int page = 1;
  // bool firstLoad = true;
  // bool isEnd = false;
  // bool loading = false;
  // var _controller = ScrollController();
  bool isLoading = false;
  bool isPromoLoading = false;
  bool isOfferLoading = false;
  bool isBrandLoading = false;
  String customerName = '';
  int _current = 0;
  Future? futureItems;
  String customerId = '';
  bool iscartLoading = false;
  bool login = false;
  String name = '';
  bool fav = false;
  bool offercat = false;
  bool inCart = false;
  List<Widget> offerText = [];
  String offertext = "";
  bool offeravailable = false;

  //List<String> imgList = [];
  List<PromoContent> statePromoDetails = [];
  List<OfferCategoryDataType> stateOfferCatogories = [];
  List<PopularBrandsDataType> statePopularBrands = [];
  List<ProductDataType> promoItemsList = [];
  List<Widget> imageSliders = [];
  List<Widget> adImageSliders = [];

  getOffers() async {
    String tempo = "";
    int l;
    List tempOffer = [];
    var result = await http.get(
      Uri.parse(Constants.App_url + Constants.offermsg),
      headers: {
        "Content-Type": "application/json",
        'Accept': 'application/json',
      },
    );
    Map<String, dynamic> response = json.decode(result.body);
    print(response);
    if (response["response"] == "success") {
      for (var u in response["offers"]) {
        tempo = u["message"];
        l = tempo.length;

        tempOffer.add(tempo.substring(3, l - 4));
      }
    }
    for (var u in tempOffer) {
      offertext = offertext + "   " + u;
    }
    print(tempOffer);
    setState(() {
      offerText = tempOffer
          .map((item) => Html(
                data: item,
                style: {
                  "html": Style(
                    color: Colors.black,
                  ),
                },
              ))
          .toList();
      if (offerText.length > 0) {
        offeravailable = true;
      }
    });
  }

  addfav(productId) async {
    final AuthState authState = Provider.of<AuthState>(context, listen: false);
    dynamic loginuserResponse = authState.getLoginUser;
    setState(() {
      customerId = loginuserResponse["customerInfo"]["cust_id"].toString();
    });
    if (loginuserResponse['isLogin']) {
      login = true;
      var body =
          json.encode({"customerid": customerId, "productid": productId});
      // print(body);
      // print(Constants.addfavitems);
      var result =
          await http.post(Uri.parse(Constants.App_url + Constants.addfavitems),
              headers: {
                "Content-Type": "application/json",
                'Accept': 'application/json',
              },
              body: body);
      // print(result);
      // print(customerId);
      Map<String, dynamic> response = json.decode(result.body);
      // print(response);
      // if (response["response"] == "success") {
      //   Fluttertoast.showToast(
      //     msg: "Added to Favourites",
      //     toastLength: Toast.LENGTH_SHORT,
      //     webBgColor: "#e74c3c",
      //     timeInSecForIosWeb: 5,
      //   );
      // }
    } else {
      Fluttertoast.showToast(
        msg: "Please login to add as favourite",
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: "#e74c3c",
        timeInSecForIosWeb: 5,
      );
    }
  }

  removefav(productId) async {
    final AuthState authState = Provider.of<AuthState>(context, listen: false);
    dynamic loginuserResponse = authState.getLoginUser;
    setState(() {
      customerId = loginuserResponse["customerInfo"]["cust_id"].toString();
    });
    if (loginuserResponse['isLogin']) {
      var body =
          json.encode({"customerid": customerId, "productid": productId});
      // print(body);
      // print(Constants.remfavitems);
      var result =
          await http.post(Uri.parse(Constants.App_url + Constants.remfavitems),
              headers: {
                "Content-Type": "application/json",
                'Accept': 'application/json',
              },
              body: body);
      // print(result);
      // print(customerId);
      Map<String, dynamic> response = json.decode(result.body);
      // print(response);
      // if (response["response"] == "success") {
      //   Fluttertoast.showToast(
      //     msg: "Removed from Favourites",
      //     toastLength: Toast.LENGTH_SHORT,
      //     webBgColor: "#e74c3c",
      //     timeInSecForIosWeb: 5,
      //   );
      // }
    }
  }

  addtoCart(productId, count, custQty, weight, shipbox) async {
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
      "optionid": 0,
      "customerid": customerId
    });
    // print(body);
    // print(Constants.addToCart);
    var result =
        await http.post(Uri.parse(Constants.App_url + Constants.addToCart),
            headers: {
              "Content-Type": "application/json",
              'Accept': 'application/json',
            },
            body: body);

    Map<String, dynamic> response = json.decode(result.body);

    if (response["response"] == "success") {
      // print("called");
      if (cartList.length > 0) {
        var isPresent = false;

        /*  If item already present in the list it wiill add to list */
        for (var i = 0; i < cartList.length; i++) {
          if (cartList[i]["itemId"] == productId) {
            // print("already exist");
            isPresent = true;
            cartList[i]["count"] = count;
            cartList[i]["total"] = cartList[i]["price"] * cartList[i]["count"];
            Fluttertoast.showToast(
              msg: "Item updated to cart",
              toastLength: Toast.LENGTH_SHORT,
              webBgColor: "#e74c3c",
              timeInSecForIosWeb: 5,
            );
          }
        }
        // print("after");

        // print("celled3");
        /* it will check whether given item present in list or not , if not will add to cart */
        if (!isPresent) {
          // print("celled4");
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
            "shipbox": shipbox
          });

          Fluttertoast.showToast(
            msg: "Item added to cart",
            toastLength: Toast.LENGTH_SHORT,
            webBgColor: "#e74c3c",
            timeInSecForIosWeb: 5,
          );
        }
      } else {
        // print("celled5");
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
          "shipbox": shipbox
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
    // }
    // else {
    //   Fluttertoast.showToast(
    //     msg: "Please login to add",
    //     toastLength: Toast.LENGTH_SHORT,
    //     webBgColor: "#e74c3c",
    //     timeInSecForIosWeb: 5,
    //   );
    // }
    Loader.hide();
  }

  getPopularBrands() async {
    try {
      // print("called");
      List<PopularBrandsDataType> popBrandsTemp = [];

      setState(() {
        isBrandLoading = true;
      });
      var result;
      if (login) {
        result = await http.get(
          Uri.parse(Constants.App_url +
              Constants.popBrands +
              "?customerid=$customerId"),
          headers: {
            "Content-Type": "application/json",
          },
        );
      } else {
        result = await http.get(
          Uri.parse(Constants.App_url + Constants.popBrands),
          headers: {
            "Content-Type": "application/json",
          },
        );
      }

      Map<String, dynamic> response = json.decode(result.body);
      // print(response);
      if (response["response"] == "success") {
        // print('saved $value');
        // print(response["brands"]);
        // print(response["brands"].length);
        if (response["brands"].length > 0) {
          print("called");
          for (var u in response["brands"]) {
            PopularBrandsDataType data = PopularBrandsDataType(
                u["brand_id"],
                u["brand_name"],
                u["url_key"],
                u["image"],
                u["meta_title"] == null ? "Null" : u["meta_title"],
                u["meta_keywords"] == null ? "Null" : u["meta_keywords"],
                u["meta_description"] == null ? "Null" : u["meta_description"],
                u["discount_percentage"],
                u);
            popBrandsTemp.add(data);
          }

          // print(imageSliderTemp);
          setState(() {
            statePopularBrands = popBrandsTemp;
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
        isBrandLoading = false;
      });
    } catch (e) {
      setState(() {
        isBrandLoading = false;
      });
    }
  }

  Future<List<ProductDataType>> getItems() async {
    try {
      // print("called");
      List<ProductDataType> itemsTemp = [];
      final AuthState authState =
          Provider.of<AuthState>(context, listen: false);
      dynamic loginuserResponse = authState.getLoginUser;
      setState(() {
        customerId = loginuserResponse["customerInfo"]["cust_id"].toString();
        name = loginuserResponse["customerInfo"]["cust_firstname"].toString();
      });
      final CartState cartItems =
          Provider.of<CartState>(context, listen: false);
      var cartList = cartItems.cart;
      if (loginuserResponse['isLogin']) {
        login = true;
      }

      setState(() {
        // if (firstLoad) {
        //   isBrandLoading = true;
        //   loading = false;
        // } else {
        //   loading = true;
        // }
        isBrandLoading = true;
      });

      // print("promoItems");
      // print(Constants.promoItems);
      var result = await http.get(
        Uri.parse(Constants.App_url + Constants.promoItems + "?page=$page"),
        headers: {
          "Content-Type": "application/json",
          'Accept': 'application/json',
        },
      );

      var body = json.encode({"customerid": customerId});
      var result2 =
          await http.post(Uri.parse(Constants.App_url + Constants.favitems),
              headers: {
                "Content-Type": "application/json",
                'Accept': 'application/json',
              },
              body: body);
      Map<String, dynamic> response2 = json.decode(result2.body);

      Map<String, dynamic> response = json.decode(result.body);
      // print("promoItems2");

      if (response["response"] == "success") {
        // print('saved $value');
        // print(response["promoitems"].length);
        if (response["promoitems"].length > 0) {
          for (var u in response["promoitems"]) {
            int tempCount = 1;
            inCart = false;
            if (cartList.length > 0) {
              for (var i = 0; i < cartList.length; i++) {
                if (cartList[i]["itemId"] == u["id"].toString()) {
                  tempCount = cartList[i]["count"];
                  inCart = true;
                }
              }
            }
            // print("called");
            if (response2["favitems"] != "") {
              for (var v in response2["favitems"]) {
                // print("called");

                if (u["id"] == v["id"]) {
                  print("fav called");
                  fav = true;
                  break;
                } else {
                  fav = false;
                }
              }
            } else {
              fav = false;
            }

            ProductDataType data = ProductDataType(
                u["id"].toString(),
                inCart,
                u["name"],
                u["standardprice"],
                u["gststandardprice"],
                u["optionscount"].toString(),
                u["price"].toString(),
                u["gstprice"].toString(),
                u["weight"],
                u["qty"],
                u["cust_qty"],
                u["image"],
                u["shippingbox"],
                tempCount,
                fav,
                u);
            itemsTemp.add(data);
          }
          // print("value");
          // print(stateItems[0]);
          setState(() {
            promoItemsList = itemsTemp;
            isBrandLoading = false;
            // firstLoad = false;
          });
          return promoItemsList;
        }
        // else {
        //   setState(() {
        //     isEnd = true;
        //     loading = false;
        //     isBrandLoading = false;
        //   });

        //   return promoItemsList;
        // }
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
        // firstLoad = false;
        // loading = false;
      });
    } catch (e) {
      setState(() {
        isBrandLoading = false;
        // firstLoad = false;
        // loading = false;
      });
    }
    throw {};
  }

  getOfferCategories() async {
    try {
      // print("called");
      List<OfferCategoryDataType> offerCatTemp = [];

      setState(() {
        isOfferLoading = true;
      });

      var result = await http.get(
        Uri.parse(Constants.App_url + Constants.offerCat),
        headers: {
          "Content-Type": "application/json",
        },
      );

      Map<String, dynamic> response = json.decode(result.body);
      // print(response);
      if (response["response"] == "success") {
        // print('saved $value');
        // print(response["categories"]);
        // print(response["categories"].length);
        if (response["categories"].length > 0) {
          // print("called");
          for (var u in response["categories"]) {
            OfferCategoryDataType data = OfferCategoryDataType(
                u["category_name"],
                u["category_id"],
                u["url_key"],
                u["image"],
                u["meta_title"] == null ? "Null" : u["meta_title"],
                u["meta_keywords"] == null ? "Null" : u["meta_keywords"],
                u["meta_description"] == null ? "Null" : u["meta_description"],
                u["discount_percentage"],
                u);
            offerCatTemp.add(data);
          }

          // print(imageSliderTemp);
          setState(() {
            if (offerCatTemp.length > 0) {
              offercat = true;
            }
            stateOfferCatogories = offerCatTemp;
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
        isOfferLoading = false;
      });
    } catch (e) {
      setState(() {
        isOfferLoading = false;
      });
    }
  }

  getAdBanner() async {
    try {
      // print("called");
      List<PromoContent> promoDetails = [];

      // setState(() {
      //   isPromoLoading = true;
      // });

      var result = await http.get(
        Uri.parse(Constants.App_url + Constants.adbanner),
        headers: {
          "Content-Type": "application/json",
        },
      );

      Map<String, dynamic> response = json.decode(result.body);
      // print(response);
      if (response["response"] == "success") {
        // print('saved $value');
        // print(response["banners"]);
        // print(response["banners"].length);
        if (response["adbanners"].length > 0) {
          // print("called");
          for (var u in response["adbanners"]) {
            PromoContent data = PromoContent(
                u["ban_name"],
                u["ban_link"],
                u["image"] == null || u["image"] == ""
                    ? "assets/images/placeholder.png"
                    : u["image"],
                u["ban_caption"],
                u);
            promoDetails.add(data);
          }
          setState(() {
            adImageSliders = promoDetails
                .map((item) => Container(
                      //  color: Colors.blueAccent,
                      child: GestureDetector(
                        onTap: () async {
                          await canLaunch(item.bannerLink)
                              ? await launch(item.bannerLink)
                              : throw 'Could not launch';
                        },
                        child: Container(
                          padding: EdgeInsets.all(5.0),
                          child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: <Widget>[
                              ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  child: item.imgPath == null ||
                                          item.imgPath == ""
                                      ? Image(
                                          image: AssetImage(
                                              'assets/images/placeholder-lands.png'),
                                          fit: BoxFit.fill,
                                          height: 130,
                                          width: 1000.0)
                                      : FadeInImage.assetNetwork(
                                          image: item.imgPath,
                                          placeholder:
                                              "assets/images/placeholder-lands.png", // your assets image path
                                          fit: BoxFit.fill,
                                          height: 130,
                                          width: 1000.0)),
                              // Html(
                              //   data: item.caption,
                              //   style: {
                              //     "html": Style(
                              //         color: Colors.white,
                              //         alignment: Alignment.center),
                              //   },
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ))
                .toList();
          });

          // print(imageSliderTemp);
          setState(() {
            // statePromoDetails = promoDetails;
            ad = true;
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
      // setState(() {
      //   isPromoLoading = false;
      // });
    } catch (e) {
      // setState(() {
      //   isPromoLoading = false;
      // });
    }
  }

  getHomeBanner() async {
    try {
      // print("called");
      List<PromoContent> promoDetails = [];

      setState(() {
        isPromoLoading = true;
      });

      var result = await http.get(
        Uri.parse(Constants.App_url + Constants.banner),
        headers: {
          "Content-Type": "application/json",
        },
      );

      Map<String, dynamic> response = json.decode(result.body);
      // print(response);
      if (response["response"] == "success") {
        // print('saved $value');
        print(response["banners"]);
        // print(response["banners"].length);
        if (response["banners"].length > 0) {
          // print("called");
          for (var u in response["banners"]) {
            PromoContent data = PromoContent(
                u["ban_name"],
                u["ban_link"],
                u["image"] == null || u["image"] == ""
                    ? "assets/images/placeholder.png"
                    : u["image"],
                u["ban_caption"],
                u);
            promoDetails.add(data);
          }
          setState(() {
            imageSliders = promoDetails
                .map((item) => Container(
                      //  color: Colors.blueAccent,
                      child: Container(
                        // padding: EdgeInsets.all(5.0),
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            ClipRRect(
                                // borderRadius:
                                //     BorderRadius.all(Radius.circular(15.0)),
                                child: item.imgPath == null ||
                                        item.imgPath == ""
                                    ? Image(
                                        image: AssetImage(
                                            'assets/images/placeholder-lands.png'),
                                        fit: BoxFit.fill,
                                        height: 1000,
                                        width: 1000.0)
                                    : FadeInImage.assetNetwork(
                                        image: item.imgPath,
                                        placeholder:
                                            "assets/images/placeholder-lands.png", // your assets image path
                                        fit: BoxFit.fill,
                                        height: 1000,
                                        width: 1000.0)),
                            // Center(
                            //   child: Html(
                            //     data: item.caption,
                            //     style: {
                            //       "html": Style(
                            //           color: Colors.white,
                            //           alignment: Alignment.center),
                            //     },
                            //   ),
                            // ),
                            // Positioned(
                            //   left: 60,
                            //   child: Html(
                            //     data: item.bannerName + "</br>" + item.caption,
                            //     style: {
                            //       "html": Style(
                            //           color: Colors.white,
                            //           alignment: Alignment.center),
                            //     },
                            //   ),
                            // ),
                            //
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Center(
                                    child: Text(
                                      //item.bannerName,
                                      "",
                                      style: styles.ThemeText.bannerHeadText,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Center(
                                    child: Text(
                                      //item.caption,
                                      "",
                                      style: styles.ThemeText.bannerCaptionText,
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ))
                .toList();
          });

          // print(imageSliderTemp);
          setState(() {
            statePromoDetails = promoDetails;
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
        isPromoLoading = false;
      });
    } catch (e) {
      setState(() {
        isPromoLoading = false;
      });
    }
  }

  // _filterBottomView() {
  //   print("called");
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (BuildContext bc) {
  //         return Container(
  //           color: Colors.white,
  //           height: MediaQuery.of(context).size.height * 0.60,
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Container(
  //                 padding:
  //                     EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   border: Border(
  //                     bottom: BorderSide(width: 1.0, color: Colors.black12),
  //                   ),
  //                 ),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Text(
  //                       "Filter By",
  //                       style: TextStyle(fontSize: 18),
  //                     ),
  //                     IconButton(
  //                         icon: Icon(
  //                           Icons.close,
  //                           size: 30,
  //                         ),
  //                         onPressed: () {
  //                           Navigator.of(context).pop();
  //                           // this._filterBottomView();
  //                         })
  //                   ],
  //                 ),
  //               ),
  //               Container(
  //                 padding:
  //                     EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     FlatButton(
  //                       onPressed: () {},
  //                       child: Text(
  //                         "Clear Filter",
  //                         style: TextStyle(fontSize: 16),
  //                       ),
  //                     ),
  //                     Container(
  //                         width: MediaQuery.of(context).size.width * 0.60,
  //                         height: 50,
  //                         //margin: styles.ThemeText.topMargin,
  //                         child: FlatButton(
  //                           color: Color(Constants.primaryYellow),
  //                           shape: styles.ThemeText.borderRaidus1,
  //                           onPressed: () {},
  //                           child: Text(
  //                             'Apply Filter',
  //                           ),
  //                         )),
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         );
  //       });
  // }

  // searchBy() {
  //   print("called");
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (BuildContext bc) {
  //         return Container(
  //           color: Colors.white,
  //           height: MediaQuery.of(context).size.height * 0.35,
  //           child: Column(
  //             children: [
  //               Container(
  //                 padding:
  //                     EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   border: Border(
  //                     bottom: BorderSide(width: 1.0, color: Colors.black12),
  //                   ),
  //                 ),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Text(
  //                       "Search By",
  //                       style: styles.ThemeText.leftTextstyles,
  //                     ),
  //                     IconButton(
  //                         icon: Icon(
  //                           Icons.close,
  //                           size: 30,
  //                         ),
  //                         onPressed: () {
  //                           Navigator.of(context).pop();
  //                           // this._filterBottomView();
  //                         })
  //                   ],
  //                 ),
  //               ),
  //               Container(
  //                   padding: EdgeInsets.only(left: 20, right: 20, top: 20),
  //                   width: MediaQuery.of(context).size.width,
  //                   height: 70,
  //                   //margin: styles.ThemeText.topMargin,
  //                   child: OutlineButton(
  //                     borderSide: BorderSide(
  //                         width: 1.0, color: Color(Constants.logocolor)),
  //                     shape: styles.ThemeText.borderRaidus1,
  //                     onPressed: () {
  //                       Navigator.pushNamed(context, '/allBrandsScreen');
  //                     },
  //                     child: Text(
  //                       'Brands',
  //                       style: styles.ThemeText.buttonTextStyles,
  //                     ),
  //                   )),
  //               Container(
  //                   width: MediaQuery.of(context).size.width,
  //                   padding: EdgeInsets.only(left: 20, right: 20, top: 20),
  //                   height: 70,
  //                   //margin: styles.ThemeText.topMargin,
  //                   child: OutlineButton(
  //                     borderSide: BorderSide(
  //                         width: 1.0, color: Color(Constants.logocolor)),
  //                     shape: styles.ThemeText.borderRaidus1,
  //                     onPressed: () {
  //                       Navigator.pushNamed(context, '/allCategories');
  //                     },
  //                     child: Text(
  //                       'Categories',
  //                       style: styles.ThemeText.buttonTextStyles,
  //                     ),
  //                   ))
  //             ],
  //           ),
  //         );
  //       });
  // }

  initLoad() async {
    /* ------------------  On load customer if already login reassiging user details to state  ------------------ */
    final sharedPrefs = await SharedPreferences.getInstance();
    final AuthState authState = Provider.of<AuthState>(context, listen: false);
    dynamic authuser = sharedPrefs.get("user");

    if (authuser != null) {
      Map<String, dynamic> user = json.decode(authuser);
      authState.saveLoginUser(user);
    } else {
      authState.saveLoginUser({"isLogin": false, "customerInfo": {}});
    }

    final CartState cartState = Provider.of<CartState>(context, listen: false);
    dynamic cartList = sharedPrefs.get("cart");

    if (cartList != null) {
      var cart = json.decode(sharedPrefs.get("cart").toString());
      // sharedPrefs.remove("cart");
      // cart=[];
      cartState.saveCart(cart);
    } else {
      cartState.saveCart([]);
    }
    futureItems = this.getItems();
    this.getHomeBanner();
    this.getOfferCategories();
    this.getPopularBrands();
    this.getOffers();
    this.getAdBanner();
  }

  @override
  void initState() {
    super.initState();
    // _controller.addListener(() {
    //   if (_controller.position.atEdge) {
    //     if (_controller.position.pixels == 0) {
    //       print("top");
    //     } else {
    //       if (!isEnd && firstLoad) {
    //         setState(() {
    //           print("end");
    //           page = page + 1;
    //           futureItems = this.getItems();
    //         });
    //       }
    //     }
    //   }
    // });
    initLoad();
  }

  @override
  Widget build(BuildContext context) {
    var pageWidth = MediaQuery.of(context).size.width;

    var pageHeight = MediaQuery.of(context).size.height;
    final double itemHeight = (pageHeight - kToolbarHeight - 24) / 2;
    final double itemWidth = pageWidth / 2;
    final CartState cartItems = Provider.of<CartState>(context, listen: false);
    var cartList = cartItems.cart;
    setState(() {
      for (var u in promoItemsList) {
        if (cartList.length > 0) {
          for (var i = 0; i < cartList.length; i++) {
            if (cartList[i]["itemId"] == u.itemId.toString()) {
              u.inCart = true;
            }
          }
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/chatScreen', arguments: {
            "route": "push",
          });
        },
        child: Icon(Icons.chat_rounded),
        backgroundColor: Color(Constants.black),
      ),

      //appBar: AppBar(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        //centerTitle: true,
        backgroundColor: Color(Constants.logocolor),
        //backgroundColor: Color(0x44ffffff),
        actions: <Widget>[
          Row(
            // mainAxisAlignment
            //MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                height: 30,
                width: pageWidth / 1.5,
                child: Padding(
                  padding: const EdgeInsets.only(left: 2, right: 8),
                  child: Center(
                    child: offeravailable
                        ? Marquee(
                            direction: Axis.horizontal,
                            child: Text(
                              offertext,
                              style:
                                  TextStyle(color: Colors.orange, fontSize: 14),
                            ),
                            textDirection: TextDirection.ltr,
                            animationDuration: Duration(seconds: 10),
                            backDuration: Duration(seconds: 0),
                            pauseDuration: Duration(seconds: 1),
                            directionMarguee: DirectionMarguee.oneDirection,
                          )
                        : SizedBox(),
                  ),
                ),
              ),
            ],
          ),
          login
              ? Center(
                  child: Container(
                  width: 100,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 3, left: 4),
                    child: Text(
                      "Hello, $name !",
                      style: TextStyle(fontSize: 13, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ))
              : Center(
                  child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text("Hello, guest !",
                      style: TextStyle(fontSize: 13, color: Colors.white)),
                ))
          //  IconButton(
          //         icon:
          //             Icon(Icons.search, color: Color(Constants.primaryYellow)),
          //         onPressed: () {
          //           Navigator.pushNamed(context, '/allItemsSearch');
          //         })
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          initLoad();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            // controller: _controller,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // test 2 start

                  // login
                  //     ? Align(
                  //         alignment: Alignment.topRight,
                  //         child: Container(
                  //           width: pageWidth,
                  //           child: Padding(
                  //             padding: const EdgeInsets.only(right: 8),
                  //             child: Text(
                  //               "Hello, $name !",
                  //               style:
                  //                   TextStyle(fontSize: 16, color: Colors.black),
                  //               overflow: TextOverflow.ellipsis,
                  //               maxLines: 2,
                  //               textAlign: TextAlign.end,
                  //             ),
                  //           ),
                  //         ),
                  //       )
                  //     : Align(
                  //         alignment: Alignment.topRight,
                  //         child: Container(
                  //           width: pageWidth,
                  //           child: Padding(
                  //             padding: const EdgeInsets.only(right: 8),
                  //             child: Text(
                  //               "Hello, Guest !",
                  //               style:
                  //                   TextStyle(fontSize: 16, color: Colors.black),
                  //               overflow: TextOverflow.ellipsis,
                  //               maxLines: 2,
                  //               textAlign: TextAlign.end,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  // Padding(
                  //     padding:
                  //         const EdgeInsets.only(top: 10, left: 20, right: 10),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         Container(
                  //             width: pageWidth * 0.90,
                  //             height: 50,
                  //             child: TextField(
                  //               onChanged: (text) {
                  //                 setState(() {
                  //                   // searchString = text;
                  //                   // myFuture = this._getRestaurants();
                  //                 });
                  //               },
                  //               autocorrect: true,
                  //               decoration: styles.ThemeText.searchBarStyle,
                  //             )),
                  //         // Container(
                  //         //     decoration: BoxDecoration(
                  //         //       color: Color(Constants.primaryYellow),
                  //         //       borderRadius:
                  //         //           BorderRadius.all(Radius.circular(15.0)),
                  //         //     ),
                  //         //     width: 50,
                  //         //     height: 50,
                  //         //     child: IconButton(
                  //         //         icon: Icon(
                  //         //           CustomIcons.filter,
                  //         //           size: 30,
                  //         //         ),
                  //         //         onPressed: () {
                  //         //           // this._filterBottomView();
                  //         //         }))
                  //       ],
                  //     )),

//test 2 end

                  Container(
                    child: isPromoLoading
                        ? SpinKitThreeBounce(
                            color: Color(Constants.logocolor),
                            size: 20.0,
                          )
                        : Column(
                            children: [
                              Stack(
                                children: [
                                  CarouselSlider(
                                      options: CarouselOptions(
                                        onPageChanged: (index, reason) {
                                          setState(() {
                                            _current = index;
                                          });
                                        },
                                        viewportFraction: 1,
                                        aspectRatio: 1.6,
                                        enlargeCenterPage: false,
                                        scrollDirection: Axis.horizontal,
                                        autoPlay: true,
                                      ),
                                      items: imageSliders),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(
                                  //       top: 10, left: 15),
                                  //   child: Row(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.spaceBetween,
                                  //     children: [
                                  //       Container(
                                  //         decoration: BoxDecoration(
                                  //           borderRadius:
                                  //               BorderRadius.circular(10),
                                  //           color: Colors.white,
                                  //         ),
                                  //         height: 35,
                                  //         width: pageWidth / 1.7,
                                  //         child: Padding(
                                  //           padding: const EdgeInsets.only(
                                  //               left: 8, right: 8),
                                  //           child: Center(
                                  //             child: offeravailable
                                  //                 ? Marquee(
                                  //                     direction:
                                  //                         Axis.horizontal,
                                  //                     child: Text(
                                  //                       offertext,
                                  //                       style: TextStyle(
                                  //                           color:
                                  //                               Colors.orange),
                                  //                     ),
                                  //                     textDirection:
                                  //                         TextDirection.ltr,
                                  //                     animationDuration:
                                  //                         Duration(seconds: 20),
                                  //                     backDuration:
                                  //                         Duration(seconds: 0),
                                  //                     pauseDuration:
                                  //                         Duration(seconds: 1),
                                  //                     directionMarguee:
                                  //                         DirectionMarguee
                                  //                             .oneDirection,
                                  //                   )
                                  //                 : SizedBox(),
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       login
                                  //           ? Center(
                                  //               child: Container(
                                  //               width: 100,
                                  //               child: Padding(
                                  //                 padding:
                                  //                     const EdgeInsets.only(
                                  //                         right: 8),
                                  //                 child: Text(
                                  //                   "Hello, $name !",
                                  //                   style: TextStyle(
                                  //                       backgroundColor: Colors.blueGrey,
                                  //                       fontWeight:
                                  //                           FontWeight.bold,
                                  //                       fontSize: 14,
                                  //                       color: Colors.white),
                                  //                   overflow:
                                  //                       TextOverflow.ellipsis,
                                  //                   maxLines: 2,
                                  //                 ),
                                  //               ),
                                  //             ))
                                  //           : Center(
                                  //               child: Padding(
                                  //               padding: const EdgeInsets.only(
                                  //                   right: 8),
                                  //               child: Text("Hello, guest !",
                                  //                   style: TextStyle(
                                  //                     backgroundColor: Colors.blueGrey,
                                  //                       fontWeight:
                                  //                           FontWeight.bold,
                                  //                       fontSize: 14,
                                  //                       color: Colors.white)),
                                  //             ))
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: statePromoDetails.map((url) {
                                  int index = statePromoDetails.indexOf(url);
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
                            ],
                          ),
                  ),
                  // if (offeravailable)
                  //   // CarouselSlider(
                  //   //     options: CarouselOptions(
                  //   //       autoPlayInterval: Duration(seconds: 5),
                  //   //       height: 100,
                  //   //       onPageChanged: (index, reason) {
                  //   //         setState(() {
                  //   //           _current = index;
                  //   //         });
                  //   //       },
                  //   //       // viewportFraction: 0.7,
                  //   //       // aspectRatio: 2.0,
                  //   //       enlargeCenterPage: true,
                  //   //       scrollDirection: Axis.horizontal,
                  //   //       autoPlay: true,
                  //   //     ),
                  //   //     items: offerText),
                  //   Marquee(
                  //     direction: Axis.horizontal,
                  //     child: Text(offertext),
                  //     textDirection: TextDirection.ltr,
                  //     animationDuration: Duration(seconds: 20),
                  //     backDuration: Duration(seconds: 0),
                  //     pauseDuration: Duration(seconds: 1),
                  //     directionMarguee: DirectionMarguee.oneDirection,
                  //   ),

                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            "Offer categories",
                            style: styles.ThemeText.leftTextstyles,
                          ),
                        ),
                        isOfferLoading
                            ? SizedBox()
                            : FlatButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/allCategories');
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      "Explore all",
                                      style: styles.ThemeText.rightTextstyles,
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Color(Constants.orange),
                                      size: 30,
                                    )
                                  ],
                                ),
                              )
                      ],
                    ),
                  ),
                  if (ad) adImageSliders[0],
                  // CarouselSlider(
                  //   options: CarouselOptions(
                  //     aspectRatio: 2.0,
                  //     enableInfiniteScroll: false,
                  //     onPageChanged: (index, reason) {
                  //       setState(() {
                  //         _current = index;
                  //       });
                  //     },
                  //     enlargeCenterPage: true,
                  //     scrollDirection: Axis.horizontal,
                  //     autoPlay: false,
                  //   ),
                  //   items: adImageSliders,
                  // ),
                  isOfferLoading
                      ? Container(
                          height: 150,
                          child: SpinKitThreeBounce(
                            color: Color(Constants.logocolor),
                            size: 20.0,
                          ),
                        )
                      : offercat
                          ? Container(
                              height: 100,
                              alignment: Alignment.centerLeft,
                              child: GridView.builder(
                                  //itemCount: no.of.items,
                                  gridDelegate:
                                      new SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 1),
                                  itemCount: stateOfferCatogories == null
                                      ? 0
                                      : stateOfferCatogories.length,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  // physics: NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return OfferProductTile(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, "/subCategoryScreen",
                                            arguments: {
                                              "categoryId":
                                                  stateOfferCatogories[index]
                                                      .categoryId,
                                              "categoryName":
                                                  stateOfferCatogories[index]
                                                      .categoryName
                                            });
                                      },
                                      imagePath:
                                          stateOfferCatogories[index].imgPath,
                                      captionText:
                                          //stateOfferCatogories[index].categoryName,
                                          "",
                                      discount:
                                          stateOfferCatogories[index].discount,
                                    );
                                  }),
                            )
                          : Container(
                              height: 100,
                              child: Center(
                                  child:
                                      Text("Currently no offers available"))),

                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          child: Text("Popular brands",
                              style: styles.ThemeText.leftTextstyles),
                        ),
                        isBrandLoading
                            ? SizedBox()
                            : FlatButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/featuredScreen');
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      "Explore all",
                                      style: styles.ThemeText.rightTextstyles,
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Color(Constants.orange),
                                      size: 30,
                                    )
                                  ],
                                ),
                              )
                      ],
                    ),
                  ),
                  if (ad) adImageSliders[1],
                  // CarouselSlider(
                  //   options: CarouselOptions(
                  //     aspectRatio: 2.0,
                  //     enableInfiniteScroll: false,
                  //     onPageChanged: (index, reason) {
                  //       setState(() {
                  //         _current = index;
                  //       });
                  //     },
                  //     enlargeCenterPage: true,
                  //     scrollDirection: Axis.horizontal,
                  //     autoPlay: false,
                  //   ),
                  //   items: adImageSliders,
                  // ),
                  Container(
                    height: 200,
                    child: isBrandLoading
                        ? SpinKitThreeBounce(
                            color: Color(Constants.logocolor),
                            size: 20.0,
                          )
                        : GridView.builder(
                            //itemCount: no.of.items,
                            gridDelegate:
                                new SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            itemCount: statePopularBrands == null
                                ? 0
                                : statePopularBrands.length,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            // physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return OfferProductTile(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/allItems',
                                      arguments: {
                                        "brandId":
                                            statePopularBrands[index].brandId,
                                        "brandName":
                                            statePopularBrands[index].brandName
                                      });
                                },
                                imagePath: statePopularBrands[index].imgPath,
                                captionText:
                                    //statePopularBrands[index].brandName,
                                    "",
                                discount: statePopularBrands[index].discount,
                              );
                            }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          child: Text("Promotion",
                              style: styles.ThemeText.leftTextstyles),
                        ),
                        isBrandLoading
                            ? SizedBox()
                            : FlatButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/promotionalItems');
                                  // searchBy();
                                  // Navigator.pushNamed(context, '/featuredScreen');
                                  //   PlatformActionSheet().displaySheet(
                                  //       context: context,
                                  //       message: Column(
                                  //         crossAxisAlignment: CrossAxisAlignment.start,
                                  //         children: [
                                  //           Row(
                                  //             mainAxisAlignment:
                                  //                 MainAxisAlignment.spaceBetween,
                                  //             children: [
                                  //               Padding(
                                  //                   padding:
                                  //                       const EdgeInsets.only(top: 20),
                                  //                   child: Text(
                                  //                     "Search By",
                                  //                     style: styles
                                  //                         .ThemeText.buttonTextStyles,
                                  //                   )),
                                  //               IconButton(
                                  //                   padding: EdgeInsets.only(top: 20),
                                  //                   icon: Icon(Icons.cancel_outlined),
                                  //                   onPressed: () =>
                                  //                       Navigator.pop(context))
                                  //             ],
                                  //           ),
                                  //           Container(
                                  //             padding: EdgeInsets.only(top: 20),
                                  //             decoration: BoxDecoration(
                                  //                 border: Border(
                                  //                     bottom: BorderSide(
                                  //                         color: Color(Constants
                                  //                             .borderGreyColor),
                                  //                         width: 1.0))),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //       actions: [
                                  //         ActionSheetAction(
                                  //           text: 'Brand',
                                  //           onPressed: () => Navigator.pushNamed(
                                  //               context, '/featuredScreen'),
                                  //           //     uploadImage('camera'),
                                  //           hasArrow: true,
                                  //         ),
                                  //         ActionSheetAction(
                                  //           text: "Category",
                                  //           onPressed: () => Navigator.pushNamed(
                                  //               context, '/allCategories'),
                                  //           //  uploadImage('gallery'),
                                  //           hasArrow: true,
                                  //         ),
                                  //         // ActionSheetAction(
                                  //         //   text: "Cancel",
                                  //         //   onPressed: () => Navigator.pop(context),
                                  //         //   isCancel: true,
                                  //         //   defaultAction: true,
                                  //         // )
                                  //       ]);
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      "Explore all",
                                      style: styles.ThemeText.rightTextstyles,
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Color(Constants.orange),
                                      size: 30,
                                    )
                                  ],
                                ),
                              )
                      ],
                    ),
                  ),
                  Container(
                      child: FutureBuilder(
                          future: futureItems,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.data != null &&
                                snapshot.data.length == 0 &&
                                !isBrandLoading) {
                              return Center(
                                  child: Column(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.only(top: 100),
                                      child: Container(
                                          child: Image(
                                        image: AssetImage(
                                            'assets/images/NoRecord.png'),
                                        fit: BoxFit.fill,
                                        height: 150.0,
                                      ))),
                                  Text("No records found",
                                      style: styles.ThemeText.leftTextstyles),
                                ],
                              ));
                            } else if (snapshot.data == null ||
                                isBrandLoading) {
                              return SpinKitThreeBounce(
                                color: Color(Constants.logocolor),
                                size: 20.0,
                              );
                            }
                            return GridView.builder(
                                //itemCount: no.of.items,
                                gridDelegate:
                                    new SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio:
                                      (itemWidth / itemHeight) * 0.90,
                                ),
                                itemCount: promoItemsList == null
                                    ? 0
                                    : promoItemsList.length,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return ItemTile1(
                                      qty: snapshot.data[index].qty,
                                      inCart: snapshot.data[index].inCart,
                                      imagePath: snapshot.data[index].imgPath,
                                      itemName: snapshot.data[index].itemName,
                                      optionscount:
                                          snapshot.data[index].optionscount,
                                      gstprice:
                                          snapshot.data[index].price.toString(),
                                      gststandardprice: snapshot
                                          .data[index].gststandardprice
                                          .toString(),
                                      increament: () {
                                        if (snapshot.data[index].count !=
                                            snapshot.data[index].custQty) {
                                          setState(() {
                                            snapshot.data[index].count++;
                                          });
                                        } else {
                                          Fluttertoast.showToast(
                                            msg:
                                                "Maximum quantity limit reached",
                                            toastLength: Toast.LENGTH_SHORT,
                                            webBgColor: "#e74c3c",
                                            timeInSecForIosWeb: 5,
                                          );
                                        }
                                      },
                                      decreament: () {
                                        if (snapshot.data[index].count != 1) {
                                          setState(() {
                                            snapshot.data[index].count--;
                                          });
                                        } else {
                                          Fluttertoast.showToast(
                                            msg:
                                                "Item quantity should not be empty",
                                            toastLength: Toast.LENGTH_SHORT,
                                            webBgColor: "#e74c3c",
                                            timeInSecForIosWeb: 5,
                                          );
                                        }
                                      },
                                      funAddToCart: () {
                                        if (snapshot.data[index].optionscount
                                                .toString() ==
                                            "0") {
                                          if (!iscartLoading) {
                                            addtoCart(
                                                snapshot.data[index].itemId,
                                                snapshot.data[index].count,
                                                snapshot.data[index].custQty,
                                                snapshot.data[index].weight,
                                                snapshot
                                                    .data[index].shippingBox);
                                          }
                                        } else {
                                          Navigator.pushNamed(
                                              context, '/productDetails',
                                              arguments: {
                                                "productId":
                                                    snapshot.data[index].itemId,
                                              });
                                        }
                                      },
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/productDetails',
                                            arguments: {
                                              "productId":
                                                  snapshot.data[index].itemId,
                                            });
                                      },
                                      favOnPress: () {
                                        setState(() {
                                          if (snapshot.data[index].fav) {
                                            removefav(
                                                snapshot.data[index].itemId);
                                          } else {
                                            addfav(snapshot.data[index].itemId);
                                          }
                                          if (login) {
                                            snapshot.data[index].fav =
                                                !snapshot.data[index].fav;
                                          }
                                        });
                                      },
                                      pageWidth: pageWidth,
                                      fav: snapshot.data[index].fav,
                                      count: snapshot.data[index].count
                                          .toString());
                                });
                          })),
                  // if (loading)
                  //   SpinKitThreeBounce(
                  //     color: Color(Constants.logocolor),
                  //     size: 20.0,
                  //   )
                  // Container(
                  //   child: Text("hello"),
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class OfferCategoryDataType {
//   final String categoryName;
//   final int categoryId;
//   final String urlKey;
//   final String imgPath;
//   final String metaTitle;
//   final String metaKeywords;
//   final String metaDescription;

//   final Object Obj;

//   OfferCategoryDataType(
//       this.categoryName,
//       this.categoryId,
//       this.urlKey,
//       this.imgPath,
//       this.metaTitle,
//       this.metaKeywords,
//       this.metaDescription,
//       this.Obj);
// }

// class PopularBrandsDataType {
//   final int brandId;
//   final String brandName;
//   final String urlKey;
//   final String imgPath;
//   final String metaTitle;
//   final String metaKeywords;
//   final String metaDescription;

//   final Object Obj;

//   PopularBrandsDataType(this.brandId, this.brandName, this.urlKey, this.imgPath,
//       this.metaTitle, this.metaKeywords, this.metaDescription, this.Obj);
// }

// "category_name": "Hand Tools",
//             "category_id": 1,
//             "url_key": "hand-tools",
//             "image": "http://hardcity.puduyugam.com/cartweb/public/uploads/category/1605573065_cata-01.jpg",
//             "meta_title": "Hand Tools",
//             "meta_keywords": "Hand Tools",
//             "meta_description": "Hand Tools"

//  "brand_id": 3,
//             "brand_name": "Ansell",
//             "url_key": "ansell",
//             "image": "http://hardcity.puduyugam.com/cartweb/public/uploads/brands/1605575482_brand_02.jpg",
//             "meta_title": "Starbrite Boat Wash, Bilge Cleaners, Deck Cleaners, Boat Care Products Singapore",
//             "meta_keywords": "Starbrite Boat Wash, Bilge Cleaners, Deck Cleaners, Boat Care Products Singapore",
//             "meta_description": "Starbrite Boat Wash, Bilge Cleaners, Deck Cleaners, Boat Care Products Singapore"
