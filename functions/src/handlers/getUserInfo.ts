import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const getUserInfo = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const user = await getUser(context.auth.uid, true);
    await db.collection("users").doc(context.auth.uid).update({
      lastOnline: admin.firestore.FieldValue.serverTimestamp(),
    });
    return user;
  } catch (e) {
    error(e);
  }
});
