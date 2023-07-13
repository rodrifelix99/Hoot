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
async function getUserObj(uid, addFollowers = true, built = null) {
  try {
    if (built !== null) {
      const user = built;
      user.uid = uid;
      user.followers = [];
      user.following = [];
      const followersSnapshot = await db.collection("users").doc(uid).collection("followers").get();
      const followingSnapshot = await db.collection("users").doc(uid).collection("following").get();
      followersSnapshot.forEach((follower) => user.followers.push(follower.id));
      followingSnapshot.forEach((follow) => user.following.push(follow.id));
      return user;
    } else {
      const doc = await db.collection("users").doc(uid).get();
      if (doc.exists) {
        const user = doc.data();
        user.uid = doc.id;
        if (addFollowers) {
          const followersSnapshot = await db.collection("users").doc(uid).collection("followers").get();
          const followingSnapshot = await db.collection("users").doc(uid).collection("following").get();
          user.followers = followersSnapshot.docs.map((follower) => follower.id);
          user.following = followingSnapshot.docs.map((follow) => follow.id);
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

/**
 * Sends a push notification to a user.
 * @param {string} uid - The user ID.
 * @param {string} title - The notification title.
 * @param {string} body - The notification body.
 * @param {object} data - The notification data.
 * @param {string} [token=null] - The user's FCM token. If not provided, it will be retrieved from the database.
 * @return {Promise<void>} A promise that resolves when the notification is sent.
 */
async function pushNotification(uid, title, body, data = null, token = null) {
  try {
    if (!token) {
      const user = await getUserObj(uid, false);
      token = user.fcmToken;
    }
    if (token) {
      const message = {
        notification: {
          title: title,
          body: body,
        },
        data: data,
        token: token,
      };
      await admin.messaging().send(message);
    }
  } catch (e) {
    error(e);
  }
}

/**
 * Store notification in the database.
 * @param {string} from - The sender ID.
 * @param {string} to - The recipient ID.
 * @param {int} type - The notification type.
 * @return {Promise<void>} A promise that resolves when the notification is stored.
 */
async function sendNotification(from, to, type) {
  try {
    const notification = {
      sender: from,
      type: type,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    await db.collection("users").doc(to).collection("notifications").add(notification);
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
    const user = await getUserObj(context.auth.uid, true);
    return user;
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
      const userInfo = await getUserObj(user.id, true, user.data());
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
        const user = await getUserObj(doc.id, true, doc.data());
        data.push(user);
      }
      if (data.length > 3) {
        return data;
      }
    }
    // get 10 users where the document id is not equal to the current user's id, must have a username and limit to 10
    const users = await db.collection("users").where("username", "!=", "").limit(10).get();
    const data = [];
    for (const doc of users.docs) {
      if (doc.id === uid) {
        continue;
      }
      const user = await getUserObj(doc.id, true, doc.data());
      data.push(user);
    }
    return data;
  } catch (e) {
    error(e);
  }
});

exports.followUser = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const user = data;
    await db.collection("users").doc(uid).collection("following").doc(user).set({
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await db.collection("users").doc(user).collection("followers").doc(uid).set({
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await sendNotification(uid, user, 1);
    await pushNotification(user, "New Follower", "You have a new follower", {type: "1", uid});
    return true;
  } catch (e) {
    error(e);
  }
});

exports.unfollowUser = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const user = data;
    await db.collection("users").doc(uid).collection("following").doc(user).delete();
    await db.collection("users").doc(user).collection("followers").doc(uid).delete();
    await sendNotification(uid, user, 2);
    await pushNotification(user, "Unfollowed", "You have beed unfollowed", {type: "2", uid});
    return true;
  } catch (e) {
    error(e);
  }
});

exports.getFollowers = functions.region("europe-west1").https.onCall(async (data) => {
  try {
    const uid = data;
    const followers = await db.collection("users").doc(uid).collection("followers").get();
    const results = [];
    for (const follower of followers.docs) {
      const user = await getUserObj(follower.id, true);
      results.push(user);
    }
    return results;
  } catch (e) {
    error(e);
  }
});

exports.getFollowing = functions.region("europe-west1").https.onCall(async (data) => {
  try {
    const uid = data;
    const following = await db.collection("users").doc(uid).collection("following").get();
    const results = [];
    for (const follow of following.docs) {
      const user = await getUserObj(follow.id, true);
      results.push(user);
    }
    return results;
  } catch (e) {
    error(e);
  }
});

exports.isFollowing = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const user = data;
    const following = await db.collection("users").doc(uid).collection("following").doc(user).get();
    return following.exists;
  } catch (e) {
    error(e);
  }
});

