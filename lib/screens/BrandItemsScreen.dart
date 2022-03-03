import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
//import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../constants.dart' as Constants;
import '../customicons.dart';
import '../models/HomeScreenModels.dart';
import '../services/firebaseStorage.dart';
import '../states/customerProfileState.dart';
import '../states/myCartState.dart';
import '../styles.dart' as styles;
import '../widgets/ItemTile1.dart';
import '../widgets/floatingCart.dart';

class AllItemsScreen extends StatefulWidget {
  @override
  _AllItemsScreenState createState() => _AllItemsScreenState();
}

class _AllItemsScreenState extends State<AllItemsScreen> {
  String filter = "";
  int page = 1;
  bool firstLoad = true;
  bool isEnd = false;
  bool loading = false;
  var _controller = ScrollController();
  bool isBrandLoading = false;
  Future? futureItems;
  List<ProductDataType> stateItems = [];
  String searchString = "";
  bool iscartLoading = false;
  String customerId = "";
  String customerName = "";
  String sFilter = "";
  int n = 0;
  bool pressed = true;
  String brandId = "";
  String brandName = "";
  bool login = false;
  bool fav = false;
  bool inCart = false;

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
      print(body);
      print(Constants.addfavitems);
      var result =
          await http.post(Uri.parse(Constants.App_url + Constants.addfavitems),
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
  }

