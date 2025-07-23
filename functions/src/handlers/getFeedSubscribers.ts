import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const getFeedSubscribers = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const { feedId } = data;
    const uid = context.auth.uid;
    const subscribers = await db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("subscribers").get();
    const results = [];
    for (const subscriber of subscribers.docs) {
      const subscriberObj = await getUser(subscriber.id, false);
      if (!subscriberObj) {
        continue;
      }
      results.push(subscriberObj);
    }
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});
