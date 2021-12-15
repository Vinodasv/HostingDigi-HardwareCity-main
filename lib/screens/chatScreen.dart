import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// class AmazonScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   elevation: 0.0,
//       //   backgroundColor: Colors.white,
//       //   title: Text(
//       //     "Go One",
//       //     style: TextStyle(color: Colors.black),
//       //   ),
//       // ),
//       body: SafeArea(
//         child: WebView(
//           initialUrl: "https://goone.in",
//           javascriptMode: JavascriptMode.unrestricted,
//           debuggingEnabled: false,
//           key: key ,
//           onPageFinished: doneLoading,
//           onPageStarted: startLoading,
//         ),
//       ),
//     );
//   }
// }

class chatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(backgroundColor: Colors.white, body: WebViewClass()));
  }
}

class WebViewClass extends StatefulWidget {
  WebViewState createState() => WebViewState();
}

class WebViewState extends State<WebViewClass> {
  int position = 1;
  final key = UniqueKey();
  doneLoading(String A) {
    setState(() {
      position = 0;
    });
  }

  startLoading(String A) {
    setState(() {
      position = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: IndexedStack(index: position, children: <Widget>[
        WebView(
          initialUrl:
              'https://v2.zopim.com/widget/popout.html?key=6FIVDCXQheiWd7dUCPAWf1Dli5JgiPcD',
          javascriptMode: JavascriptMode.unrestricted,
          debuggingEnabled: false,
          key: key,
          onPageFinished: doneLoading,
          onPageStarted: startLoading,
        ),
        Container(
          color: Colors.white,
          child: (LinearProgressIndicator(
            backgroundColor: Colors.redAccent,
          )),
        ),
      ]),
    ));
  }
}
