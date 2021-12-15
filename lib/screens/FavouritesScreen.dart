import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
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
import '../widgets/ItemTile1.dart';
import '../widgets/floatingCart.dart';

class FavouriteScreen extends StatefulWidget {
  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  bool isBrandLoading = false;
  Future? futureItems;
  List<FavItemsDataType> stateItems = [];
  String searchString = '';
  bool iscartLoading = false;
  String customerId = '';
  bool inCart = false;
  String customerName = '';

  int n = 0;
  bool pressed = true;
  bool empty = true;

  removefav(productId) async {
    Loader.show(context, progressIndicator: CupertinoActivityIndicator());
    final AuthState authState = Provider.of<AuthState>(context, listen: false);
    dynamic loginuserResponse = authState.getLoginUser;
    if (loginuserResponse['isLogin']) {
      var body =
          json.encode({"customerid": customerId, "productid": productId});
      print(body);
      print(Constants.remfavitems);
      var result =
          await http.post(Uri.parse(Constants.App_url + Constants.remfavitems),
              headers: {
                "Content-Type": "application/json",
                'Accept': 'application/json',
              },
              body: body);
      print(result);
      print(customerId);
      Map<String, dynamic> response = json.decode(result.body);
      print(response);
      // if (response["response"] == "success") {
      //   Fluttertoast.showToast(
      //     msg: "Removed from Favourites",
      //     toastLength: Toast.LENGTH_SHORT,
      //     webBgColor: "#e74c3c",
      //     timeInSecForIosWeb: 5,
      //   );
      // }
    }
    setState(() {
      this.getItems();
    });
    Loader.hide();
  }

  // Future<List<ProductDataType>> _searchResults() async {
  //   List<ProductDataType> itemsTemp = [];

