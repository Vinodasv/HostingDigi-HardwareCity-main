import '../customicons.dart';
import '../widgets/floatingCart.dart';
import 'package:flutter/material.dart';
import '../styles.dart' as styles;
import '../constants.dart' as Constants;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
//import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/HomeScreenModels.dart';

class AllCategoriesScreen extends StatefulWidget {
  @override
  _AllCategoriesScreenState createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  bool isBrandLoading = true;
  List<OfferCategoryDataType> stateAllCategories = [];
  Future? futureItems;
  String searchString = "";

  Future<List<OfferCategoryDataType>> _searchResults() async {
    List<OfferCategoryDataType> itemsTemp = [];

    for (var u in stateAllCategories) {
      if (u.categoryName.toLowerCase().contains(
            searchString.toLowerCase(),
          )) {
        itemsTemp.add(u);
      }
    }
    return itemsTemp;
  }

  Future<List<OfferCategoryDataType>> getPopularBrands() async {
    try {
      print("called");
      List<OfferCategoryDataType> popBrandsTemp = [];

      setState(() {
        isBrandLoading = false;
      });

      var result = await http.get(
        Uri.parse(Constants.App_url + Constants.allCategory),
        headers: {
          "Content-Type": "application/json",
        },
      );

      Map<String, dynamic> response = json.decode(result.body);
      print(response);
      if (response["response"] == "success") {
        // print('saved $value');
        print(response["categories"]);
        print(response["categories"].length);
        if (response["categories"].length > 0) {
          print("called");
          for (var u in response["categories"]) {
            OfferCategoryDataType data = OfferCategoryDataType(
                u["category_name"],
                u["category_id"],
                u["url_key"],
                u["image"],
                u["meta_title"] == null ? "Null" : u["meta_title"],
                u["meta_keywords"] == null ? "Null" : u["meta_keywords"],
                u["meta_description"] == null ? "Null" : u["meta_description"],
                0,
                u);
            popBrandsTemp.add(data);
          }

          // print(imageSliderTemp);
          setState(() {
            stateAllCategories = popBrandsTemp;
          });
          return popBrandsTemp;
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
        isBrandLoading = true;
      });
    } catch (e) {
      setState(() {
        isBrandLoading = true;
      });
    }
    throw {
      //do nothing
    };
  }

  @override
  void initState() {
    super.initState();
    futureItems = this.getPopularBrands();
  }

  @override
  Widget build(BuildContext context) {
    var pageWidth = MediaQuery.of(context).size.width;

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
              child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 20, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: pageWidth * 0.90,
                            height: 50,
                            child: TextField(
                              onChanged: (text) {
                                setState(() {
                                  searchString = text;
                                  futureItems = this._searchResults();
                                });
                              },
                              autocorrect: true,
                              decoration: styles.ThemeText.searchBarStyle,
                            )),
                        // Container(
                        //     decoration: BoxDecoration(
                        //       color: Color(Constants.primaryYellow),
                        //       borderRadius:
                        //           BorderRadius.all(Radius.circular(15.0)),
                        //     ),
                        //     width: 50,
                        //     height: 50,
                        //     child: IconButton(
                        //         icon: Icon(
                        //           CustomIcons.filter,
                        //           size: 30,
                        //         ),
                        //         onPressed: () {
                        //           // this._filterBottomView();
                        //         }))
                      ],
                    )),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Container(
                //       padding: EdgeInsets.only(left: 10),
                //       child: Text(
                //         "Featured Brands",
                //         style: styles.ThemeText.leftTextstyles,
                //       ),
                //     ),
                //     isBrandLoading
                //         ? SizedBox()
                //         : FlatButton(
                //             onPressed: () {
                //               //  Navigator.pushNamed(context, '/featuredScreen');
                //             },
                //             child: Row(
                //               children: [
                //                 Text(
                //                   "View All",
                //                   style: styles.ThemeText.rightTextstyles,
                //                 ),
                //                 Icon(
                //                   Icons.keyboard_arrow_right,
                //                   size: 30,
                //                 )
                //               ],
                //             ),
                //           )
                //   ],
                // ),
                Container(
                  //height: MediaQuery.of(context).size.height,
                  margin: EdgeInsets.only(top: 30),
                  // child: isBrandLoading
                  //     ? SpinKitThreeBounce(
                  //         color: Color(Constants.logocolor),
                  //         size: 20.0,
                  //       )
                  child: FutureBuilder(
                      future: futureItems,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.data != null &&
                            snapshot.data.length == 0 &&
                            !isBrandLoading) {
                          return Center(
                              child: Column(
                            children: [
                              Container(
                                  padding: const EdgeInsets.only(top: 100),
                                  child: Container(
                                      padding: const EdgeInsets.only(top: 100),
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
                        } else if (snapshot.data == null || isBrandLoading) {
                          return Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: SpinKitThreeBounce(
                                color: Color(Constants.logocolor),
                                size: 20.0,
                              ));
                        }
                        return ListView.builder(
                            //itemCount: no.of.items,

                            itemCount: snapshot.data == null
                                ? 0
                                : snapshot.data.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                  width: pageWidth,
                                  height: 60,
                                  margin: EdgeInsets.only(
                                      left: 20, top: 0, right: 20, bottom: 20),
                                  child: RaisedButton(
                                    color: Colors.white,
                                    shape: styles.ThemeText.borderRadiusOutLine,
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, "/subCategoryScreen",
                                          arguments: {
                                            "categoryId":
                                                snapshot.data[index].categoryId,
                                            "categoryName": snapshot
                                                .data[index].categoryName
                                          });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Text(
                                            snapshot.data[index].categoryName,
                                            style:
                                                styles.ThemeText.leftTextstyles,
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        Center(
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                snapshot.data[index].imgPath),
                                          ),
                                        )
                                      ],
                                    ),
                                  ));
                            });
                      }),
                ),
                // Text("hello"),
              ],
            ),
          )),
        ));
  }
}
