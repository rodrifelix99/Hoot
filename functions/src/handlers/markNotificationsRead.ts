import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const markNotificationsRead = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const uid = context.auth.uid;
    let batch = db.batch();
    const notifications = await db.collection("users").doc(uid).collection("notifications").where("read", "==", false).get();
    for (const notification of notifications.docs) {
      const ref = db.collection("users").doc(uid).collection("notifications").doc(notification.id);
      batch.update(ref, {read: true});
    }
    await batch.commit();
    return true;
  } catch (e) {
    error(e);
  }
});
