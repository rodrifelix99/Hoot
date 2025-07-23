import { functionsV1, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const deleteUserDocument = functionsV1.region("europe-west1").auth.user().onDelete(async (u) => {
  try {
    const uid = u.uid;
    let writeCount = 0;
    const user = await db.collection("users").doc(uid).get();
    if (user.exists) {
      let batch = db.batch();
      const feeds = await db.collection("users").doc(uid).collection("feeds").get();
      for (const feed of feeds.docs) {
        const subscribers = await db.collection("users").doc(uid).collection("feeds").doc(feed.id).collection("subscribers").get();
        for (const subscriber of subscribers.docs) {
          const ref = db.collection("users").doc(subscriber.id).collection("subscriptions").doc(feed.id);
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
        const posts = await db.collection("users").doc(uid).collection("feeds").doc(feed.id).collection("posts").get();
        for (const post of posts.docs) {
          const ref = db.collection("users").doc(uid).collection("feeds").doc(feed.id).collection("posts").doc(post.id);
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
        const feedRef = db.collection("users").doc(uid).collection("feeds").doc(feed.id);
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
      const subscriptions = await db.collection("users").doc(uid).collection("subscriptions").get();
      for (const subscription of subscriptions.docs) {
        const ref = db.collection("users").doc(uid).collection("subscriptions").doc(subscription.id);
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
      const notifications = await db.collection("users").doc(uid).collection("notifications").get();
      for (const notification of notifications.docs) {
        const ref = db.collection("users").doc(uid).collection("notifications").doc(notification.id);
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
      const userRef = db.collection("users").doc(uid);
      if (writeCount < 500) {
        batch.delete(userRef);
        writeCount++;
      } else {
        await batch.commit();
        batch = db.batch();
        batch.delete(userRef);
        writeCount = 1;
      }
      await batch.commit();
    }
  } catch (e) {
    error(e);
  }
});
