import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const acceptFeedRequest = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { feedId, userId } = data;
    let batch = db.batch();
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
