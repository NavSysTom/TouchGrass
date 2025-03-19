const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.checkAndNotifyUser = functions.pubsub
    .schedule("every 4 hours")
    .onRun(async (context) => {
      const db = admin.firestore();
      const usersRef = db.collection("users");

      const snapshot = await usersRef.get();
      const now = new Date();

      snapshot.forEach(async (doc) => {
        const userData = doc.data();
        const lastPostTime = userData.lastPostTime.toDate();
        const fcmToken = userData.fcmToken;

        if (now - lastPostTime >= 4 * 60 * 60 * 1000 &&
        !userData.hasPostedToday) {
          const message = {
            notification: {
              title: "Reminder!",
              body: "Post today to keep your streak going!",
            },
            token: fcmToken,
          };

          await admin.messaging().send(message);
        }
      });
    });

exports.resetHasPostedToday = functions.pubsub
    .schedule("every day 00:00")
    .onRun(async (context) => {
      const db = admin.firestore();
      const usersRef = db.collection("users");

      const snapshot = await usersRef.get();
      snapshot.forEach(async (doc) => {
        await doc.ref.update({hasPostedToday: false});
      });

      console.log("Reset hasPostedToday for all users");
    });
