import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const getLikes = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const { userId, feedId, postId, startAfter } = data;
    const startAfterTimestamp = startAfter ? admin.firestore.Timestamp.fromDate(new Date(startAfter)) : admin.firestore.Timestamp.fromDate(new Date());
    const likes = await db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("posts").doc(postId).collection("likes").orderBy("createdAt", "desc").startAfter(startAfterTimestamp).limit(10).get();
    const results = [];
    for (const like of likes.docs) {
      const likeObj = await getUser(like.id, false);
      if (!likeObj) {
        continue;
      }
      results.push(likeObj);
    }
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});
