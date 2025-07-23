import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const getSubscriptions = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
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
