import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const getSuggestedUsers = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const uid = context.auth.uid;
    const users = await db.collection("users").where("username", "!=", null).limit(10).get();
    const results = [];
    for (const user of users.docs) {
      if (user.id !== uid) {
        results.push(await getUser(user.id, true, user.data()));
      }
    }
    return results;
  } catch (e) {
    error(e);
  }
});
