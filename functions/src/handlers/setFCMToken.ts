import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const setFCMToken = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const token = data;
    await db.collection("users").doc(context.auth.uid).update({
      fcmToken: token,
    });
    return true;
  } catch (e) {
    error(e);
  }
});
