import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const createPost = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const uid = context.auth.uid;
    const { feedId, text, images } = data;
    await db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("posts").add({
      text,
      images,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return true;
  } catch (e) {
    error(e);
  }
});
