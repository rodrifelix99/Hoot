import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const getSubscriptions = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const { uid } = data;
    const subscriptions = await db.collection("users").doc(uid).collection("subscriptions").get();
    const results = [];
    for (const subscription of subscriptions.docs) {
      const userId = subscription.data().userId || null;
      if (!userId) {
        continue;
      }
      const feed = await getFeedObject(userId, subscription.id, false, false, true);
      if (!feed) {
        continue;
      }
      results.push(feed);
    }
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});
