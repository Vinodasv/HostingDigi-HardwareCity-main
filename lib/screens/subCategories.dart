import 'dart:async';
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
import '../models/HomeScreenModels.dart';
import '../services/firebaseStorage.dart';
import '../states/customerProfileState.dart';
import '../states/myCartState.dart';
import '../styles.dart' as styles;
import '../widgets/ItemTile1.dart';
import '../widgets/OfferProductTile2.dart';
import '../widgets/floatingCart.dart';

class SubCategoryScreen extends StatefulWidget {
  @override
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  String filter = "";
  bool isSearch = false;
  int page = 1;
  bool firstLoad = true;
  bool isEnd = false;
  bool loading = false;
  var _controller = ScrollController();
  bool isProductLoading = false;
  bool isCategoryLoading = false;
  bool isCategoryProductsAvail = false;
  bool isChildCategoryAvailable = false;
  String categoryName = '';
  String categoryId = '';
  String customerId = '';
  String customerName = '';
  bool iscartLoading = false;
  int _current = 0;
  Future? futureItems;
  String sFilter = '';
  Future? futureCategory;
  Future? futureProduct;
  List<ProductDataType> productData = [];
  List<OfferCategoryDataType> categoryData = [];
  bool login = false;
  bool fav = false;
  String searchString = "";
  bool inCart = false;

  //List<String> imgList = [];

  List<Widget> imageSliders = [];

  // Future<List<OfferCategoryDataType>> _searchResultsforCategory() async {
  //   List<OfferCategoryDataType> itemsTemp = [];

  //   for (var u in categoryData) {
  //     if (u.categoryName.toLowerCase().contains(
  //           searchString.toLowerCase(),
  //         )) {
  //       itemsTemp.add(u);
  //     }
  //   }
  //   return itemsTemp;
  // }

