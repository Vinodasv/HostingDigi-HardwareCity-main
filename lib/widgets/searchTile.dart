import 'package:flutter/material.dart';

import '../constants.dart' as Constants;
import '../styles.dart' as styles;

class SearchTile extends StatelessWidget {
  final int? qty;
  final String? imagePath;
  final String? itemName;
  final String? price1;
  final String? standardprice;
  final Function? onPressed;
  final double? pageWidth;

  SearchTile({
    this.qty,
    this.imagePath,
    this.itemName,
    this.price1,
    this.standardprice,
    this.onPressed,
    this.pageWidth,
  });

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
          child: Align(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                qty! > 0
                    ? ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        child: imagePath == null || imagePath == ""
                            ? Image(
                                image: AssetImage(
                                    'assets/images/placeholder-logo.png'),
                                fit: BoxFit.fill,
                                height: 60.0,
                                width: 60.0)
                            : FadeInImage.assetNetwork(
                                image: imagePath!,
                                placeholder:
                                    "assets/images/placeholder-logo.png", // your assets image path
                                fit: BoxFit.fill,
                                height: 60.0,
                                width: 60.0))
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
                                      height: 60.0,
                                      width: 60.0)
                                  : FadeInImage.assetNetwork(
                                      image: imagePath!,
                                      placeholder:
                                          "assets/images/placeholder-logo.png", // your assets image path
                                      fit: BoxFit.fill,
                                      height: 60.0,
                                      width: 60.0)),
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
                Text(
                  itemName!,
                  textAlign: TextAlign.left,
                  style: styles.ThemeText.brandName,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      child: Text(
                        "\$" + double.parse(price1!).toStringAsFixed(2),
                        style: styles.ThemeText.priceBold,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      // margin: EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "\$" + double.parse(standardprice!).toStringAsFixed(2),
                        style: styles.ThemeText.priceBoldStrikethrough,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
