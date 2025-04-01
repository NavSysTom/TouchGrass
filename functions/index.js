const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Function to check and notify users every 4 hours
exports.checkAndNotifyUser = functions.pubsub
    .schedule("every 4 hours")
    .onRun(async (context) => {
      const db = admin.firestore();
      const usersRef = db.collection("users");

      const snapshot = await usersRef.get();
      const now = new Date();

      snapshot.forEach(async (doc) => {
        const userData = doc.data();
        const lastPostTime = userData.lastPostTime ? userData.lastPostTime.toDate() : null;
        const fcmToken = userData.fcmToken;

        // Ensure lastPostTime and fcmToken exist before proceeding
        if (!lastPostTime || !fcmToken) {
          console.log(`Skipping user ${doc.id} due to missing data.`);
          return;
        }

        // Check if the user hasn't posted in the last 4 hours and send a notification
        if (now - lastPostTime >= 4 * 60 * 60 * 1000 && !userData.hasPostedToday) {
          const message = {
            notification: {
              title: "Reminder!",
              body: "Post today to keep your streak going!",
            },
            token: fcmToken,
          };

          try {
            await admin.messaging().send(message);
            console.log(`Notification sent to user ${doc.id}`);
          } catch (error) {
            console.error(`Failed to send notification to user ${doc.id}:`, error);
          }
        }
      });
    });

// Function to reset hasPostedToday for all users at midnight
exports.resetHasPostedToday = functions.pubsub
    .schedule("every day 00:00")
    .onRun(async (context) => {
      const db = admin.firestore();
      const usersRef = db.collection("users");

      const snapshot = await usersRef.get();
      snapshot.forEach(async (doc) => {
        try {
          await doc.ref.update({ hasPostedToday: false });
          console.log(`Reset hasPostedToday for user ${doc.id}`);
        } catch (error) {
          console.error(`Failed to reset hasPostedToday for user ${doc.id}:`, error);
        }
      });

      console.log("Reset hasPostedToday for all users");
    });