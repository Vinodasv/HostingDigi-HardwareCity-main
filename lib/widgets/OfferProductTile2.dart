import 'package:flutter/material.dart';

import '../constants.dart' as Constants;
import '../styles.dart' as styles;

class OfferProductTile extends StatelessWidget {
  final String? imagePath;
  final String? captionText;
  final Function? onPressed;
  final dynamic? discount;

  OfferProductTile(
      {this.imagePath, this.captionText, this.onPressed, this.discount});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        this.onPressed!();
      },
      child: Padding(
        padding:
            const EdgeInsets.only(left: 3.0, right: 3.0, bottom: 3.0, top: 3.0),
        child: Stack(
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            imagePath == null || imagePath == ""
                ? Image(
                    image: AssetImage('assets/images/placeholder-logo.png'),
                    fit: BoxFit.cover,
                    // height: 30.0,
                    // width: 30.0
                  )
                : FadeInImage.assetNetwork(
                    image: imagePath!,
                    placeholder:
                        "assets/images/placeholder-logo.png", // your assets image path
                    height: 150.0,
                    fit: BoxFit.fill,
                    width: 150.0),
            // Container(
            //   color: Colors.black.withOpacity(0.35),
            // ),
            Center(
              child: Text(
                captionText!,
                textAlign: TextAlign.center,
                style: styles.ThemeText.offerbrandName,
              ),
            ),
            if (discount != null && discount != 0)
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                  height: 20,
                  color: Color(Constants.primaryYellow),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        "Up to $discount% off",
                        style: styles.ThemeText.offerTextStyles,
                      ),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
