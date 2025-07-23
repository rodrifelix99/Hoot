import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const onDeletePost = functions.region("europe-west1").firestore.document("users/{userId}/feeds/{feedId}/posts/{postId}").onDelete(async (snap, context) => {
  try {
    const { userId, feedId, postId } = context.params;
    const feedSubscribers = await db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("subscribers").get();
    let batch = db.batch();
    let writeCount = 0;
    for (const feedSubscriber of feedSubscribers.docs) {
      const feedPostRef = db.collection("users").doc(feedSubscriber.id).collection("mainFeed").doc(postId);
      writeCount++;
      if (writeCount > 499) {
        await batch.commit();
        batch = db.batch();
        writeCount = 0;
      }
      batch.delete(feedPostRef);
    }
    await batch.commit();
  } catch (e) {
    error(e);
  }
});
