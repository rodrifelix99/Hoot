import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const getNotifications = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const uid = context.auth.uid;
    const { startAfter } = data || { startAfter: null };
    let notifications: FirebaseFirestore.QuerySnapshot | null = null;
    if (startAfter) {
      const startAfterTimestamp = admin.firestore.Timestamp.fromDate(new Date(startAfter));
      notifications = await db.collection("users").doc(uid).collection("notifications").orderBy("createdAt", "desc").startAfter(startAfterTimestamp).limit(10).get();
    } else {
      notifications = await db.collection("users").doc(uid).collection("notifications").orderBy("createdAt", "desc").limit(10).get();
    }
    let results: any[] = [];

    if (notifications.size > 0) {
      results = await Promise.all(
        notifications.docs.map(async (doc) => {
          const senderUser = await getUser(doc.data().sender, true);
          if (!senderUser) {
            return null;
          }
          const feed = doc.data().feedId && doc.data().feedAuthor ? await getFeedObject(doc.data().feedAuthor, doc.data().feedId) : null;
          return {
            id: doc.id,
            user: senderUser,
            feed: feed,
            ...doc.data(),
          };
        })
      );
    }
    results = results.filter((x) => x !== null);
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});
