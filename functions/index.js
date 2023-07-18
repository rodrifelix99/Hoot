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
 * @param {boolean} [addSubscribed=true] - Indicates whether to include subscribed feeds. Default is true.
 * @param {object} [built=null] - An optional pre-built user object.
 * @return {Promise<object|null>} A promise that resolves with the user data or null if the user doesn't exist.
 */
async function getUser(uid, addSubscribed = true, built = null) {
  try {
    if (built !== null) {
      const user = built;
      user.uid = uid;
      const subscribedSnapshot = await db.collection("users").doc(uid).collection("subscriptions").get();
      user.subscriptions = subscribedSnapshot.docs.map((subscription) => subscription.id);
      return user;
    } else {
      const doc = await db.collection("users").doc(uid).get();
      if (doc.exists) {
        const user = doc.data();
        user.uid = doc.id;
        if (addSubscribed) {
          const subscribedSnapshot = await db.collection("users").doc(uid).collection("subscriptions").get();
          user.subscriptions = subscribedSnapshot.docs.map((subscription) => subscription.id);
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
 * Retrieves a Feed object from the database.
 * @param {string} uid - The user ID.
 * @param {string} feedId - The feed ID.
 * @param {boolean} [listSubscriberIds=false] - Indicates whether to include subscriber IDs. Default is false.
 * @param {boolean} [requests=false] - Indicates whether to include request IDs. Default is false.
 * @param {boolean} [addUserObj=false] - Indicates whether to include the user object. Default is false.
 * @return {Promise<object|null>} A promise that resolves with the feed object or null if the feed doesn't exist.
 */
async function getFeed(uid, feedId, requests = false, listSubscriberIds = false, addUserObj = false) {
  try {
    const doc = await db.collection("users").doc(uid).collection("feeds").doc(feedId).get();
    if (doc.exists) {
      const feed = doc.data();
      feed.id = doc.id;
      if (listSubscriberIds) {
        const subscribersSnapshot = await db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("subscribers").get();
        feed.subscribers = subscribersSnapshot.docs.map((subscriber) => subscriber.id);
      }
      if (requests) {
        const requestsSnapshot = await db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("requests").get();
        feed.requests = requestsSnapshot.docs.map((request) => request.id);
      }
      if (addUserObj) {
        feed.user = await getUser(uid, true);
      }
      return feed;
    } else {
      return null;
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
async function sendPush(uid, title, body, data = {}, token = null) {
  try {
    if (!token) {
      const user = await getUser(uid, false);
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
async function sendDatabaseNotification(from, to, type, feedAuthor = null, feedId = null, postId = null) {
  try {
    const notification = {
      sender: from,
      feedAuthor: feedAuthor,
      feedId: feedId,
      postId: postId,
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
    const user = await getUser(context.auth.uid, true);
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
      const userInfo = await getUser(user.id, true, user.data());
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
    const users = await db.collection("users").where("username", "!=", null).limit(10).get();
    const results = [];
    for (const user of users.docs) {
      if (user.id !== uid) {
        results.push(await getUser(user.id, true, user.data()));
      }
    }
    return results;
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
          const senderUser = await getUser(doc.data().sender, true);
          const feed = doc.data().feedId && doc.data().feedAuthor ? await getFeed(doc.data().feedAuthor, doc.data().feedId) : null;
          return {
            id: doc.id,
            user: senderUser,
            feed: feed,
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
      userId: uid,
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
      nsfw
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
    await batch.commit();
    return true;
  } catch (e) {
    error(e);
    return false;
  }
});

exports.getFeeds = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const { uid } = data;
    const feeds = await db.collection("users").doc(uid).collection("feeds").orderBy("updatedAt", "desc").get();
    const results = [];
    for (const feed of feeds.docs) {
      const feedObj = await getFeed(uid, feed.id, true, true);
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
    await sendDatabaseNotification(uid, userId, 5, userId, feedId);
    await sendPush(userId, "New feed request", "Someone wants to subscribe your private feed");
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
      const requestObj = await getUser(request.id, false);
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
    await sendDatabaseNotification(uid, userId, 6, uid, feedId);
    await sendPush(userId, "Feed request accepted", "Your request to subscribe a private feed was accepted");
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
    await sendDatabaseNotification(uid, userId, 7, uid, feedId);
    await sendPush(userId, "Feed request rejected", "Your request to subscribe a private feed was rejected");
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
      userId: userId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await batch.commit();
    await sendDatabaseNotification(uid, userId, 3, userId, feedId);
    await sendPush(userId, "New subscriber", "Someone subscribed to one of your feeds", {"type": "3"});
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
    const { feedId, text, images } = data;
    await db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("posts").add({
      text,
      images,
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
    //update feed 'updatedAt' field
    const feedRef = db.collection("users").doc(userId).collection("feeds").doc(feedId);
    batch.update(feedRef, {
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    writeCount++;
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
        feedPostObj.user = await getUser(feedPostObj.userId);
        cachedUsers.push(feedPostObj.user);
      }
      results.push(feedPostObj);
    }
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});

exports.getSubscriptions = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const { uid } = data;
    const subscriptions = await db.collection("users").doc(uid).collection("subscriptions").get();
    const results = [];
    for (const subscription of subscriptions.docs) {
      const userId = subscription.data().userId || null;
      if (!userId) {
        continue;
      }
      const feed = await getFeed(userId, subscription.id, false, false, true);
      results.push(feed);
    }
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});

exports.top10MostSubscribedFeeds = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    // Fetch the top 10 most subscribed feeds
    const subRefs = await db.collectionGroup("subscribers").get();
    const feedIds = [];
    for (const subRef of subRefs.docs) {
      const feedId = subRef.ref.parent.parent.id;
      if (feedIds.includes(feedId)) {
        continue;
      }
      feedIds.push({ feedId, userId: subRef.ref.parent.parent.parent.parent.id });
    }
    
    const feedSubs = {};
    for (const feedId of feedIds) {
      if (feedSubs[feedId.feedId]) {
        feedSubs[feedId.feedId].count++;
      } else {
        feedSubs[feedId.feedId] = { count: 1, userId: feedId.userId };
      }
    }

    const feedSubsArr = [];
    for (const feedId in feedSubs) {
      feedSubsArr.push({ feedId, ...feedSubs[feedId] });
    }

    feedSubsArr.sort((a, b) => b.count - a.count);

    const results = [];
    for (let i = 0; i < 10; i++) {
      const feedSub = feedSubsArr[i];
      if (!feedSub) {
        break;
      }
      const feed = await getFeed(feedSub.userId, feedSub.feedId, false, true, true);
      if (feed != null) {
        results.push(feed);
      }
    }
    
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});

exports.recentlyAddedFeeds = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const feeds = await db.collectionGroup("feeds").get();
    feeds.docs.sort((a, b) => b.data().createdAt - a.data().createdAt);
    const results = [];
    for (let i = 0; i < 10; i++) {
      const feed = feeds.docs[i];
      const feedObj = await getFeed(feed.ref.parent.parent.id, feed.id, false, true, true);
      if (feedObj != null) {
        results.push(feedObj);
      } else {
        i--;
      }
    }
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});
