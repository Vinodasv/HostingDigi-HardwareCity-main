import '../customicons.dart';
import '../widgets/floatingCart.dart';
import 'package:flutter/material.dart';
import '../styles.dart' as styles;
import '../constants.dart' as Constants;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/HomeScreenModels.dart';
import '../widgets/OfferProductTile2.dart';

class FeaturedBrandScreen extends StatefulWidget {
  @override
  _FeaturedBrandScreenState createState() => _FeaturedBrandScreenState();
}

class _FeaturedBrandScreenState extends State<FeaturedBrandScreen> {
  bool isBrandLoading = false;
  List<PopularBrandsDataType> statePopularBrands = [];
  Future? futureItems;
  String searchString = '';
  String customerId = '';

  Future<List<PopularBrandsDataType>> _searchResults() async {
    List<PopularBrandsDataType> itemsTemp = [];

    for (var u in statePopularBrands) {
      if (u.brandName.toLowerCase().contains(
            searchString.toLowerCase(),
          )) {
        itemsTemp.add(u);
      }
    }
    return itemsTemp;
  }

  // _filterBottomView(s) {
  //   print("called");
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (BuildContext context) {
  //         String filterData = s;

  //         return StatefulBuilder(
  //             builder: (BuildContext context, StateSetter mystate) {
  //           return Container(
  //             color: Colors.white,
  //             height: MediaQuery.of(context).size.height * 0.60,
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Container(
  //                   padding:
  //                       EdgeInsets.only(left: 20, right: 10, top: 5, bottom: 5),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     border: Border(
  //                       bottom: BorderSide(width: 1.0, color: Colors.black12),
  //                     ),
  //                   ),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         "Filter by",
  //                         style: TextStyle(fontSize: 18),
  //                       ),
  //                       IconButton(
  //                           icon: Icon(
  //                             Icons.close,
  //                             size: 30,
  //                           ),
  //                           onPressed: () {
  //                             Navigator.of(context).pop();
  //                             // this._filterBottomView();
  //                           })
  //                     ],
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.only(top: 15, left: 25),
  //                   child: Align(
  //                     alignment: Alignment.centerLeft,
  //                     child: Text(
  //                       "Filter by name",
  //                       style: styles.ThemeText.editProfileText,
  //                       textAlign: TextAlign.left,
  //                     ),
  //                   ),
  //                 ),
  //                 RadioListTile(
  //                   groupValue: filterData,
  //                   title: Text('Ascending',
  //                       style: styles.ThemeText.itemsTextStyle),
  //                   value: 'az',
  //                   onChanged: (val) {
  //                     mystate(() {
  //                       filterData = val;
  //                     });
  //                   },
  //                 ),
  //                 RadioListTile(
  //                   groupValue: filterData,
  //                   title: Text('Descending',
  //                       style: styles.ThemeText.itemsTextStyle),
  //                   value: 'za',
  //                   onChanged: (val) {
  //                     mystate(() {
  //                       filterData = val;
  //                     });
  //                   },
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.only(left: 25),
  //                   child: Align(
  //                     alignment: Alignment.centerLeft,
  //                     child: Text(
  //                       "Filter by price",
  //                       style: styles.ThemeText.editProfileText,
  //                       textAlign: TextAlign.left,
  //                     ),
  //                   ),
  //                 ),
  //                 RadioListTile(
  //                   groupValue: filterData,
  //                   title: Text('Low - High',
  //                       style: styles.ThemeText.itemsTextStyle),
  //                   value: 'lh',
  //                   onChanged: (val) {
  //                     mystate(() {
  //                       filterData = val;
  //                     });
  //                   },
  //                 ),
  //                 RadioListTile(
  //                   groupValue: filterData,
  //                   title: Text("High - Low",
  //                       style: styles.ThemeText.itemsTextStyle),
  //                   value: 'hl',
  //                   onChanged: (val) {
  //                     mystate(() {
  //                       filterData = val;
  //                     });
  //                   },
  //                 ),
  //                 Container(
  //                   padding: EdgeInsets.only(
  //                       left: 20, right: 10, top: 10, bottom: 10),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     children: [
  //                       // FlatButton(
  //                       //   onPressed: () {},
  //                       //   child: Text(
  //                       //     "Clear Filter",
  //                       //     style: TextStyle(fontSize: 16),
  //                       //   ),
  //                       // ),
  //                       Container(
  //                           // width: MediaQuery.of(context).size.width / 2,
  //                           height: 40,
  //                           //margin: styles.ThemeText.topMargin,
  //                           child: FlatButton(
  //                             color: Color(Constants.primaryYellow),
  //                             shape: styles.ThemeText.borderRaidus1,
  //                             onPressed: () {
  //                               Navigator.of(context).pop();
  //                               _filterResults(filterData);

  //                               // Navigator.pop(context);
  //                             },
  //                             child: Text(
  //                               'Apply Filter',
  //                             ),
  //                           )),
  //                     ],
  //                   ),
  //                 )
  //               ],
  //             ),
  //           );
  //         });
  //       });
  // }

  Future<List<PopularBrandsDataType>> getPopularBrands() async {
    try {
      print("called");
      List<PopularBrandsDataType> popBrandsTemp = [];

      setState(() {
        isBrandLoading = true;
      });

      var result = await http.get(
        Uri.parse(Constants.App_url + Constants.popBrands),
        headers: {
          "Content-Type": "application/json",
        },
      );

      Map<String, dynamic> response = json.decode(result.body);
      print(response);
      if (response["response"] == "success") {
        // print('saved $value');

        if (response["brands"].length > 0) {
          print("called");
          for (var u in response["brands"]) {
            PopularBrandsDataType data = PopularBrandsDataType(
                u["brand_id"],
                u["brand_name"],
                u["url_key"],
                u["image"] == null || u["image"] == ""
                    ? "assets/images/placeholder.png"
                    : u["image"],
                u["meta_title"] == null ? "Null" : u["meta_title"],
                u["meta_keywords"] == null ? "Null" : u["meta_keywords"],
                u["meta_description"] == null ? "Null" : u["meta_description"],
                0,
                u);
            popBrandsTemp.add(data);
          }

          // print(imageSliderTemp);
          setState(() {
            statePopularBrands = popBrandsTemp;
            isBrandLoading = false;
          });
        }
        return popBrandsTemp;
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
    throw {};
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
            Navigator.pushNamed(context, '/productDetails', arguments: {
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
                        //           this._filterBottomView();
                        //         }))
                      ],
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        "Featured brands",
                        style: styles.ThemeText.leftTextstyles,
                      ),
                    ),
                    isBrandLoading
                        ? SizedBox()
                        : FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              Navigator.pushNamed(context, '/allBrandsScreen');
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
                                        padding:
                                            const EdgeInsets.only(top: 100),
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
                          return GridView.builder(
                              //itemCount: no.of.items,
                              gridDelegate:
                                  new SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4),
                              itemCount: snapshot.data.length == null
                                  ? 0
                                  : snapshot.data.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return OfferProductTile(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/allItems',
                                        arguments: {
                                          "brandId":
                                              snapshot.data[index].brandId,
                                          "brandName":
                                              snapshot.data[index].brandName
                                        });
                                  },
                                  imagePath: snapshot.data[index].imgPath,
                                  captionText:
                                      //snapshot.data[index].brandName,
                                      "",
                                );
                              });
                        })),
                //Text("hello"),
              ],
            ),
          )),
        ));
  }
}
