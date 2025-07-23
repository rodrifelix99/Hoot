import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const editFeed = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const uid = context.auth.uid;
    const { feedId, title, description, icon, color, private: isPrivate, nsfw, type } = data;
    const ref = db.collection("users").doc(uid).collection("feeds").doc(feedId);
    await ref.update({
      title,
      description,
      icon,
      color,
      type,
      private: isPrivate,
      nsfw
    });
    return true;
  } catch (e) {
    error(e);
  }
});
