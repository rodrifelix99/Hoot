import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const subscribeToFeed = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { feedId, userId } = data;
    let batch = db.batch();
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
