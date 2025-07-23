import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const countUnreadNotifications = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const notifications = await db.collection("users").doc(uid).collection("notifications").where("read", "==", false).get();
    return notifications.size;
  } catch (e) {
    error(e);
  }
});
