/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendChatNotification = functions.firestore
  .document("chatRooms/{chatRoomId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    const message = snapshot.data();
    const { senderId, message: text, timestamp, isRead } = message;

    if (isRead) return; // Don't send notification if already read.

    const chatRoomId = context.params.chatRoomId;
    const senderDoc = await admin.firestore().collection("users").doc(senderId).get();
    const senderName = senderDoc.data()?.username || "Someone";

    const recipientId = chatRoomId.replace(senderId, "").replace("_", "");
    const recipientDoc = await admin.firestore().collection("users").doc(recipientId).get();
    const recipientToken = recipientDoc.data()?.fcmToken;

    if (!recipientToken) return;

    const payload = {
      notification: {
        title: `New message from ${senderName}`,
        body: text,
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
      token: recipientToken,
    };

    await admin.messaging().send(payload);
  });
