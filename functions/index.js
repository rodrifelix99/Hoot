const functions = require("firebase-functions");
const {
  // log,
  info,
  // debug,
  // warn,
  error,
  // write,
} = require("firebase-functions/logger");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();

// Get a reference to the Firestore database
const db = admin.firestore();

exports.createUserDocument = functions.region("europe-west1").auth.user().onCreate(async (user) => {
  try {
    // Create a document for the new user in Firestore
    await db.collection("users").doc(user.uid).set({
      displayName: user.displayName || null,
      username: null,
      bigAvatar: user.photoURL || null,
      smallAvatar: user.photoURL || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    info("User created with uid " + user.uid);
  } catch (e) {
    error(e);
  }
});

exports.deleteUserDocument = functions.region("europe-west1").auth.user().onDelete(async (user) => {
  try {
    // Delete the document for the deleted user in Firestore
    await db.collection("users").doc(user.uid).delete();
    info("User deleted with uid " + user.uid);
  } catch (e) {
    error(e);
  }
});

// get authenticated user info from firestore
exports.getUserInfo = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const user = await db.collection("users").doc(context.auth.uid).get();
    const userInfo = user.data();
    userInfo.uid = user.id;
    return userInfo;
  } catch (e) {
    error(e);
  }
});

exports.testEndpoint = functions.region("europe-west1").https.onCall(async () => {
  try {
    return "Hello World";
  } catch (e) {
    error(e);
  }
});

exports.updateUser = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const info = JSON.parse(data);
    info.updatedAt = admin.firestore.FieldValue.serverTimestamp();
    await db.collection("users").doc(context.auth.uid).update(info);
    await admin.auth().updateUser(context.auth.uid, {
      displayName: data.displayName,
      photoURL: data.bigAvatar,
    });
    return true;
  } catch (e) {
    error(e);
  }
});

exports.isUsernameAvailable = functions.region("europe-west1").https.onCall(async (data) => {
  try {
    const username = data;
    const user = await db.collection("users").where("username", "==", username).get();
    info(user.empty + " " + username);
    return user.empty;
  } catch (e) {
    error(e);
  }
});

exports.setFCMToken = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const token = data;
    await db.collection("users").doc(context.auth.uid).update({
      fcmToken: token,
    });
    return true;
  } catch (e) {
    error(e);
  }
});

exports.sendTestNotification = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const token = data;
    // get photoUrl from auth
    // const userPhotoURL = context.auth.photoURL;
    const message = {
      notification: {
        title: "Test Notification",
        body: "This is a test notification",
      },
      token: token,
      android: {
        notification: {
          imageUrl: "https://play-lh.googleusercontent.com/pEZvyjV4HNa9dwxYB4g-YzRVmbtNEwKdo_YpGbkDucVftFAx93gXrXYJYnTaT8TaDg", // URL of the image
        },
      },
      apns: {
        payload: {
          aps: {
            "mutable-content": 1,
          },
        },
        fcm_options: {
          image: "https://play-lh.googleusercontent.com/pEZvyjV4HNa9dwxYB4g-YzRVmbtNEwKdo_YpGbkDucVftFAx93gXrXYJYnTaT8TaDg", // URL of the image
        },
      },
      webpush: {
        headers: {
          image: "https://play-lh.googleusercontent.com/pEZvyjV4HNa9dwxYB4g-YzRVmbtNEwKdo_YpGbkDucVftFAx93gXrXYJYnTaT8TaDg", // URL of the image
        },
      },
    };
    await admin.messaging().send(message);
    return true;
  } catch (e) {
    console.error(e);
    throw new functions.https.HttpsError("internal", "An error occurred while sending the notification.");
  }
});