  Future<List<ProductDataType>> _searchResults() async {
    List<ProductDataType> itemsTemp = [];

    for (var u in stateItems) {
      if (u.itemName.toLowerCase().contains(
            searchString.toLowerCase(),
          )) {
        itemsTemp.add(u);
      }
    }
    return itemsTemp;
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

  Future<List<ProductDataType>> sortAZ(data) async {
    List<ProductDataType> temp = [];

    for (var u in data) {
      temp.add(u);
      print(u.itemName);
    }
    temp.sort(
        (a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
    for (var u in temp) {
      print(u.itemName);
    }
    return temp;
  }

  Future<List<ProductDataType>> sortZA(data) async {
    List<ProductDataType> temp = [];
    List<ProductDataType> rTemp = [];

    for (var u in data) {
      temp.add(u);
      print(u.itemName);
    }
    temp.sort(
        (a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
    rTemp = List.from(temp.reversed);
    return rTemp;
  }

  Future<List<ProductDataType>> sortLH(data) async {
    List<ProductDataType> temp = [];

    for (var u in data) {
      temp.add(u);
      print(u.price);
    }
    temp.sort((a, b) => double.parse(a.price).compareTo(double.parse(b.price)));
    for (var u in temp) {
      print(u.price);
    }
    return temp;
  }

  Future<List<ProductDataType>> sortHL(data) async {
    List<ProductDataType> temp = [];
    List<ProductDataType> rTemp = [];

    for (var u in data) {
      temp.add(u);
      print(u.price);
    }
    temp.sort((a, b) => double.parse(a.price).compareTo(double.parse(b.price)));
    print("done");
    for (var u in temp) {
      print(u.price);
    }
    rTemp = List.from(temp.reversed);
    return rTemp;
  }

  _filterResults(name) async {
    setState(() {
      firstLoad = true;
      page = 1;
      stateItems = [];
    });
    //List<ProductDataType> itemsTemp = [];
    print(name);

    setState(() {
      sFilter = name;
    });
    // if (searchString == null || searchString == "") {
    //   print("stateCalled");
    //   //itemsTemp = stateItems;
    // } else {
    //   print("filter called");
    //   itemsTemp = filterItems;
    // }
    if (name == "az") {
      setState(() {
        filter = "ascending";
        // futureItems = sortAZ(itemsTemp);
        // isBrandLoading = false;
      });
      //return;
    }
    if (name == "lh") {
      setState(() {
        filter = "lowtohigh";
        // futureItems = sortLH(itemsTemp);
        // isBrandLoading = false;
      });
      //return;
    }
    if (name == "hl") {
      setState(() {
        filter = "hightolow";
        // futureItems = sortHL(itemsTemp);
        // isBrandLoading = false;
      });
      //return;
    }
    if (name == "za") {
      setState(() {
        filter = "descending";
        // futureItems = sortZA(itemsTemp);
        // isBrandLoading = false;
      });
      //return;
    }
    futureItems = this.getItems();
  }

  _filterBottomView(s) {
    print("called");
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          String filterData = s;

          return StatefulBuilder(
              builder: (BuildContext context, StateSetter mystate) {
            return Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        EdgeInsets.only(left: 20, right: 10, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(width: 1.0, color: Colors.black12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Filter by",
                          style: TextStyle(fontSize: 18),
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              // this._filterBottomView();
                            })
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 25),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Filter by name",
                        style: styles.ThemeText.editProfileText,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  RadioListTile(
                    groupValue: filterData,
                    title: Text('Ascending',
                        style: styles.ThemeText.itemsTextStyle),
                    value: 'az',
                    onChanged: (val) {
                      mystate(() {
                        filterData = val.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    groupValue: filterData,
                    title: Text('Descending',
                        style: styles.ThemeText.itemsTextStyle),
                    value: 'za',
                    onChanged: (val) {
                      mystate(() {
                        filterData = val.toString();
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Filter by price",
                        style: styles.ThemeText.editProfileText,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  RadioListTile(
                    groupValue: filterData,
                    title: Text('Low - High',
                        style: styles.ThemeText.itemsTextStyle),
                    value: 'lh',
                    onChanged: (val) {
                      mystate(() {
                        filterData = val.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    groupValue: filterData,
                    title: Text("High - Low",
                        style: styles.ThemeText.itemsTextStyle),
                    value: 'hl',
                    onChanged: (val) {
                      mystate(() {
                        filterData = val.toString();
                      });
                    },
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: 20, right: 10, top: 10, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // FlatButton(
                        //   onPressed: () {},
                        //   child: Text(
                        //     "Clear Filter",
                        //     style: TextStyle(fontSize: 16),
                        //   ),
                        // ),
                        Container(
                            // width: MediaQuery.of(context).size.width / 2,
                            height: 40,
                            //margin: styles.ThemeText.topMargin,
                            child: RaisedButton(
                              color: Color(Constants.primaryYellow),
                              shape: styles.ThemeText.borderRaidus1,
                              onPressed: () {
                                Navigator.of(context).pop();
                                _filterResults(filterData);

                                // Navigator.pop(context);
                              },
                              child: Text(
                                'Apply Filter',
                              ),
                            )),
                      ],
                    ),
                  )
                ],
              ),
            );
          });
        });
  }

  Future<List<ProductDataType>> getItems() async {
    try {
      print("called");
      final CartState cartItems =
          Provider.of<CartState>(context, listen: false);
      var cartList = cartItems.cart;
      List<ProductDataType> itemsTemp = [];
      final AuthState authState =
          Provider.of<AuthState>(context, listen: false);
      dynamic loginuserResponse = authState.getLoginUser;
      setState(() {
        customerId = loginuserResponse["customerInfo"]["cust_id"].toString();
      });
      if (loginuserResponse['isLogin']) {
        login = true;
      }

      setState(() {
        if (firstLoad) {
          isBrandLoading = true;
          loading = false;
        } else {
          loading = true;
        }
      });
      var body = json.encode({
        "brand": brandId,
        "page": page,
        "searchkey": searchString,
        "orderby": filter
      });
      print(body);
      print(Constants.allItems);
      var result =
          await http.post(Uri.parse(Constants.App_url + Constants.allItems),
              headers: {
                "Content-Type": "application/json",
                'Accept': 'application/json',
              },
              body: body);
      print(result);
      var body2 = json.encode({"customerid": customerId});
      var result2 =
          await http.post(Uri.parse(Constants.App_url + Constants.favitems),
              headers: {
                "Content-Type": "application/json",
                'Accept': 'application/json',
              },
              body: body2);
      Map<String, dynamic> response2 = json.decode(result2.body);

      Map<String, dynamic> response = json.decode(result.body);
      print(response);
      if (response["response"] == "success") {
        // print('saved $value');
        print(response["branditems"].length);
        if (response["branditems"].length > 0) {
          for (var u in response["branditems"]) {
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
            if (response2["favitems"] != "") {
              for (var v in response2["favitems"]) {
                print("called");
                if (u["name"] == v["name"]) {
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
            print("called");
            print(u);
            print(u["id"]);
            print(u["name"]);
            print(u["price"]);
            print(u["image"]);
            ProductDataType data = ProductDataType(
                u["id"].toString(),
                inCart,
                u["name"],
                u["standardprice"],
                u["gststandardprice"],
                u["price"].toString(),
                u["optionscount"].toString(),
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
          print("value");
          // print(stateItems[0]);
          setState(() {
            stateItems.addAll(itemsTemp);
            isBrandLoading = false;
            firstLoad = false;
          });
          return stateItems;
        } else {
          setState(() {
            isEnd = true;
            loading = false;
            isBrandLoading = false;
          });
          return stateItems;
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
        loading = false;
      });
    } catch (e) {
      setState(() {
        isBrandLoading = false;
        loading = false;
      });
    }
    throw {};
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        if (_controller.position.pixels == 0) {
          print("top");
        } else {
          if (!isEnd) {
            setState(() {
              print("end");
              page = page + 1;
              futureItems = this.getItems();
            });
          }
        }
      }
    });
    Future.delayed(const Duration(milliseconds: 10), () {
      final Map<String, Object> rcvdData =
          ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
      setState(() {
        brandId = rcvdData["brandId"].toString();
        brandName = rcvdData["brandName"].toString();
      });
      futureItems = this.getItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    print(brandId);
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
            "Brands",
            style: styles.ThemeText.appbarTextStyles2,
          ),
          leading: IconButton(
            icon: Icon(CustomIcons.backarrow,
                color: Color(Constants.primaryYellow)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search, color: Color(Constants.primaryYellow)),
                onPressed: () {
                  Navigator.pushNamed(context, '/allItemsSearch');
                })
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
        body: SafeArea(
          child: SingleChildScrollView(
              controller: _controller,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    if (stateItems.length > 0)
                      Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  width: pageWidth * 0.75,
                                  height: 50,
                                  child: TextField(
                                    onChanged: (text) {
                                      setState(() {
                                        searchString = text;
                                        //futureItems = this._searchResults();
                                      });
                                    },
                                    onSubmitted: (value) {
                                      setState(() {
                                        searchString = value;
                                        firstLoad = true;
                                        page = 1;
                                        stateItems = [];
                                        futureItems = this.getItems();
                                      });
                                    },
                                    autocorrect: true,
                                    decoration: styles.ThemeText.searchBarStyle,
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
                                      icon: Icon(
                                        Icons.filter_list,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        this._filterBottomView(sFilter);
                                      }))
                            ],
                          )),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          brandName == null ? "" : brandName,
                          style: styles.ThemeText.leftTextstyles,
                        ),
                      ),
                    ),
                    // isBrandLoading
                    //     ? SpinKitThreeBounce(
                    //         color: Color(Constants.primaryBlack),
                    //         size: 20.0,
                    //       )
                    // :

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
                                        padding:
                                            const EdgeInsets.only(top: 100),
                                        child: Container(
                                            padding:
                                                const EdgeInsets.only(top: 100),
                                            child: Image(
                                              image: AssetImage(
                                                  'assets/images/NoRecord.png'),
                                              fit: BoxFit.fill,
                                              height: 150.0,
                                            ))),
                                    Text(
                                      "No records found",
                                      style: styles.ThemeText.leftTextstyles,
                                    ),
                                  ],
                                ));
                              } else if (snapshot.data == null ||
                                  isBrandLoading) {
                                return Padding(
                                    padding: const EdgeInsets.only(top: 50),
                                    child: SpinKitThreeBounce(
                                      color: Color(Constants.logocolor),
                                      size: 20.0,
                                    ));
                              }
                              return GridView.builder(
                                  //itemCount: no.of.items,
                                  gridDelegate:
                                      new SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio:
                                        (itemWidth / itemHeight) * 0.90,
                                  ),
                                  itemCount: snapshot.data.length,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ItemTile1(
                                        qty: snapshot.data[index].qty,
                                        inCart: snapshot.data[index].inCart,
                                        imagePath: snapshot.data[index].imgPath,
                                        itemName: snapshot.data[index].itemName,
                                        gstprice: snapshot.data[index].price
                                            .toString(),
                                        gststandardprice: snapshot
                                            .data[index].gststandardprice
                                            .toString(),
                                        optionscount: snapshot
                                            .data[index].optionscount
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
                                            Navigator.pushNamed(context,
                                                '/singleproductDetails',
                                                arguments: {
                                                  "productId": snapshot
                                                      .data[index].itemId,
                                                });
                                          }
                                        },
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/singleproductDetails',
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
                                              addfav(
                                                  snapshot.data[index].itemId);
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

