import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../constants.dart' as Constants;
import '../customicons.dart';
import '../styles.dart' as styles;

class ItemTile1 extends StatelessWidget {
  final int? qty;
  final bool? inCart;
  final String? imagePath;
  final String? itemName;
  final String? price;
  final String? standardprice;
  final String? gstprice;
  final String? gststandardprice;
  final String? count;
  final bool? fav;
  final Function? increament;
  final Function? decreament;
  final Function? funAddToCart;
  final Function? onPressed;

  final Function? favOnPress;
  final double? pageWidth;
  final String? optionscount;

  ItemTile1(
      {this.qty,
      this.inCart,
      this.imagePath,
      this.itemName,
      this.price,
      this.standardprice,
      this.increament,
      this.decreament,
      this.funAddToCart,
      this.onPressed,
      this.favOnPress,
      this.pageWidth,
      this.fav,
      this.count,
      this.optionscount,
      this.gstprice,
      this.gststandardprice});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed!();
      },
      child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              border: Border.all(color: Color(Constants.borderGreyColor))),
          child: Stack(
            children: [
              inCart!
                  ? Positioned(
                      top: 5,
                      right: 0,
                      child: Icon(
                        Icons.shopping_basket,
                        color: Color(Constants.logocolor),
                      ),
                      // child: Container(
                      //     padding: EdgeInsets.all(4),
                      //     decoration: BoxDecoration(
                      //         color: Color(Constants.primaryYellow),
                      //         borderRadius:
                      //             BorderRadius.all(Radius.circular(15.0)),
                      //         border: Border.all(width: 0.5)),
                      //     child: Text(
                      //       "In Cart",
                      //       style: styles.ThemeText.buttonTextStyles,
                      //     ))
                    )
                  : SizedBox(),
              Align(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: fav!
                            ? Icon(Icons.favorite, color: Color(Constants.pink))
                            : Icon(
                                Icons.favorite_border,
                              ),
                        alignment: Alignment.topLeft,
                        onPressed: () {
                          favOnPress!();
                        },
                      ),
                    ),
                    qty! > 0
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                            child: imagePath == null || imagePath == ""
                                ? Image(
                                    image: AssetImage(
                                        'assets/images/placeholder-logo.png'),
                                    fit: BoxFit.fill,
                                    height: 100.0,
                                  )
                                : FadeInImage.assetNetwork(
                                    image: imagePath!,
                                    placeholder:
                                        "assets/images/placeholder-logo.png", // your assets image path
                                    fit: BoxFit.fill,
                                    height: 100.0,
                                  ))
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                  child: imagePath == null || imagePath == ""
                                      ? Image(
                                          image: AssetImage(
                                              'assets/images/placeholder-logo.png'),
                                          fit: BoxFit.fill,
                                          height: 100.0,
                                        )
                                      : FadeInImage.assetNetwork(
                                          image: imagePath!,
                                          placeholder:
                                              "assets/images/placeholder-logo.png", // your assets image path
                                          fit: BoxFit.fill,
                                          height: 100.0,
                                        )),
                              Container(
                                color: Colors.red.withOpacity(0.6),
                                width: pageWidth,
                                padding: EdgeInsets.all(10),
                                child: Center(
                                    child: Text(
                                  "Out of Stock",
                                  style: styles.ThemeText.outOfOrder,
                                )),
                              ),
                            ],
                          ),
                    SizedBox(
                      child: Text(
                        itemName!,
                        textAlign: TextAlign.left,
                        style: styles.ThemeText.brandName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          child: Text(
                            "\$" + double.parse(gstprice!).toStringAsFixed(2),
                            style: styles.ThemeText.priceBold,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        if (gstprice != gststandardprice)
                          Container(
                            // margin: EdgeInsets.only(left: 20),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "\$" +
                                  double.parse(gststandardprice!)
                                      .toStringAsFixed(2),
                              style: styles.ThemeText.priceBoldStrikethrough,
                              textAlign: TextAlign.left,
                            ),
                          ),
                      ],
                    ),
                    if (optionscount == "0" && qty != 0)
                      Container(
                        width: pageWidth,
                        height: 35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(Constants.borderGreyColor),
                            ),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15))),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: Icon(Icons.remove),
                                iconSize: 14,
                                alignment: Alignment.centerLeft,
                                onPressed: () {
                                  decreament!();
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                count!,
                                style: styles.ThemeText.buttonTextStyles,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(Icons.add),
                                iconSize: 14,
                                alignment: Alignment.centerRight,
                                onPressed: () {
                                  increament!();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    qty! > 0

                        ///demo india
                        ? optionscount == "0"
                            // optionscount != null
                            ? Container(
                                width: pageWidth,
                                height: 36,
                                child: RaisedButton(
                                  color: Color(Constants.primaryYellow),
                                  shape: styles.ThemeText.borderRaidus1,
                                  onPressed: () {
                                    funAddToCart!();
                                  },
                                  child: inCart!
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              CustomIcons.shoppingcart,
                                              size: 14,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: Text(
                                                'Update Cart',
                                                style: styles
                                                    .ThemeText.buttonTextStyles,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              CustomIcons.shoppingcart,
                                              size: 14,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                'Add to Cart',
                                                style: styles
                                                    .ThemeText.buttonTextStyles,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              )
                            : Container(
                                width: pageWidth,
                                height: 36,
                                child: RaisedButton(
                                  color: Color(Constants.primaryYellow),
                                  shape: styles.ThemeText.borderRaidus1,
                                  onPressed: () {
                                    funAddToCart!();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Icon(
                                      //   Icons.more_horiz,
                                      //   size: 14,
                                      // ),
                                      Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Text(
                                          'More details',
                                          style:
                                              styles.ThemeText.buttonTextStyles,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                        : Container(
                            width: pageWidth,
                            height: 36,
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text(
                                      'Not Available',
                                      style: styles.ThemeText.buttonTextStyles,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

// Container(
//                                   padding: EdgeInsets.all(10),
//                                   margin: EdgeInsets.all(10),
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.all(
//                                           Radius.circular(15.0)),
//                                       border: Border.all(
//                                           color: Color(
//                                               Constants.borderGreyColor))),
//                                   child: Align(
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Align(
//                                           alignment: Alignment.topLeft,
//                                           child: IconButton(
//                                             icon: stateItems[index].fav
//                                                 ? Icon(Icons.favorite,
//                                                     color:
//                                                         Color(Constants.pink))
//                                                 : Icon(
//                                                     Icons.favorite_border,
//                                                   ),
//                                             alignment: Alignment.topLeft,
//                                             onPressed: () {
//                                               setState(() {
//                                                 snapshot.data[index].fav =
//                                                     !snapshot.data[index].fav;
//                                               });
//                                             },
//                                           ),
//                                         ),
//                                         ClipRRect(
//                                             borderRadius: BorderRadius.all(
//                                                 Radius.circular(30.0)),
//                                             child: snapshot.data[index]
//                                                             .imgPath ==
//                                                         null ||
//                                                     snapshot.data[index]
//                                                             .imgPath ==
//                                                         ""
//                                                 ? Image(
//                                                     image: AssetImage(
//                                                         'assets/images/placeholder-logo.png'),
//                                                     fit: BoxFit.fill,
//                                                     height: 60.0,
//                                                     width: 60.0)
//                                                 : FadeInImage.assetNetwork(
//                                                     image: snapshot
//                                                         .data[index].imgPath,
//                                                     placeholder:
//                                                         "assets/images/placeholder-logo.png", // your assets image path
//                                                     fit: BoxFit.fill,
//                                                     height: 60.0,
//                                                     width: 60.0)),
//                                         Text(
//                                           snapshot.data[index].itemName,
//                                           textAlign: TextAlign.center,
//                                         ),
//                                         Align(
//                                           alignment: Alignment.centerLeft,
//                                           child: Text(
//                                             snapshot.data[index].price
//                                                     .toString() +
//                                                 "\$",
//                                             textAlign: TextAlign.left,
//                                           ),
//                                         ),
//                                         Container(
//                                           width: pageWidth,
//                                           height: 35,
//                                           alignment: Alignment.center,
//                                           decoration: BoxDecoration(
//                                               border: Border.all(
//                                                 color: Color(
//                                                     Constants.borderGreyColor),
//                                               ),
//                                               borderRadius: BorderRadius.only(
//                                                   topLeft: Radius.circular(15),
//                                                   topRight: Radius.circular(15),
//                                                   bottomLeft:
//                                                       Radius.circular(15),
//                                                   bottomRight:
//                                                       Radius.circular(15))),
//                                           child: Stack(
//                                             children: [
//                                               Align(
//                                                 alignment: Alignment.centerLeft,
//                                                 child: IconButton(
//                                                   icon: Icon(Icons.remove),
//                                                   iconSize: 14,
//                                                   alignment:
//                                                       Alignment.centerLeft,
//                                                   onPressed: () {
//                                                     if (snapshot.data[index]
//                                                             .count !=
//                                                         0) {
//                                                       setState(() {
//                                                         snapshot.data[index]
//                                                             .count--;
//                                                       });
//                                                     }
//                                                   },
//                                                 ),
//                                               ),
//                                               Align(
//                                                 alignment: Alignment.center,
//                                                 child: Text(
//                                                   snapshot.data[index].count
//                                                       .toString(),
//                                                   style: styles.ThemeText
//                                                       .buttonTextStyles,
//                                                   textAlign: TextAlign.center,
//                                                 ),
//                                               ),
//                                               Align(
//                                                 alignment:
//                                                     Alignment.centerRight,
//                                                 child: IconButton(
//                                                   icon: Icon(Icons.add),
//                                                   iconSize: 14,
//                                                   alignment:
//                                                       Alignment.centerRight,
//                                                   onPressed: () {
//                                                     setState(() {
//                                                       snapshot
//                                                           .data[index].count++;
//                                                     });
//                                                   },
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Container(
//                                           width: pageWidth,
//                                           height: 36,
//                                           child: FlatButton(
//                                             color:
//                                                 Color(Constants.primaryYellow),
//                                             shape:
//                                                 styles.ThemeText.borderRaidus1,
//                                             onPressed: () {
//                                               print("Pressed");
//                                             },
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.center,
//                                               children: [
//                                                 Icon(
//                                                   CustomIcons.shoppingcart,
//                                                   size: 14,
//                                                 ),
//                                                 Padding(
//                                                   padding:
//                                                       const EdgeInsets.all(6.0),
//                                                   child: Text(
//                                                     'Add To Cart',
//                                                     style: styles.ThemeText
//                                                         .buttonTextStyles,
//                                                     textAlign: TextAlign.center,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ));
