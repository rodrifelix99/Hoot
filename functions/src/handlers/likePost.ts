import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const likePost = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { userId, feedId, postId } = data;
    const likeRef = db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("posts").doc(postId).collection("likes").doc(uid);
    const like = await likeRef.get();
    if (like.exists) {
      await likeRef.delete();
    } else {
      await likeRef.set({ createdAt: admin.firestore.FieldValue.serverTimestamp() });
      if (uid != userId) {
        await sendDatabaseNotification(uid, userId, 8, userId, feedId, postId);
        await sendPush(userId, "New like", "Someone liked your hoot", {
          type: "8",
          userId: userId,
          feedId: feedId,
          postId: postId,
        });
      }
    }
    return true;
  } catch (e) {
    error(e);
    return false;
  }
});