exports.getNotifications = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { startAfter } = data || { startAfter: null };
    let notifications = null;
    if (startAfter) {
      const startAfterTimestamp = admin.firestore.Timestamp.fromDate(new Date(startAfter));
      notifications = await db.collection("users").doc(uid).collection("notifications").orderBy("createdAt", "desc").startAfter(startAfterTimestamp).limit(10).get();
    } else {
      notifications = await db.collection("users").doc(uid).collection("notifications").orderBy("createdAt", "desc").limit(10).get();
    }
    results = [];

    if (notifications.size > 0) {
      results = await Promise.all(
        notifications.docs.map(async (doc) => {
          const senderUser = await getUserObj(doc.data().sender, true);
          return {
            id: doc.id,
            user: senderUser,
            ...doc.data(),
          };
        })
      );
    }

    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});

exports.countUnreadNotifications = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const notifications = await db.collection("users").doc(uid).collection("notifications").where("read", "==", false).get();
    return notifications.size;
  } catch (e) {
    error(e);
  }
});

exports.markNotificationsRead = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const batch = db.batch();
    const notifications = await db.collection("users").doc(uid).collection("notifications").where("read", "==", false).get();
    for (const notification of notifications.docs) {
      const ref = db.collection("users").doc(uid).collection("notifications").doc(notification.id);
      batch.update(ref, {read: true});
    }
    await batch.commit();
    return true;
  } catch (e) {
    error(e);
  }
});

exports.createFeed = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { title, description, icon, color, private, nsfw } = data;
    const feed = await db.collection("users").doc(uid).collection("feeds").add({
      title,
      description,
      icon,
      color,
      private,
      nsfw,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await db.collection("users").doc(uid).collection("feeds").doc(feed.id).collection("subscribers").doc(uid).set({
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await db.collection("users").doc(uid).collection("subscriptions").doc(feed.id).set({
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return feed.id;
  } catch (e) {
    error(e);
  }
});

exports.editFeed = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { feedId, title, description, icon, color, private, nsfw } = data;
    const ref = db.collection("users").doc(uid).collection("feeds").doc(feedId);
    await ref.update({
      title,
      description,
      icon,
      color,
      private,
      nsfw,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return true;
  } catch (e) {
    error(e);
  }
});

exports.deleteFeed = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { feedId } = data;
    const batch = db.batch();
    let writeCount = 0;
    const feed = await db.collection("users").doc(uid).collection("feeds").doc(feedId).get();
    if (feed.exists) {
      const subscribers = await db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("subscribers").get();
      for (const subscriber of subscribers.docs) {
        const ref = db.collection("users").doc(subscriber.id).collection("subscriptions").doc(feedId);
        if (writeCount < 500) {
          batch.delete(ref);
          writeCount++;
        } else {
          await batch.commit();
          batch = db.batch();
          batch.delete(ref);
          writeCount = 1;
        }
      }
      const posts = await db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("posts").get();
      for (const post of posts.docs) {
        const ref = db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("posts").doc(post.id);
        if (writeCount < 500) {
          batch.delete(ref);
          writeCount++;
        } else {
          await batch.commit();
          batch = db.batch();
          batch.delete(ref);
          writeCount = 1;
        }
      }
      const feedRef = db.collection("users").doc(uid).collection("feeds").doc(feedId);
      if (writeCount < 500) {
        batch.delete(feedRef);
        writeCount++;
      } else {
        await batch.commit();
        batch = db.batch();
        batch.delete(feedRef);
        writeCount = 1;
      }
    }
  } catch (e) {
    error(e);
  }
});

exports.getFeeds = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const { uid } = data;
    const feeds = await db.collection("users").doc(uid).collection("feeds").orderBy("updatedAt", "desc").get();
    const results = [];
    for (const feed of feeds.docs) {
      const feedObj = feed.data();
      feedObj.id = feed.id;
      const subscribersSnapshot = await db.collection("users").doc(uid).collection("feeds").doc(feed.id).collection("subscribers").get();
      feedObj.subscribers = subscribersSnapshot.docs.map((doc) => doc.id);
      const requestsSnapshot = await db.collection("users").doc(uid).collection("feeds").doc(feed.id).collection("requests").get();
      feedObj.requests = requestsSnapshot.docs.map((doc) => doc.id);
      results.push(feedObj);
    }
    info(results);
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});

