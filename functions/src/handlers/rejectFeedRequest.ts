import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const rejectFeedRequest = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { feedId, userId } = data;
    await db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("requests").doc(userId).delete();
    await sendDatabaseNotification(uid, userId, 7, uid, feedId);
    await sendPush(userId, "Feed request rejected", "Your request to subscribe a private feed was rejected");
    return true;
  } catch (e) {
    error(e);
  }
});
