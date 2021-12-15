import 'package:HardwareCity/screens/PaypalPayment.dart';
import 'package:HardwareCity/screens/singleproductDetails.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './screens/AllBrandScreens.dart';
import './screens/AllCategories.dart';
import './screens/AllItems.dart';
import './screens/ChangePassword.dart';
import './screens/CheckoutScreen.dart';
import './screens/FavouritesScreen.dart';
import './screens/FeaturedBrands.dart';
import './screens/FeedbackScreen.dart';
import './screens/ForgetPassword.dart';
import './screens/LoginScreen.dart';
import './screens/OrderDetails.dart';
import './screens/PDFViewer.dart';
import './screens/PaymentmethodsScreen.dart';
import './screens/PromotionalItems.dart';
import './screens/Registration.dart';
import './screens/TermsAndConditions.dart';
import './screens/bottomTabRoute.dart';
import './screens/chatScreen.dart';
import './screens/editProfileScreen.dart';
import './screens/homeScreen.dart';
import './screens/myCart.dart';
import './screens/myOrders.dart';
import './screens/productDetails.dart';
import './screens/profileScreen.dart';
import './screens/subCategories.dart';
import './states/customerProfileState.dart';
//screens
import './states/myCartState.dart';
import 'models/HomeScreenModels.dart';
import 'screens/BrandItemsScreen.dart';
import 'services/LocalNotifyManager.dart';
import 'services/pushNotificationService.dart';

class Cart {
  static List<CartDataType> cart = [];
}

var intialRoute = '/login';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  PushNotificationService _pushNotificationService =
      new PushNotificationService();
  _pushNotificationService.initialise();
  var prefs = await SharedPreferences.getInstance();
  try {
    var temp =
        prefs.get("opened") != null ? prefs.get("opened") ?? false : false;

    bool isOpened = (temp.toString()).toLowerCase() == 'true';
    if ((isOpened)) {
      //  prefs.remove("user");

      intialRoute = '/bottomTab';
    }
  } catch (e) {
    intialRoute = '/login';
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  onNotificationReceive(ReceiveNotification notification) {
    print('notification received: ${notification.id}');
  }

  onNotificationClick(String payload) {}

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    final sharedPrefs = await SharedPreferences.getInstance();
    var cartList = sharedPrefs.get("cart");
    if (cartList == null) {
      //do nothing
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      await localNotifyManager.showCartNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => CartState()),
      ],
      child: MaterialApp(
        //home: new Splash(),
        debugShowCheckedModeBanner: false,
        title: "HardwareCity",
        initialRoute: intialRoute,
        // initialRoute: '/payment',
        //   initialRoute: '/restaurant-subscription',
        routes: {
          '/login': (context) => LoginScreen(),
          '/registration': (context) => Registration(),
          '/bottomTab': (context) => HomeDashScreen(),
          '/customerProfile': (context) => CustomerProfileScreen(),
          '/myOrderScreen': (context) => MyCartScreen(),
          '/homeScreen': (context) => HomeScreen(),
          '/featuredScreen': (context) => FeaturedBrandScreen(),
          '/allBrandsScreen': (context) => AllBrandsScreen(),
          '/editProfileScreen': (context) => EditProfileScreen(),
          '/allCategories': (context) => AllCategoriesScreen(),
          '/allItems': (context) => AllItemsScreen(),
          '/productDetails': (context) => ProductDetailsScreen(),
          '/singleproductDetails': (context) => SingleProductDetailsScreen(),
          '/checkoutScreen': (context) => CheckoutScreen(),
          '/feedbackScreen': (context) => FeedbackScreen(),
          '/subCategoryScreen': (context) => SubCategoryScreen(),
          '/favScreen': (context) => FavouriteScreen(),
          '/paymentmethods': (context) => PaymentmethodsScreen(),
          '/allItemsSearch': (context) => AllItemsSearchScreen(),
          '/T&C': (context) => TermsAndConditions(),
          '/orderDetails': (context) => OrderDetails(),
          '/changePass': (context) => ChangePassword(),
          '/forgotPass': (context) => ForgetPassword(),
          '/promotionalItems': (context) => PromotionalItems(),
          '/pdfviewer': (context) => PDFViewer(),
          '/chatScreen': (context) => chatScreen(),
          '/paypal': (context) => PaypalPayment(),
          '/myOrders': (context) => MyOrdersScreen(),
        },
      ),
    );
  }
}
