import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const getSubscriptionsCount = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const { uid } = data;
    const subscriptions = await db.collection("users").doc(uid).collection("subscriptions").get();
    return subscriptions.size;
  } catch (e) {
    error(e);
  }
});