                                    // Container(
                                    //     padding: EdgeInsets.all(10),
                                    //     margin: EdgeInsets.all(10),
                                    //     decoration: BoxDecoration(
                                    //         borderRadius: BorderRadius.all(
                                    //             Radius.circular(15.0)),
                                    //         border: Border.all(
                                    //             color: Color(
                                    //                 Constants.borderGreyColor))),
                                    //     child: Align(
                                    //       child: Column(
                                    //         mainAxisAlignment:
                                    //             MainAxisAlignment.spaceBetween,
                                    //         children: [
                                    //           Align(
                                    //             alignment: Alignment.topLeft,
                                    //             child: IconButton(
                                    //               icon: stateItems[index].fav
                                    //                   ? Icon(Icons.favorite,
                                    //                       color:
                                    //                           Color(Constants.pink))
                                    //                   : Icon(
                                    //                       Icons.favorite_border,
                                    //                     ),
                                    //               alignment: Alignment.topLeft,
                                    //               onPressed: () {
                                    //                 setState(() {
                                    //                   snapshot.data[index].fav =
                                    //                       !snapshot.data[index].fav;
                                    //                 });
                                    //               },
                                    //             ),
                                    //           ),
                                    //           ClipRRect(
                                    //               borderRadius: BorderRadius.all(
                                    //                   Radius.circular(30.0)),
                                    //               child: snapshot.data[index]
                                    //                               .imgPath ==
                                    //                           null ||
                                    //                       snapshot.data[index]
                                    //                               .imgPath ==
                                    //                           ""
                                    //                   ? Image(
                                    //                       image: AssetImage(
                                    //                           'assets/images/placeholder-logo.png'),
                                    //                       fit: BoxFit.fill,
                                    //                       height: 60.0,
                                    //                       width: 60.0)
                                    //                   : FadeInImage.assetNetwork(
                                    //                       image: snapshot
                                    //                           .data[index].imgPath,
                                    //                       placeholder:
                                    //                           "assets/images/placeholder-logo.png", // your assets image path
                                    //                       fit: BoxFit.fill,
                                    //                       height: 60.0,
                                    //                       width: 60.0)),
                                    //           Text(
                                    //             snapshot.data[index].itemName,
                                    //             textAlign: TextAlign.center,
                                    //           ),
                                    //           Align(
                                    //             alignment: Alignment.centerLeft,
                                    //             child: Text(
                                    //               snapshot.data[index].price
                                    //                       .toString() +
                                    //                   "\$",
                                    //               textAlign: TextAlign.left,
                                    //             ),
                                    //           ),
                                    //           Container(
                                    //             width: pageWidth,
                                    //             height: 35,
                                    //             alignment: Alignment.center,
                                    //             decoration: BoxDecoration(
                                    //                 border: Border.all(
                                    //                   color: Color(
                                    //                       Constants.borderGreyColor),
                                    //                 ),
                                    //                 borderRadius: BorderRadius.only(
                                    //                     topLeft: Radius.circular(15),
                                    //                     topRight: Radius.circular(15),
                                    //                     bottomLeft:
                                    //                         Radius.circular(15),
                                    //                     bottomRight:
                                    //                         Radius.circular(15))),
                                    //             child: Stack(
                                    //               children: [
                                    //                 Align(
                                    //                   alignment: Alignment.centerLeft,
                                    //                   child: IconButton(
                                    //                     icon: Icon(Icons.remove),
                                    //                     iconSize: 14,
                                    //                     alignment:
                                    //                         Alignment.centerLeft,
                                    //                     onPressed: () {
                                    //                       if (snapshot.data[index]
                                    //                               .count !=
                                    //                           0) {
                                    //                         setState(() {
                                    //                           snapshot.data[index]
                                    //                               .--;
                                    //                         });
                                    //                       }
                                    //                     },
                                    //                   ),
                                    //                 ),
                                    //                 Align(
                                    //                   alignment: Alignment.center,
                                    //                   child: Text(
                                    //                     snapshot.data[index].count
                                    //                         .toString(),
                                    //                     style: styles.ThemeText
                                    //                         .buttonTextStyles,
                                    //                     textAlign: TextAlign.center,
                                    //                   ),
                                    //                 ),
                                    //                 Align(
                                    //                   alignment:
                                    //                       Alignment.centerRight,
                                    //                   child: IconButton(
                                    //                     icon: Icon(Icons.add),
                                    //                     iconSize: 14,
                                    //                     alignment:
                                    //                         Alignment.centerRight,
                                    //                     onPressed: () {
                                    //                       setState(() {
                                    //                         snapshot
                                    //                             .data[index].count++;
                                    //                       });
                                    //                     },
                                    //                   ),
                                    //                 ),
                                    //               ],
                                    //             ),
                                    //           ),
                                    //           Container(
                                    //             width: pageWidth,
                                    //             height: 36,
                                    //             child: FlatButton(
                                    //               color:
                                    //                   Color(Constants.primaryYellow),
                                    //               shape:
                                    //                   styles.ThemeText.borderRaidus1,
                                    //               onPressed: () {
                                    //                 print("Pressed");
                                    //               },
                                    //               child: Row(
                                    //                 mainAxisAlignment:
                                    //                     MainAxisAlignment.center,
                                    //                 crossAxisAlignment:
                                    //                     CrossAxisAlignment.center,
                                    //                 children: [
                                    //                   Icon(
                                    //                     CustomIcons.shoppingcart,
                                    //                     size: 14,
                                    //                   ),
                                    //                   Padding(
                                    //                     padding:
                                    //                         const EdgeInsets.all(6.0),
                                    //                     child: Text(
                                    //                       'Add To Cart',
                                    //                       style: styles.ThemeText
                                    //                           .buttonTextStyles,
                                    //                       textAlign: TextAlign.center,
                                    //                     ),
                                    //                   ),
                                    //                 ],
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ],
                                    //       ),
                                    //     ));
                                  });
                            })),
                    // Text("hello"),
                    if (loading)
                      SpinKitThreeBounce(
                        color: Color(Constants.logocolor),
                        size: 20.0,
                      )
                  ],
                ),
              )),
        ));
  }
}
