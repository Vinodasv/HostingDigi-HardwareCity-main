// import 'package:flutter/services.dart';
// import 'package:stripe_payment/stripe_payment.dart';
//
// class StripeTransactionResponse {
//   String? message;
//   bool? success;
//   String? paymentIntentId;
//   StripeTransactionResponse({this.message, this.success, this.paymentIntentId});
// }
//
// class StripeService {
//   static init(pk) {
//     StripePayment.setOptions(StripeOptions(publishableKey: pk));
//   }
//
//   // static Future<StripeTransactionResponse> payViaExistingCard(
//   //     {String amount, String currency, CreditCard card}) async {
//   //   try {
//   //     var paymentMethod = await StripePayment.createPaymentMethod(
//   //         PaymentMethodRequest(card: card));
//   //     var paymentIntent =
//   //         await StripeService.createPaymentIntent(amount, currency);
//   //     var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
//   //         clientSecret: paymentIntent['client_secret'],
//   //         paymentMethodId: paymentMethod.id));
//   //     if (response.status == 'succeeded') {
//   //       return new StripeTransactionResponse(
//   //           message: 'Transaction successful', success: true);
//   //     } else {
//   //       return new StripeTransactionResponse(
//   //           message: 'Transaction failed', success: false);
//   //     }
//   //   } on PlatformException catch (err) {
//   //     return StripeService.getPlatformExceptionErrorResult(err);
//   //   } catch (err) {
//   //     return new StripeTransactionResponse(
//   //         message: 'Transaction failed: ${err.toString()}', success: false);
//   //   }
//   // }
//
//   static Future<StripeTransactionResponse> payWithNewCard(
//       {String? amount, String? currency, String? sk}) async {
//     try {
//       // var paymentMethod = await StripePayment.paymentRequestWithCardForm(
//       //    CardFormPaymentRequest());
//
//       print("paymentmethod created");
//       //  var ttlAmount = (double.parse(amount) * 100).toStringAsFixed(0);
//
//       // var body = json.encode({
//       //   "amount": amount,
//       //   "currancyType": "usd",
//       //   "paymentMethodId": paymentMethod.id,
//       //   "restId": storeId
//       // });
//
//       // var result = await http.post(Constants.generateClientSecret,
//       //     headers: {
//       //       "Content-Type": "application/json",
//       //       HttpHeaders.authorizationHeader: token
//       //     },
//       //     body: body);
//       // print('after payment props');
//
//       // Map<String, dynamic> generateClientSecretResponse =
//       //     json.decode(result.body);
//
//       // print("payment intent created");
//       // print(generateClientSecretResponse);
//       // print(generateClientSecretResponse['intentClientsecret']);
//       var response = await StripePayment.confirmPaymentIntent(
//           PaymentIntent(clientSecret: sk, paymentMethodId: paymentMethod.id));
//
//       if (response.status == 'succeeded') {
//         return new StripeTransactionResponse(
//             message: 'Transaction successful',
//             success: true,
//             paymentIntentId: response.paymentIntentId);
//       } else {
//         return new StripeTransactionResponse(
//             message: 'Transaction failed', success: false);
//       }
//     } on PlatformException catch (err) {
//       return StripeService.getPlatformExceptionErrorResult(err);
//     } catch (err) {
//       print(err.toString());
//       return new StripeTransactionResponse(
//           message: 'Transaction failed', success: false);
//     }
//   }
//
//   static getPlatformExceptionErrorResult(err) {
//     String message = 'Transaction cancelled';
//     if (err.code == 'cancelled') {
//       message = 'Transaction cancelled';
//     }
//
//     return new StripeTransactionResponse(message: message, success: false);
//   }
//
// // static Future<Map<String, dynamic>> createPaymentIntent(
// //     String amount, String currency) async {
// //   try {
// //     print("payment intent creattion called");
// //     Map<String, dynamic> body = {
// //       'amount': amount,
// //       'currency': currency,
// //       'payment_method_types[]': 'card'
// //     };
// //     var response = await http.post(StripeService.paymentApiUrl,
// //         body: body, headers: StripeService.headers);
// //     return jsonDecode(response.body);
// //   } catch (err) {
// //     print('err charging user: ${err.toString()}');
// //   }
// //   return null;
// // }
// }
