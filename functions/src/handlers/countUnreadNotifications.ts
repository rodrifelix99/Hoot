import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const countUnreadNotifications = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const uid = context.auth.uid;
    const notifications = await db.collection("users").doc(uid).collection("notifications").where("read", "==", false).get();
    return notifications.size;
  } catch (e) {
    error(e);
  }
});
