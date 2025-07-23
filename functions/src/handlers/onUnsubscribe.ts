import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const onUnsubscribe = functions.region("europe-west1").firestore.document("users/{userId}/feeds/{feedId}/subscribers/{subscribedId}").onDelete(async (snap, context) => {
  try {
    const { subscribedId, userId, feedId } = context.params;
    const feedPosts = await db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("posts").get();
    let batch = db.batch();
    let writeCount = 0;
    for (const feedPost of feedPosts.docs) {
      const feedPostRef = db.collection("users").doc(subscribedId).collection("mainFeed").doc(feedPost.id);
      writeCount++;
      if (writeCount > 499) {
        await batch.commit();
        batch = db.batch();
        writeCount = 0;
      } else {
        batch.delete(feedPostRef);
      }
    }
    await batch.commit();
  } catch (e) {
    error(e);
  }
});