exports.requestPrivateFeed = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { feedId, userId } = data;
    await db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("requests").doc(uid).set({
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await sendNotification(uid, userId, 5);
    await pushNotification(userId, "New feed request", "Someone wants to subscribe your private feed");
    return true;
  } catch (e) {
    error(e);
  }
});

exports.getFeedRequests = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { feedId } = data;
    const requests = await db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("requests").get();
    const results = [];
    for (const request of requests.docs) {
      const requestObj = await getUserObj(request.id, false);
      results.push(requestObj);
    }
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});

exports.acceptFeedRequest = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { feedId, userId } = data;
    const batch = db.batch();
    const requestRef = db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("requests").doc(userId);
    batch.delete(requestRef);
    const subscribedRef = db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("subscribers").doc(userId);
    batch.set(subscribedRef, {
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    const userSubscribedRef = db.collection("users").doc(userId).collection("subscriptions").doc(feedId);
    batch.set(userSubscribedRef, {
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await batch.commit();
    await sendNotification(uid, userId, 6);
    await pushNotification(userId, "Feed request accepted", "Your request to subscribe a private feed was accepted");
    return true;
  } catch (e) {
    error(e);
  }
});

exports.rejectFeedRequest = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { feedId, userId } = data;
    await db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("requests").doc(userId).delete();
    await sendNotification(uid, userId, 7);
    await pushNotification(userId, "Feed request rejected", "Your request to subscribe a private feed was rejected");
    return true;
  } catch (e) {
    error(e);
  }
});

exports.subscribeToFeed = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { feedId, userId } = data;
    const batch = db.batch();
    const subscribedRef = db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("subscribers").doc(uid);
    batch.set(subscribedRef, {
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    const userSubscribedRef = db.collection("users").doc(uid).collection("subscriptions").doc(feedId);
    batch.set(userSubscribedRef, {
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await batch.commit();
    await sendNotification(uid, userId, 3);
    await pushNotification(userId, "New subscriber", "Someone subscribed to one of your feeds");
    return true;
  } catch (e) {
    error(e);
  }
});

exports.unsubscribeFromFeed = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { feedId, userId } = data;
    const batch = db.batch();
    const subscribedRef = db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("subscribers").doc(uid);
    batch.delete(subscribedRef);
    const userSubscribedRef = db.collection("users").doc(uid).collection("subscriptions").doc(feedId);
    batch.delete(userSubscribedRef);
    await batch.commit();
    return true;
  } catch (e) {
    error(e);
  }
});

// on subscribing to feed copy all posts to main feed collection
exports.onSubscribe = functions.region("europe-west1").firestore.document("users/{userId}/feeds/{feedId}/subscribers/{subscribedId}").onCreate(async (snap, context) => {
  try {
    const { subscribedId, userId, feedId } = context.params;
    const feedPosts = await db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("posts").get();
    const batch = db.batch();
    let writeCount = 0;
    for (const feedPost of feedPosts.docs) {
      const feedPostRef = db.collection("users").doc(subscribedId).collection("mainFeed").doc(feedPost.id);
      writeCount++;
      if (writeCount > 499) {
        await batch.commit();
        batch = db.batch();
        writeCount = 0;
      } else {
        batch.set(feedPostRef, {
          feedId,
          userId,
          ...feedPost.data()
        });
      }
    }
    await batch.commit();
  } catch (e) {
    error(e);
  }
});

// on unsubscribing to feed delete all posts from main feed collection
exports.onUnsubscribe = functions.region("europe-west1").firestore.document("users/{userId}/feeds/{feedId}/subscribers/{subscribedId}").onDelete(async (snap, context) => {
  try {
    const { subscribedId, userId, feedId } = context.params;
    const feedPosts = await db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("posts").get();
    const batch = db.batch();
    let writeCount = 0;
    for (const feedPost of feedPosts.docs) {
      const feedPostRef = db.collection("users").doc(subscribedId).collection("mainFeed").doc(feedPost.id);
      writeCount++;
      if (writeCount > 499) {
        await batch.commit();
        batch = db.batch();
        writeCount = 0;
      } else {
        batch.delete(feedPostRef);
      }
    }
    await batch.commit();
  } catch (e) {
    error(e);
  }
});

