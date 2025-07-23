import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const deleteFeed = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { feedId } = data;
    let batch = db.batch();
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
