import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const unsubscribeFromFeed = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { feedId, userId } = data;
    let batch = db.batch();
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