exports.createPost = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { feedId, text, image } = data;
    await db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("posts").add({
      text,
      image,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return true;
  } catch (e) {
    error(e);
  }
});

// on creating a post add it to all subscribed feeds
exports.onCreatePost = functions.region("europe-west1").firestore.document("users/{userId}/feeds/{feedId}/posts/{postId}").onCreate(async (snap, context) => {
  try {
    const { userId, feedId, postId } = context.params;
    const feedSubscribers = await db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("subscribers").get();
    const batch = db.batch();
    let writeCount = 0;
    for (const feedSubscriber of feedSubscribers.docs) {
      const feedPostRef = db.collection("users").doc(feedSubscriber.id).collection("mainFeed").doc(postId);
      writeCount++;
      if (writeCount > 499) {
        await batch.commit();
        batch = db.batch();
        writeCount = 0;
      }
      batch.set(feedPostRef, {
        feedId,
        userId,
        ...snap.data(),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  } catch (e) {
    error(e);
  }
});

exports.deletePost = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { feedId, postId } = data;
    await db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("posts").doc(postId).delete();
    return true;
  } catch (e) {
    error(e);
  }
});

// on deleting a post delete it from all subscribed feeds
exports.onDeletePost = functions.region("europe-west1").firestore.document("users/{userId}/feeds/{feedId}/posts/{postId}").onDelete(async (snap, context) => {
  try {
    const { userId, feedId, postId } = context.params;
    const feedSubscribers = await db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("subscribers").get();
    const batch = db.batch();
    let writeCount = 0;
    for (const feedSubscriber of feedSubscribers.docs) {
      const feedPostRef = db.collection("users").doc(feedSubscriber.id).collection("mainFeed").doc(postId);
      writeCount++;
      if (writeCount > 499) {
        await batch.commit();
        batch = db.batch();
        writeCount = 0;
      }
      batch.delete(feedPostRef);
    }
    await batch.commit();
  } catch (e) {
    error(e);
  }
});

exports.getFeedPosts = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    let { startAfter, uid, feedId } = data;
    const startAfterTimestamp = startAfter ? admin.firestore.Timestamp.fromDate(new Date(startAfter)) : admin.firestore.Timestamp.fromDate(new Date());
    const feedPosts = await db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("posts").orderBy("createdAt", "desc").startAfter(startAfterTimestamp).limit(10).get();
    const results = [];
    for (const feedPost of feedPosts.docs) {
      const feedPostObj = feedPost.data();
      feedPostObj.id = feedPost.id;
      results.push(feedPostObj);
    }
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});

exports.getMainFeedPosts = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    let { startAfter } = data || { startAfter: null };
    const startAfterTimestamp = startAfter ? admin.firestore.Timestamp.fromDate(new Date(startAfter)) : admin.firestore.Timestamp.fromDate(new Date());
    const feedPosts = await db.collection("users").doc(uid).collection("mainFeed").orderBy("createdAt", "desc").startAfter(startAfterTimestamp).limit(10).get();
    const results = [];

    let cachedUsers = [];
    let cachedFeeds = [];

    for (const feedPost of feedPosts.docs) {
      const feedPostObj = feedPost.data();
      feedPostObj.id = feedPost.id;
      if (cachedFeeds.find((feed) => feed.id === feedPostObj.feedId)) {
        feedPostObj.feed = cachedFeeds.find((feed) => feed.id === feedPostObj.feedId);
      } else {
        const feedDoc = await db.collection("users").doc(feedPostObj.userId).collection("feeds").doc(feedPostObj.feedId).get();
        if (!feedDoc.exists) {
          continue;
        }
        feedPostObj.feed = feedDoc.data();
        feedPostObj.feed.id = feedPostObj.feedId;
        cachedFeeds.push(feedPostObj.feed);
      }
      if (cachedUsers.find((user) => user.uid === feedPostObj.userId)) {
        feedPostObj.user = cachedUsers.find((user) => user.uid === feedPostObj.userId);
      } else {
        feedPostObj.user = await getUserObj(feedPostObj.userId);
        cachedUsers.push(feedPostObj.user);
      }
      results.push(feedPostObj);
    }
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});
