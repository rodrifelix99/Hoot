import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const createFeed = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { title, description, icon, color, private: isPrivate, nsfw, type } = data;
    const feed = await db.collection("users").doc(uid).collection("feeds").add({
      title,
      description,
      icon,
      color,
      type,
      private: isPrivate,
      nsfw,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await db.collection("users").doc(uid).collection("feeds").doc(feed.id).collection("subscribers").doc(uid).set({
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await db.collection("users").doc(uid).collection("subscriptions").doc(feed.id).set({
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      userId: uid,
    });
    return feed.id;
  } catch (e) {
    error(e);
  }
});
