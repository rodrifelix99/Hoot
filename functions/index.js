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

/**
 * Retrieves user data from the database.
 * @param {string} uid - The user ID.
 * @param {boolean} [addFollowers=true] - Indicates whether to include follower information. Default is true.
 * @param {object} [built=null] - An optional pre-built user object.
 * @return {Promise<object|null>} A promise that resolves with the user data or null if the user doesn't exist.
 */
async function getUserObject(uid, addFollowers = true, built = null) {
  try {
    if (!!built) {
      const user = built;
      user.uid = uid;
      user.followers = [];
      user.following = [];
      const followers = await db.collection("users").doc(uid).collection("followers").get() || [];
      for (const follower of followers.docs) {
        user.followers.push(follower.id);
      }
      const following = await db.collection("users").doc(uid).collection("following").get() || [];
      for (const follow of following.docs) {
        user.following.push(follow.id);
      }
      return user;
    } else {
      const doc = await db.collection("users").doc(uid).get();
      if (doc.exists) {
        const user = doc.data();
        user.uid = doc.id;
        if (addFollowers) {
          user.followers = [];
          user.following = [];
          const followers = await db.collection("users").doc(uid).collection("followers").get() || [];
          for (const follower of followers.docs) {
            user.followers.push(follower.id);
          }
          const following = await db.collection("users").doc(uid).collection("following").get() || [];
          for (const follow of following.docs) {
            user.following.push(follow.id);
          }
        }
        return user;
      } else {
        return null;
      }
    }
  } catch (e) {
    error(e);
  }
}

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

exports.searchUsers = functions.region("europe-west1").https.onCall(async (data) => {
  try {
    // query is the search string trimmed and lowercased and remove @
    const query = data.trim().toLowerCase().replace("@", "");
    const users = await db.collection("users").where("username", ">=", query).where("username", "<=", query + "\uf8ff").get();
    const results = [];
    for (const user of users.docs) {
      const userInfo = await getUserObject(user.id, true, user.data());
      results.push(userInfo);
    }
    return results;
  } catch (e) {
    error(e);
  }
});

exports.getSuggestedUsers = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const query = await db.collection("users").doc(uid).collection("following").get();
    const promises = [];
    if (query.size > 0) {
      for (const doc of query.docs) {
        promises.push(db.collection("users").doc(doc.id).collection("following").get());
      }
      const results = await Promise.all(promises);
      const following = new Set();
      for (const result of results) {
        for (const doc of result.docs) {
          following.add(doc.id);
        }
      }
      const users = await db.collection("users").where("id", "not-in", [...following, uid]).limit(10).get();
      const data = [];
      for (const doc of users.docs) {
        const user = await getUserObject(doc.id, true, doc.data());
        data.push(user);
      }
      return data;
    } else {
      // get 10 users where the document id is not equal to the current user's id, must have a username and limit to 10
      const users = await db.collection("users").where("username", "!=", "").limit(10).get();
      const data = [];
      for (const doc of users.docs) {
        if (doc.id === uid) {
          continue;
        }
        const user = await getUserObject(doc.id, true, doc.data());
        data.push(user);
      }
      return data;
    }
  } catch (e) {
    error(e);
  }
});

