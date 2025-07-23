import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const onUpdatePost = functions.region("europe-west1").firestore.document("users/{userId}/feeds/{feedId}/posts/{postId}").onUpdate(async (change, context) => {
  try {
    const { userId, feedId, postId } = context.params;
    const feedSubscribers = await db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("subscribers").get();
    let batch = db.batch();
    let writeCount = 0;
    //update feed 'updatedAt' field
    const feedRef = db.collection("users").doc(userId).collection("feeds").doc(feedId);
    batch.update(feedRef, {
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    writeCount++;
    for (const feedSubscriber of feedSubscribers.docs) {
      const feedPostRef = db.collection("users").doc(feedSubscriber.id).collection("mainFeed").doc(postId);
      writeCount++;
      if (writeCount > 499) {
        await batch.commit();
        batch = db.batch();
        writeCount = 0;
      }
      batch.update(feedPostRef, {
        ...change.after.data(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  } catch (e) {
    error(e);
  }
});
