import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const blockUser = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const uid = context.auth.uid;
    const { blockedUserId } = data;
    const blockedRef = db.collection("users").doc(uid).collection("blocked").doc(blockedUserId);
    const blocked = await blockedRef.get();
    if (blocked.exists) {
      await blockedRef.delete();
    } else {
      // unsubscribe from all feeds of blocked user
      const subscriptions = await db.collection("users").doc(blockedUserId).collection("subscriptions").get();
      let batch = db.batch();
      for (const subscription of subscriptions.docs) {
        const subscribedRef = db.collection("users").doc(blockedUserId).collection("feeds").doc(subscription.id).collection("subscribers").doc(uid);
        batch.delete(subscribedRef);
        const userSubscribedRef = db.collection("users").doc(uid).collection("subscriptions").doc(subscription.id);
        batch.delete(userSubscribedRef);
      }
      await batch.commit();
      await blockedRef.set({ createdAt: admin.firestore.FieldValue.serverTimestamp() });
    }
    return true;
  } catch (e) {
    error(e);
    return false;
  }
});
