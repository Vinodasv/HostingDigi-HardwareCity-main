import { firestore, messaging } from "firebase-admin";
import * as functions from "firebase-functions";

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript

const admin = require('firebase-admin');
admin.initializeApp();
exports.scheduledFunctionCrontab = functions.pubsub.schedule('0 9 * * *')
  .onRun(async () => {
    const fcm = messaging();
    const customers = firestore().collection('cart').get();
    const datas = (await customers).docs.map((doc) => doc.data()) as Array<any>;
    datas.forEach(data => {
        if(!data["isEmpty"]) {
               var device = data["token"];
               const payload = {
                notification: {
                  title: "Hey "+ data["name"],
                  body: "Your cart is waiting for you !",
                  sound: "default",
                },
              };
              fcm.sendToDevice(device, payload);
        }
    });
  return null;
});
