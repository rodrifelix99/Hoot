import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const updateUser = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const info = JSON.parse(data);
    info.updatedAt = admin.firestore.FieldValue.serverTimestamp();
    await db.collection("users").doc(context.auth.uid).update(info);
    await admin.auth().updateUser(context.auth.uid, {
      displayName: data.displayName,
      photoURL: data.bigAvatar,
    });
    return true;
  } catch (e) {
    error(e);
  }
});
