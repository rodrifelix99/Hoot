import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const requestPrivateFeed = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { feedId, userId } = data;
    await db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("requests").doc(uid).set({
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await sendDatabaseNotification(uid, userId, 5, userId, feedId);
    await sendPush(userId, "New feed request", "Someone wants to subscribe your private feed");
    return true;
  } catch (e) {
    error(e);
  }
});
