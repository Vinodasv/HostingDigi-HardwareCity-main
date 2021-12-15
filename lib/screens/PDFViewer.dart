import '../customicons.dart';
import 'package:flutter/material.dart';
import '../constants.dart' as Constants;
import '../styles.dart' as styles;
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewer extends StatefulWidget {
  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  String url = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10), () {
      final Map<String, Object> rcvdData =
          ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
      if (rcvdData != null) {
        setState(() {
          url = rcvdData["url"].toString();
          print(url);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var pageWidth = MediaQuery.of(context).size.width;
    var pageHeight = MediaQuery.of(context).size.height;
    print(url);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
//        backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(CustomIcons.backarrow,
                color: Color(Constants.primaryYellow)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Color(Constants.logocolor),
          elevation: 16,
          title: Text(
            "PDF Viewer",
            style: styles.ThemeText.appbarTextStyles2,
          ),
        ),
        body: SingleChildScrollView(
            child: Container(
          child: url != ""
              ? SfPdfViewer.network(
                  url.toString(),
                  onDocumentLoadFailed: (details) => {
                    Fluttertoast.showToast(
                      msg: details.error,
                      toastLength: Toast.LENGTH_SHORT,
                      webBgColor: "#e74c3c",
                      timeInSecForIosWeb: 5,
                    ),
                  },
                )
              : SizedBox(),
        )));
  }
}
