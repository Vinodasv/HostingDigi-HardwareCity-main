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

class AllBrandsScreen extends StatefulWidget {
  @override
  _AllBrandsScreenState createState() => _AllBrandsScreenState();
}

class _AllBrandsScreenState extends State<AllBrandsScreen> {
  bool isBrandLoading = false;
  bool isFilterApplied = false;
  List<AlphaCategories> brandList = [];
  List<AlphaCategories> statePopularBrands = [];
  List<PopularBrandsDataType> updated = [];
  Future? futureItems;

  List<bool> alphaIsPressed = [];
  List<String> alphaBet = [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z",
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
  ];

  filterTheData(int position) {
    for (var i = 0; i < statePopularBrands.length; i++) {
      if (position == i) {
        setState(() {
          alphaIsPressed[i] = true;
        });
      } else {
        setState(() {
          alphaIsPressed[i] = false;
        });
      }
    }
    List<AlphaCategories> popBrandsTemp = statePopularBrands;
    List<PopularBrandsDataType> filteredList = [];

    for (var u in popBrandsTemp[position].data) {
      print("1");

      filteredList.add(u);
    }

    setState(() {
      isFilterApplied = true;
      updated = filteredList;
    });
  }

  Future<List<AlphaCategories>> getPopularBrands() async {
    try {
      print("called");
      List<AlphaCategories> popBrandsTemp = [];

      setState(() {
        isBrandLoading = true;
      });

      var result = await http.get(
        Uri.parse(Constants.App_url + Constants.allBrandsWithOrder),
        headers: {
          "Content-Type": "application/json",
        },
      );

      Map<String, dynamic> response = json.decode(result.body);

      if (response["response"] == "success") {
        // print('saved $value');

        if (response["brands"].length > 0) {
          print("called");
          for (var u in response["brands"]) {
            List<PopularBrandsDataType> valuesByAlpha = [];

            for (var v in u["data"]) {
              PopularBrandsDataType data = PopularBrandsDataType(
                  v["brand_id"],
                  v["brand_name"],
                  v["url_key"],
                  v["image"],
                  v["meta_title"] == null ? "Null" : v["meta_title"],
                  v["meta_keywords"] == null ? "Null" : v["meta_keywords"],
                  v["meta_description"] == null
                      ? "Null"
                      : v["meta_description"],
                  0,
                  v);
              valuesByAlpha.add(data);
              print("step3");
            }

            AlphaCategories mainData =
                AlphaCategories(u["startchar"], false, valuesByAlpha, u);

            popBrandsTemp.add(mainData);
          }

          // print(imageSliderTemp);
          setState(() {
            statePopularBrands = popBrandsTemp;
            isBrandLoading = false;
          });
          print("called2");
          this.setDataforBool(popBrandsTemp.length);

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
        isBrandLoading = false;
      });
    } catch (e) {
      setState(() {
        isBrandLoading = false;
      });
    }
    throw {
      //do nothing
    };
  }

  setDataforBool(var len) {
    List<bool> temp = [];
    for (var i = 0; i < len; i++) {
      temp.add(false);
    }
    setState(() {
      alphaIsPressed = temp;
    });
    this.filterTheData(0);
    print("finished");
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
                        // Container(
                        //     width: pageWidth * 0.90,
                        //     height: 50,
                        //     child: TextField(
                        //       onChanged: (text) {
                        //         setState(() {
                        //           // searchString = text;
                        //           // myFuture = this._getRestaurants();
                        //         });
                        //       },
                        //       autocorrect: true,
                        //       decoration: styles.ThemeText.searchBarStyle,
                        //     )),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10, top: 10),
                      child: Text(
                        "Brands",
                        style: styles.ThemeText.leftTextstyles,
                      ),
                    ),
                    // Container(
                    //   margin: EdgeInsets.only(right: 10, top: 10),
                    //   child: FlatButton(
                    //       onPressed: () {
                    //         this.setDataforBool();
                    //         setState(() {
                    //           isFilterApplied = false;
                    //         });
                    //       },
                    //       shape: isFilterApplied
                    //           ? styles.ThemeText.alphabetNotSelected
                    //           : styles.ThemeText.alphabetSelected,
                    //       color: isFilterApplied
                    //           ? Colors.white
                    //           : Color(Constants.primaryYellow),
                    //       child: Text("All")),
                    // ),
                  ],
                ),
                FutureBuilder(
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
                                child: Image(
                                  image:
                                      AssetImage('assets/images/NoRecord.png'),
                                  fit: BoxFit.fill,
                                  height: 150.0,
                                )),
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

                      return Container(
                        height: 50,
                        margin: EdgeInsets.only(top: 5, left: 10, bottom: 5),
                        child: GridView.builder(

                            //itemCount: no.of.items,
                            gridDelegate:
                                new SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1),
                            itemCount: snapshot.data.length == null
                                ? 0
                                : snapshot.data.length,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            // physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                padding: EdgeInsets.only(left: 5, right: 5),
                                child: RaisedButton(
                                    onPressed: () {
                                      filterTheData(index);
                                    },
                                    shape: alphaIsPressed[index]
                                        ? styles.ThemeText.alphabetSelected
                                        : styles.ThemeText.alphabetNotSelected,
                                    color: alphaIsPressed[index]
                                        ? Color(Constants.primaryYellow)
                                        : Colors.white,
                                    child:
                                        Text(snapshot.data[index].startchar)),
                              );
                            }),
                      );
                    }),

                Container(
                    margin: EdgeInsets.only(top: 10),
                    //height: MediaQuery.of(context).size.height,
                    child: isBrandLoading
                        ? SpinKitThreeBounce(
                            color: Color(Constants.logocolor),
                            size: 20.0,
                          )
                        :
                        //: isFilterApplied
                        //?
                        updated.length == 0
                            ? Center(
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
                                        style: styles.ThemeText.leftTextstyles),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                //itemCount: no.of.items,

                                itemCount: updated == null ? 0 : updated.length,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  //print(updated.length);
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/allItems', arguments: {
                                        "brandId": updated[index].brandId,
                                        "brandName": updated[index].brandName
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                          bottom: BorderSide(
                                              width: 1.0,
                                              color: Colors.black12),
                                        ),
                                      ),
                                      child: Text(
                                        updated[index].brandName,
                                        style:
                                            styles.ThemeText.appbarTextStyles,
                                      ),
                                    ),
                                  );
                                })
                    // : ListView.builder(
                    //     //itemCount: no.of.items,

                    //     itemCount: statePopularBrands == null
                    //         ? 0
                    //         : statePopularBrands.length,
                    //     scrollDirection: Axis.vertical,
                    //     shrinkWrap: true,
                    //     physics: NeverScrollableScrollPhysics(),
                    //     itemBuilder: (BuildContext context, int index) {
                    //       return GestureDetector(
                    //         onTap: () {},
                    //         child: Container(
                    //           padding: EdgeInsets.all(15),
                    //           decoration: BoxDecoration(
                    //             color: Colors.white,
                    //             border: Border(
                    //               bottom: BorderSide(
                    //                   width: 1.0, color: Colors.black12),
                    //             ),
                    //           ),
                    //           child: Text(
                    //             statePopularBrands[index].brandName,
                    //             style: styles.ThemeText.appbarTextStyles,
                    //           ),
                    //         ),
                    //       );
                    //     }),
                    ),
                // Text("hello"),
              ],
            ),
          )),
        ));
  }
}
