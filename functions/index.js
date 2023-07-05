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

exports.createPost = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    info(data);
    const post = data;
    post.user = db.collection("users").doc(context.auth.uid);
    post.createdAt = admin.firestore.FieldValue.serverTimestamp();
    post.updatedAt = admin.firestore.FieldValue.serverTimestamp();
    post.hashtags = [];
    const regex = /(?:^|\s)(?:#)([a-zA-Z\d]+)/gm;
    let m;
    let i = 0;
    while ((m = regex.exec(post.text)) !== null && i < 10) {
      // This is necessary to avoid infinite loops with zero-width matches
      if (m.index === regex.lastIndex) {
        regex.lastIndex++;
      }
      post.hashtags.push(m[1]);
      i++;
    }
    await db.collection("users").doc(context.auth.uid).collection("posts").add(post);
    await db.collection("users").doc(context.auth.uid).collection("feed").add(post);
    return true;
  } catch (e) {
    error(e);
    return false;
  }
});

exports.onPostCreated = functions.region("europe-west1").firestore.document("users/{userId}/posts/{postId}").onCreate(async (snapshot, context) => {
  try {
    const post = snapshot.data();
    const followers = await db.collection("users").doc(context.params.userId).collection.followers.get();
    const promises = [];
    for (const follower of followers) {
      uid = follower.id;
      promises.push(db.collection("users").doc(uid).collection("feed").add(post));
    }
    await Promise.all(promises);
    return true;
  } catch (e) {
    error(e);
    return false;
  }
});

exports.deletePost = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const postId = data;
    await db.collection("users").doc(context.auth.uid).collection("posts").doc(postId).delete();
    await db.collection("users").doc(context.auth.uid).collection("feed").doc(postId).delete();
    return true;
  } catch (e) {
    error(e);
    return false;
  }
});

exports.onPostDeleted = functions.region("europe-west1").firestore.document("users/{userId}/posts/{postId}").onDelete(async (snapshot, context) => {
  try {
    const post = snapshot.data();
    const followers = await db.collection("users").doc(context.params.userId).collection.followers.get();
    const promises = [];
    for (const follower of followers) {
      uid = follower.id;
      promises.push(db.collection("users").doc(uid).collection("feed").where("id", "==", post.id).get());
    }
    const results = await Promise.all(promises);
    for (const result of results) {
      for (const doc of result.docs) {
        await doc.ref.delete();
      }
    }
    return true;
  } catch (e) {
    error(e);
  }
});

exports.updatePost = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const post = JSON.parse(data);
    post.updatedAt = admin.firestore.FieldValue.serverTimestamp();
    await db.collection("users").doc(context.auth.uid).collection("posts").doc(post.id).update(post);
    await db.collection("users").doc(context.auth.uid).collection("feed").doc(post.id).update(post);
    return true;
  } catch (e) {
    error(e);
    return false;
  }
});

exports.onPostUpdated = functions.region("europe-west1").firestore.document("users/{userId}/posts/{postId}").onUpdate(async (change, context) => {
  try {
    const post = change.after.data();
    const followers = await db.collection("users").doc(context.params.userId).collection.followers.get();
    const promises = [];
    for (const follower of followers) {
      uid = follower.id;
      promises.push(db.collection("users").doc(uid).collection("feed").where("id", "==", post.id).get());
    }
    const results = await Promise.all(promises);
    for (const result of results) {
      for (const doc of result.docs) {
        await doc.ref.update(post);
      }
    }
    return true;
  } catch (e) {
    error(e);
  }
});

exports.getFeed = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const startAfter = data ? new Date(data) : new Date();
    const posts = await db.collection("users").doc(context.auth.uid).collection("feed").orderBy("createdAt", "desc").startAfter(startAfter).limit(10).get();
    const feed = [];
    const cashedUsers = [];
    for (const post of posts.docs) {
      const postData = post.data();
      postData.id = post.id;
      if (!cashedUsers[post.data().user.id]) {
        cashedUsers[post.data().user.id] = await getUserObject(post.data().user.id);
      }
      if (cashedUsers[post.data().user.id].username === "") {
        continue;
      }
      postData.user = cashedUsers[post.data().user.id];
      const likesSnapshot = await db.collection("users").doc(context.auth.uid).collection("feed").doc(post.id).collection("likes").get();
      const commentsSnapshot = await db.collection("users").doc(context.auth.uid).collection("feed").doc(post.id).collection("comments").get();
      postData.likes = likesSnapshot.size > 0 ? likesSnapshot.docs.map((doc) => doc.data().user.id) || [] : [];
      postData.comments = commentsSnapshot.size > 0 ? commentsSnapshot.docs.map((doc) => doc.data()) || [] : [];
      feed.push(postData);
    }
    return JSON.stringify(feed);
  } catch (e) {
    error(e);
  }
});


exports.followUser = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = data;
    await db.collection("users").doc(context.auth.uid).collection("following").doc(uid).set({
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await db.collection("users").doc(uid).collection("followers").doc(context.auth.uid).set({
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return true;
  } catch (e) {
    error(e);
  }
});

exports.onFollowUser = functions.region("europe-west1").firestore.document("users/{userId}/following/{followingId}").onCreate(async (snapshot, context) => {
  try {
    const uid = context.params.userId;
    const followingId = context.params.followingId;
    const posts = await db.collection("users").doc(followingId).collection("posts").get();
    const promises = [];
    for (const post of posts) {
      promises.push(db.collection("users").doc(uid).collection("feed").add(post.data()));
    }
    await Promise.all(promises);
    return true;
  } catch (e) {
    error(e);
  }
});

exports.unfollowUser = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = data;
    await db.collection("users").doc(context.auth.uid).collection("following").doc(uid).delete();
    await db.collection("users").doc(uid).collection("followers").doc(context.auth.uid).delete();
    return true;
  } catch (e) {
    error(e);
  }
});

exports.onUnfollowUser = functions.region("europe-west1").firestore.document("users/{userId}/following/{followingId}").onDelete(async (snapshot, context) => {
  try {
    const uid = context.params.userId;
    const followingId = context.params.followingId;
    const posts = await db.collection("users").doc(followingId).collection("posts").get();
    const promises = [];
    for (const post of posts) {
      const query = await db.collection("users").doc(uid).collection("feed").where("id", "==", post.id).get();
      for (const doc of query.docs) {
        promises.push(doc.ref.delete());
      }
    }
    await Promise.all(promises);
    return true;
  } catch (e) {
    error(e);
  }
});

// suggest 10 users to follow based on the user's followers
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

exports.isFollowing = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = data;
    const query = await db.collection("users").doc(context.auth.uid).collection("following").doc(uid).get();
    return query.exists;
  } catch (e) {
    error(e);
  }
});
