import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const getSubscriptionsCount = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const { uid } = data;
    const subscriptions = await db.collection("users").doc(uid).collection("subscriptions").get();
    return subscriptions.size;
  } catch (e) {
    error(e);
  }
});
