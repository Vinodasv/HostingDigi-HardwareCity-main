import 'package:flutter/material.dart';

import '../constants.dart' as Constants;
import '../styles.dart' as styles;

class ProductTile1 extends StatelessWidget {
  final String? imagePath;
  final String? captionText;
  final Function? onPressed;

  ProductTile1({this.imagePath, this.captionText, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        this.onPressed!();
      },
      child: Container(
          // padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              border: Border.all(color: Color(Constants.borderGreyColor))),
          child: Align(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: ClipRRect(
                      // borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      child: imagePath == null || imagePath == ""
                          ? Image(
                              image: AssetImage(
                                  'assets/images/placeholder-logo.png'),
                              fit: BoxFit.fill,
                              // height: 30.0,
                              // width: 30.0
                            )
                          : FadeInImage.assetNetwork(
                              image: imagePath!,
                              placeholder:
                                  "assets/images/placeholder-logo.png", // your assets image path
                              fit: BoxFit.fill,
                              // height: 30.0,
                              // width: 30.0
                            )),
                ),
                Text(
                  captionText!,
                  textAlign: TextAlign.center,
                  style: styles.ThemeText.brandName,
                ),
              ],
            ),
          )),
    );
  }
}
