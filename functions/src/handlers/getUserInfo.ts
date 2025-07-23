import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const getUserInfo = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
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