  Future<List<ProductDataType>> _searchResultsforProducts() async {
    List<ProductDataType> itemsTemp = [];

    for (var u in productData) {
      if (u.itemName.toLowerCase().contains(
            searchString.toLowerCase(),
          )) {
        itemsTemp.add(u);
      }
    }
    return itemsTemp;
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

  Future setChildProducts(data, favdata) async {
    List<ProductDataType> proData = [];
    final CartState cartItems = Provider.of<CartState>(context, listen: false);
    var cartList = cartItems.cart;
    print("calledProd");
    for (var u in data) {
      int tempCount = 1;
      inCart = false;
      if (cartList.length > 0) {
        for (var i = 0; i < cartList.length; i++) {
          if (cartList[i]["itemId"] == u["id"].toString()) {
            tempCount = cartList[i]["count"];
            inCart = true;
            print("countAdded");
          }
        }
      }
      if (favdata != "") {
        for (var v in favdata) {
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
      ProductDataType data2 = ProductDataType(
          u["id"].toString(),
          inCart,
          u["name"],
          u["standardprice"],
          u["gststandardprice"],
          u["gstprice"].toString(),
          u["optionscount"].toString(),
          u["price"].toString(),
          u["weight"],
          u["qty"],
          u["cust_qty"],
          u["image"],
          u["shippingBox"],
          tempCount,
          fav,
          u);
      proData.add(data2);
    }
    setState(() {
      productData.addAll(proData);
    });
    print("value");
    return productData;
  }

  Future setChildCategoryData(data) async {
    List<OfferCategoryDataType> catData = [];
    print("calledCat");
    for (var u in data) {
      OfferCategoryDataType data2 = OfferCategoryDataType(
          u["category_name"],
          u["category_id"],
          u["url_key"],
          u["image"],
          u["meta_title"] == null ? "Null" : u["meta_title"],
          u["meta_keywords"] == null ? "Null" : u["meta_keywords"],
          u["meta_description"] == null ? "Null" : u["meta_description"],
          0,
          u);
      catData.add(data2);
    }
    print("value");
    // print(stateItems[0]);
    setState(() {
      categoryData = catData;
    });
    return catData;
  }

  getItems() async {
    try {
      print("called");

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
        //isProductLoading = true;
        if (firstLoad && !isSearch) {
          isProductLoading = true;
          isCategoryLoading = true;
          loading = false;
        } else if (isSearch) {
          isProductLoading = true;
        } else {
          loading = true;
          firstLoad = false;
        }
      });
      print(isProductLoading);
      print(isCategoryLoading);
      print(loading);
      print(isSearch);
      print(firstLoad);

      print(Constants.App_url +
          Constants.subCategory +
          categoryId +
          "&page=$page&orderby=$filter&searchkey=$searchString");
      var result = await http.get(
        Uri.parse(Constants.App_url +
            Constants.subCategory +
            categoryId +
            "&page=$page&orderby=$filter&searchkey=$searchString"),
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

      print(response);
      if (response["response"] == "success") {
        // print('saved $value');

        if (response["categoryproducts"].length > 0 ||
            response["categoryproducts"] == null) {
          futureProduct = setChildProducts(
              response["categoryproducts"], response2["favitems"]);
          setState(() {
            isCategoryProductsAvail = true;
            isProductLoading = false;
            firstLoad = false;
            loading = false;
          });
          // print(stateItems[0]);

        } else {
          setState(() {
            futureProduct = setChildProducts(
                response["categoryproducts"], response2["favitems"]);
            // isCategoryProductsAvail = false;
            setState(() {
              isProductLoading = false;
              //isCategoryLoading = false;
              isEnd = true;
              loading = false;
            });
          });
        }
        if (response["childcategories"].length > 0 ||
            response["childcategories"] == null) {
          futureCategory = setChildCategoryData(response["childcategories"]);
          setState(() {
            isChildCategoryAvailable = true;
            isCategoryLoading = false;
          });
        } else {
          setState(() {
            isChildCategoryAvailable = false;
            isCategoryLoading = false;
          });
        }
      } else {
        Fluttertoast.showToast(
          msg: response['message'],
          toastLength: Toast.LENGTH_SHORT,
          webBgColor: "#e74c3c",
          timeInSecForIosWeb: 5,
        );
        setState(() {
          isCategoryLoading = false;
          isProductLoading = false;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        isCategoryLoading = false;
        isProductLoading = false;
        loading = false;
      });
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
      isSearch = true;
      page = 1;
      productData = [];
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
    this.getItems();
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

  // initLoad() async {
  //   /* ------------------  On load customer if already login reassiging user details to state  ------------------ */
  //   final sharedPrefs = await SharedPreferences.getInstance();
  //   final AuthState authState = Provider.of<AuthState>(context, listen: false);
  //   dynamic authuser = sharedPrefs.get("user");

  //   if (authuser != null) {
  //     Map<String, dynamic> user = json.decode(authuser);
  //     authState.saveLoginUser(user);
  //   } else {
  //     authState.saveLoginUser({"isLogin": false, "customerInfo": {}});
  //   }
  // }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10), () {
      final Map<String, Object> rcvdData =
          ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
      if (rcvdData != null) {
        setState(() {
          categoryId = rcvdData["categoryId"].toString();
          categoryName = rcvdData["categoryName"].toString();
        });

        getItems();
      }
    });
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        if (_controller.position.pixels == 0) {
          print("top");
        } else {
          if (!isEnd) {
            setState(() {
              print("end");
              isSearch = false;
              page = page + 1;
              getItems();
            });
          }
        }
      }
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
      for (var u in productData) {
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
          "Categories",
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
        // actions: <Widget>[
        //   // Container(
        //   //     padding: EdgeInsets.only(right: 15),
        //   //     child: Icon(
        //   //       CustomIcons.notification,
        //   //       color: Color(Constants.primaryYellow),
        //   //     )),

        //   // add the icon to this list
        //   // StatusWidget(),
        // ],
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
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    categoryName == null ? "" : categoryName,
                    style: styles.ThemeText.leftTextstyles,
                  ),
                ),

                Container(
                    child: Container(
                        height: 120,
                        child: isCategoryLoading
                            ? SpinKitThreeBounce(
                                color: Color(Constants.logocolor),
                                size: 20.0,
                              )
                            : FutureBuilder(
                                future: futureCategory,
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.data != null &&
                                      snapshot.data.length == 0 &&
                                      !isCategoryLoading) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                            child: Image(
                                          image: AssetImage(
                                              'assets/images/NoRecord.png'),
                                          fit: BoxFit.fill,
                                          height: 150,
                                        )),
                                        Text("No records found",
                                            style: styles
                                                .ThemeText.leftTextstyles),
                                      ],
                                    );
                                  }
                                  return isChildCategoryAvailable
                                      ? GridView.builder(
                                          //itemCount: no.of.items,
                                          gridDelegate:
                                              new SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 1),
                                          itemCount: snapshot.data == null
                                              ? 0
                                              : snapshot.data.length,
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          // physics: NeverScrollableScrollPhysics(),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return OfferProductTile(
                                              onPressed: () {
                                                Navigator.pushNamed(context,
                                                    "/subCategoryScreen",
                                                    arguments: {
                                                      "categoryId": snapshot
                                                          .data[index]
                                                          .categoryId,
                                                      "categoryName":
                                                          categoryName +
                                                              "/" +
                                                              snapshot
                                                                  .data[index]
                                                                  .categoryName
                                                    });
                                              },
                                              imagePath:
                                                  snapshot.data[index].imgPath,
                                              captionText:
                                                  //snapshot.data[index].categoryName,
                                                  "",
                                            );
                                          })
                                      : Column(
                                          children: [
                                            Container(
                                                child: Image(
                                              image: AssetImage(
                                                  'assets/images/NoRecord.png'),
                                              fit: BoxFit.fill,
                                              height: 100.0,
                                            )),
                                            Text("No records found",
                                                style: styles
                                                    .ThemeText.leftTextstyles),
                                          ],
                                        );
                                }))),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Product List",
                      style: styles.ThemeText.leftTextstyles),
                ),

                Container(
                    child: isProductLoading
                        ? SpinKitThreeBounce(
                            color: Color(Constants.logocolor),
                            size: 20.0,
                          )
                        : Column(
                            children: [
                              if (isCategoryProductsAvail)
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 20, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                            width: pageWidth * 0.75,
                                            height: 50,
                                            child: TextField(
                                              onChanged: (text) {
                                                setState(() {
                                                  searchString = text;

                                                  // futureProduct = this
                                                  //     ._searchResultsforProducts();
                                                });
                                              },
                                              onSubmitted: (value) {
                                                searchString = value;
                                                firstLoad = true;
                                                page = 1;
                                                productData = [];
                                                isSearch = true;
                                                this.getItems();
                                              },
                                              autocorrect: true,
                                              decoration: styles
                                                  .ThemeText.searchBarStyle,
                                            )),
                                        Container(
                                            decoration: BoxDecoration(
                                              color: Color(
                                                  Constants.primaryYellow),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0)),
                                            ),
                                            width: 50,
                                            height: 50,
                                            child: IconButton(
                                                icon: Icon(
                                                  CustomIcons.filter,
                                                  size: 30,
                                                ),
                                                onPressed: () {
                                                  _filterBottomView(sFilter);
                                                  // this._filterBottomView();
                                                }))
                                      ],
                                    )),
                              FutureBuilder(
                                future: futureProduct,
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.data != null &&
                                      snapshot.data.length == 0 &&
                                      !isCategoryLoading) {
                                    return Center(
                                        child: Column(
                                      children: [
                                        Container(
                                            padding:
                                                const EdgeInsets.only(top: 100),
                                            child: Image(
                                              image: AssetImage(
                                                  'assets/images/NoRecord.png'),
                                              fit: BoxFit.fill,
                                              height: 150.0,
                                            )),
                                        Text("No records found",
                                            style: styles
                                                .ThemeText.leftTextstyles),
                                      ],
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
                                      itemCount: snapshot.data == null
                                          ? 0
                                          : snapshot.data.length,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ItemTile1(
                                            qty:
                                                snapshot.data[index].qty == null
                                                    ? 0
                                                    : snapshot.data[index].qty,
                                            inCart: snapshot.data[index].inCart,
                                            imagePath:
                                                snapshot.data[index].imgPath,
                                            itemName:
                                                snapshot.data[index].itemName,
                                            optionscount: snapshot.data[index]
                                                        .optionscount ==
                                                    null
                                                ? "0"
                                                : snapshot
                                                    .data[index].optionscount,
                                            gstprice: snapshot.data[index].price
                                                .toString(),
                                            gststandardprice: snapshot
                                                .data[index].gststandardprice
                                                .toString(),
                                            /*   gstprice: snapshot
                                                .data[index].gstprice
                                                .toString(),
                                            gststandardprice: snapshot
                                                .data[index].gstStandardprice
                                                .toString(),*/
                                            increament: () {
                                              if (snapshot.data[index].count !=
                                                  snapshot
                                                      .data[index].custQty) {
                                                setState(() {
                                                  snapshot.data[index].count++;
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
                                            decreament: () {
                                              if (snapshot.data[index].count !=
                                                  1) {
                                                setState(() {
                                                  snapshot.data[index].count--;
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
                                            funAddToCart: () {
                                              if (snapshot
                                                      .data[index].optionscount
                                                      .toString() ==
                                                  "0") {
                                                if (!iscartLoading) {
                                                  addtoCart(
                                                      snapshot
                                                          .data[index].itemId,
                                                      snapshot
                                                          .data[index].count,
                                                      snapshot
                                                          .data[index].custQty,
                                                      snapshot
                                                          .data[index].weight,
                                                      snapshot.data[index]
                                                          .shippingBox);
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
                                              Navigator.pushNamed(context,
                                                  '/singleproductDetails',
                                                  arguments: {
                                                    "productId": snapshot
                                                        .data[index].itemId,
                                                  });
                                            },
                                            favOnPress: () {
                                              setState(() {
                                                if (snapshot.data[index].fav) {
                                                  removefav(snapshot
                                                      .data[index].itemId);
                                                } else {
                                                  addfav(snapshot
                                                      .data[index].itemId);
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
                                },
                              ),
                              if (loading)
                                SpinKitThreeBounce(
                                  color: Color(Constants.logocolor),
                                  size: 20.0,
                                )
                            ],
                          )),

                // Container(
                //   child: Text("hello"),
                // )
              ],
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
