import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const listBlockedUsers = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const uid = context.auth.uid;
    const { startAfter } = data;
    const startAfterTimestamp = startAfter ? admin.firestore.Timestamp.fromDate(new Date(startAfter)) : admin.firestore.Timestamp.fromDate(new Date());
    const blocked = await db.collection("users").doc(uid).collection("blocked").orderBy("createdAt", "desc").startAfter(startAfterTimestamp).limit(10).get();
    const results = [];
    for (const block of blocked.docs) {
      const user = await getUser(block.id, false);
      if (!user) {
        continue;
      }
      results.push(user);
    }
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});