  //   for (var u in stateItems) {
  //     if (u.itemName.toLowerCase().contains(
  //           searchString.toLowerCase(),
  //         )) {
  //       itemsTemp.add(u);
  //     }
  //   }
  //   return itemsTemp;
  // }

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
            cartList[i]["total"] = cartList[i]["price"] * cartList[i]["count"];
            Fluttertoast.showToast(
              msg: "Item updated to cart",
              toastLength: Toast.LENGTH_SHORT,
              webBgColor: "#e74c3c",
              timeInSecForIosWeb: 5,
            );
          }
        }
        print("after");

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

  getItems() async {
    try {
      print("called");
      List<FavItemsDataType> itemsTemp = [];
      final CartState cartItems =
          Provider.of<CartState>(context, listen: false);
      var cartList = cartItems.cart;

      setState(() {
        isBrandLoading = true;
      });
      var body = json.encode({"customerid": customerId});
      print("called");
      print(customerId);
      print(body);
      print(Constants.favitems);
      var result =
          await http.post(Uri.parse(Constants.App_url + Constants.favitems),
              headers: {
                "Content-Type": "application/json",
                'Accept': 'application/json',
              },
              body: body);
      print(result);
      Map<String, dynamic> response = json.decode(result.body);
      print(response);
      if (response["response"] == "success") {
        // print('saved $value');
        if (response["favitems"] != "") {
          empty = false;
          print("true called");
          for (var u in response["favitems"]) {
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
            print("called");
            print(u);
            print(u["id"]);
            print(u["name"]);
            print(u["standardprice"]);
            print(u["price"]);
            print(u["image"]);
            print(u["optionscount"]);
            FavItemsDataType data = FavItemsDataType(
                u["id"].toString(),
                inCart,
                u["name"].toString(),
                u["standardprice"].toString(),
                u["price"].toString(),
                u["weight"],
                u["qty"],
                u["cust_qty"],
                u["image"].toString(),
                u["optionscount"],
                u["shippingbox"],
                tempCount,
                true,
                u);
            itemsTemp.add(data);
            print(data);
          }
          print(itemsTemp);
          // print(stateItems[0]);
          setState(() {
            stateItems = itemsTemp;
            isBrandLoading = false;
          });
          return itemsTemp;
        } else {
          empty = true;
          print("false Called");
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

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10), () {
      final AuthState authState =
          Provider.of<AuthState>(context, listen: false);
      dynamic loginuserResponse = authState.getLoginUser;
      setState(() {
        customerId = loginuserResponse["customerInfo"]["cust_id"].toString();
      });
      this.getItems();
    });
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
      for (var u in stateItems) {
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
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(Constants.logocolor),

          //backgroundColor: Color(0x44ffffff),
          elevation: 16,
          title: Text(
            "My favourite products",
            style: styles.ThemeText.appbarTextStyles2,
          ),
          leading: IconButton(
            icon: Icon(CustomIcons.backarrow,
                color: Color(Constants.primaryYellow)),
            onPressed: () => Navigator.of(context).pop(),
          ),
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
        body: isBrandLoading
            ? SpinKitThreeBounce(
                color: Color(Constants.logocolor),
                size: 20.0,
              )
            : empty
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          // padding: const EdgeInsets.only(top: 150),
                          child: Image(
                        image: AssetImage('assets/images/shopbagempty.png'),
                        fit: BoxFit.fill,
                        height: 150.0,
                      )),
                      Text("You have no favourites",
                          style: styles.ThemeText.leftTextstyles)
                    ],
                  ))
                : SafeArea(
                    child: SingleChildScrollView(
                        child: Container(
                      child: GridView.builder(
                          //itemCount: no.of.items,7
                          gridDelegate:
                              new SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: (itemWidth / itemHeight) * 0.90,
                          ),
                          itemCount: stateItems.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return ItemTile1(
                                qty: stateItems[index].qty,
                                inCart: stateItems[index].inCart,
                                imagePath: stateItems[index].imgPath,
                                itemName: stateItems[index].itemName,
                                price: stateItems[index].price.toString(),
                                optionscount:
                                    stateItems[index].optionscount.toString(),
                                standardprice:
                                    stateItems[index].standardprice.toString(),
                                gststandardprice:
                                    stateItems[index].standardprice.toString(),
                                gstprice:
                                    stateItems[index].standardprice.toString(),
                                increament: () {
                                  if (stateItems[index].count !=
                                      stateItems[index].custQty) {
                                    setState(() {
                                      stateItems[index].count++;
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "Maximum quantity limit reached",
                                      toastLength: Toast.LENGTH_SHORT,
                                      webBgColor: "#e74c3c",
                                      timeInSecForIosWeb: 5,
                                    );
                                  }
                                },
                                decreament: () {
                                  if (stateItems[index].count != 1) {
                                    setState(() {
                                      stateItems[index].count--;
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "Item quantity should not be empty",
                                      toastLength: Toast.LENGTH_SHORT,
                                      webBgColor: "#e74c3c",
                                      timeInSecForIosWeb: 5,
                                    );
                                  }
                                },
                                funAddToCart: () {
                                  if (stateItems[index]
                                          .optionscount
                                          .toString() ==
                                      "0") {
                                    if (!iscartLoading) {
                                      addtoCart(
                                          stateItems[index].itemId,
                                          stateItems[index].count,
                                          stateItems[index].custQty,
                                          stateItems[index].weight,
                                          stateItems[index].shippingBox);
                                    }
                                  } else {
                                    Navigator.pushNamed(
                                        context, '/productDetails',
                                        arguments: {
                                          "productId": stateItems[index].itemId,
                                        });
                                  }
                                },
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/productDetails',
                                      arguments: {
                                        "productId": stateItems[index].itemId,
                                      });
                                },
                                favOnPress: () {
                                  setState(() {
                                    removefav(stateItems[index].itemId);
                                  });
                                },
                                pageWidth: pageWidth,
                                fav: stateItems[index].fav,
                                count: stateItems[index].count.toString());
                          }),
                      // child: FutureBuilder(
                      //     future: futureItems,
                      //     builder:
                      //         (BuildContext context, AsyncSnapshot snapshot) {
                      //       if (snapshot.connectionState ==
                      //               ConnectionState.done &&
                      //           snapshot.data != null &&
                      //           snapshot.data.length == 0 &&
                      //           !isBrandLoading) {
                      //         return Center(
                      //             child: Container(
                      //                 padding: const EdgeInsets.only(top: 100),
                      //                 child: Text('No Records Found')));
                      //       } else if (snapshot.data == null || isBrandLoading) {
                      //         return Padding(
                      //             padding: const EdgeInsets.only(top: 50),
                      //             child: SpinKitThreeBounce(
                      //               color: Color(Constants.logocolor),
                      //               size: 20.0,
                      //             ));
                      //       }
                      //       return GridView.builder(
                      //           //itemCount: no.of.items,
                      //           gridDelegate:
                      //               new SliverGridDelegateWithFixedCrossAxisCount(
                      //             crossAxisCount: 2,
                      //             childAspectRatio: (itemWidth / itemHeight),
                      //           ),
                      //           itemCount: snapshot.data.length,
                      //           scrollDirection: Axis.vertical,
                      //           shrinkWrap: true,
                      //           physics: NeverScrollableScrollPhysics(),
                      //           itemBuilder: (BuildContext context, int index) {
                      //             return ItemTile1(
                      //                 imagePath: snapshot.data[index].imgPath,
                      //                 itemName: snapshot.data[index].itemName,
                      //                 price1:
                      //                     snapshot.data[index].price.toString(),
                      //                 optionscount: snapshot
                      //                     .data[index].optionscount
                      //                     .toString(),
                      //                 standardprice: snapshot
                      //                     .data[index].standardprice
                      //                     .toString(),
                      //                 increament: () {
                      //                   setState(() {
                      //                     snapshot.data[index].count++;
                      //                   });
                      //                 },
                      //                 decreament: () {
                      //                   if (snapshot.data[index].count != 1) {
                      //                     setState(() {
                      //                       snapshot.data[index].count--;
                      //                     });
                      //                   } else {
                      //                     Fluttertoast.showToast(
                      //                       msg:
                      //                           "Item quantity should not be empty",
                      //                       toastLength: Toast.LENGTH_SHORT,
                      //                       webBgColor: "#e74c3c",
                      //                       timeInSecForIosWeb: 5,
                      //                     );
                      //                   }
                      //                 },
                      //                 funAddToCart: () {
                      //                   if (snapshot.data[index].optionscount
                      //                           .toString() ==
                      //                       "0") {
                      //                     if (!iscartLoading) {
                      //                       addtoCart(snapshot.data[index].itemId,
                      //                           snapshot.data[index].count);
                      //                     }
                      //                   } else {
                      //                     Navigator.pushNamed(
                      //                         context, '/productDetails',
                      //                         arguments: {
                      //                           "productId":
                      //                               snapshot.data[index].itemId,
                      //                         });
                      //                   }
                      //                 },
                      //                 onPressed: () {
                      //                   Navigator.pushNamed(
                      //                       context, '/productDetails',
                      //                       arguments: {
                      //                         "productId":
                      //                             snapshot.data[index].itemId,
                      //                       });
                      //                 },
                      //                 favOnPress: () {
                      //                   setState(() {
                      //                     if (snapshot.data[index].fav) {
                      //                       removefav(
                      //                           snapshot.data[index].itemId);
                      //                     }
                      //                   });
                      //                 },
                      //                 pageWidth: pageWidth,
                      //                 fav: snapshot.data[index].fav,
                      //                 count:
                      //                     snapshot.data[index].count.toString());

                      //             // Container(
                      //             //     padding: EdgeInsets.all(10),
                      //             //     margin: EdgeInsets.all(10),
                      //             //     decoration: BoxDecoration(
                      //             //         borderRadius: BorderRadius.all(
                      //             //             Radius.circular(15.0)),
                      //             //         border: Border.all(
                      //             //             color: Color(
                      //             //                 Constants.borderGreyColor))),
                      //             //     child: Align(
                      //             //       child: Column(
                      //             //         mainAxisAlignment:
                      //             //             MainAxisAlignment.spaceBetween,
                      //             //         children: [
                      //             //           Align(
                      //             //             alignment: Alignment.topLeft,
                      //             //             child: IconButton(
                      //             //               icon: stateItems[index].fav
                      //             //                   ? Icon(Icons.favorite,
                      //             //                       color:
                      //             //                           Color(Constants.pink))
                      //             //                   : Icon(
                      //             //                       Icons.favorite_border,
                      //             //                     ),
                      //             //               alignment: Alignment.topLeft,
                      //             //               onPressed: () {
                      //             //                 setState(() {
                      //             //                   snapshot.data[index].fav =
                      //             //                       !snapshot.data[index].fav;
                      //             //                 });
                      //             //               },
                      //             //             ),
                      //             //           ),
                      //             //           ClipRRect(
                      //             //               borderRadius: BorderRadius.all(
                      //             //                   Radius.circular(30.0)),
                      //             //               child: snapshot.data[index]
                      //             //                               .imgPath ==
                      //             //                           null ||
                      //             //                       snapshot.data[index]
                      //             //                               .imgPath ==
                      //             //                           ""
                      //             //                   ? Image(
                      //             //                       image: AssetImage(
                      //             //                           'assets/images/placeholder-logo.png'),
                      //             //                       fit: BoxFit.fill,
                      //             //                       height: 60.0,
                      //             //                       width: 60.0)
                      //             //                   : FadeInImage.assetNetwork(
                      //             //                       image: snapshot
                      //             //                           .data[index].imgPath,
                      //             //                       placeholder:
                      //             //                           "assets/images/placeholder-logo.png", // your assets image path
                      //             //                       fit: BoxFit.fill,
                      //             //                       height: 60.0,
                      //             //                       width: 60.0)),
                      //             //           Text(
                      //             //             snapshot.data[index].itemName,
                      //             //             textAlign: TextAlign.center,
                      //             //           ),
                      //             //           Align(
                      //             //             alignment: Alignment.centerLeft,
                      //             //             child: Text(
                      //             //               snapshot.data[index].price
                      //             //                       .toString() +
                      //             //                   "\$",
                      //             //               textAlign: TextAlign.left,
                      //             //             ),
                      //             //           ),
                      //             //           Container(
                      //             //             width: pageWidth,
                      //             //             height: 35,
                      //             //             alignment: Alignment.center,
                      //             //             decoration: BoxDecoration(
                      //             //                 border: Border.all(
                      //             //                   color: Color(
                      //             //                       Constants.borderGreyColor),
                      //             //                 ),
                      //             //                 borderRadius: BorderRadius.only(
                      //             //                     topLeft: Radius.circular(15),
                      //             //                     topRight: Radius.circular(15),
                      //             //                     bottomLeft:
                      //             //                         Radius.circular(15),
                      //             //                     bottomRight:
                      //             //                         Radius.circular(15))),
                      //             //             child: Stack(
                      //             //               children: [
                      //             //                 Align(
                      //             //                   alignment: Alignment.centerLeft,
                      //             //                   child: IconButton(
                      //             //                     icon: Icon(Icons.remove),
                      //             //                     iconSize: 14,
                      //             //                     alignment:
                      //             //                         Alignment.centerLeft,
                      //             //                     onPressed: () {
                      //             //                       if (snapshot.data[index]
                      //             //                               .count !=
                      //             //                           0) {
                      //             //                         setState(() {
                      //             //                           snapshot.data[index]
                      //             //                               .--;
                      //             //                         });
                      //             //                       }
                      //             //                     },
                      //             //                   ),
                      //             //                 ),
                      //             //                 Align(
                      //             //                   alignment: Alignment.center,
                      //             //                   child: Text(
                      //             //                     snapshot.data[index].count
                      //             //                         .toString(),
                      //             //                     style: styles.ThemeText
                      //             //                         .buttonTextStyles,
                      //             //                     textAlign: TextAlign.center,
                      //             //                   ),
                      //             //                 ),
                      //             //                 Align(
                      //             //                   alignment:
                      //             //                       Alignment.centerRight,
                      //             //                   child: IconButton(
                      //             //                     icon: Icon(Icons.add),
                      //             //                     iconSize: 14,
                      //             //                     alignment:
                      //             //                         Alignment.centerRight,
                      //             //                     onPressed: () {
                      //             //                       setState(() {
                      //             //                         snapshot
                      //             //                             .data[index].count++;
                      //             //                       });
                      //             //                     },
                      //             //                   ),
                      //             //                 ),
                      //             //               ],
                      //             //             ),
                      //             //           ),
                      //             //           Container(
                      //             //             width: pageWidth,
                      //             //             height: 36,
                      //             //             child: FlatButton(
                      //             //               color:
                      //             //                   Color(Constants.primaryYellow),
                      //             //               shape:
                      //             //                   styles.ThemeText.borderRaidus1,
                      //             //               onPressed: () {
                      //             //                 print("Pressed");
                      //             //               },
                      //             //               child: Row(
                      //             //                 mainAxisAlignment:
                      //             //                     MainAxisAlignment.center,
                      //             //                 crossAxisAlignment:
                      //             //                     CrossAxisAlignment.center,
                      //             //                 children: [
                      //             //                   Icon(
                      //             //                     CustomIcons.shoppingcart,
                      //             //                     size: 14,
                      //             //                   ),
                      //             //                   Padding(
                      //             //                     padding:
                      //             //                         const EdgeInsets.all(6.0),
                      //             //                     child: Text(
                      //             //                       'Add To Cart',
                      //             //                       style: styles.ThemeText
                      //             //                           .buttonTextStyles,
                      //             //                       textAlign: TextAlign.center,
                      //             //                     ),
                      //             //                   ),
                      //             //                 ],
                      //             //               ),
                      //             //             ),
                      //             //           ),
                      //             //         ],
                      //             //       ),
                      //             //     ));
                      //           });
                      //     })
                    )),
                  ));
  }
}

class FavItemsDataType {
  final String itemId;
  bool inCart;
  final String itemName;
  int count;
  bool isLoading = false;
  bool fav;
  final int qty;
  final int custQty;
  final int optionscount;
  // final double size;
  // final String shortDesc;
  // final String color;
  // final String specification;
  // final String urlKey;
  final String standardprice;
  final String price;
  final String shippingBox;
  final String weight;
  // final double qty;
  // final double custqty;
  // final double dimension;
  // final double catId;
  // final double brand;
  final String imgPath;
  // final String largeImgPath;
  // final String description;
  // final String videoPath;

  final Object Obj;

  FavItemsDataType(
      this.itemId,
      this.inCart,
      this.itemName,
      // this.size,
      // this.shortDesc,
      // this.color,
      // this.specification,
      // this.urlKey,
      this.standardprice,
      this.price,
      this.weight,
      this.qty,
      this.custQty,
      this.imgPath,
      this.optionscount,
      this.shippingBox,
      // this.weight,
      // this.qty,
      // this.custqty,
      // this.dimension,
      // this.catId,
      // this.brand,
      // this.largeImgPath,
      // this.description,
      // this.videoPath,
      this.count,
      this.fav,
      this.Obj);
}
