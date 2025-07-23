import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const refeedPost = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { userId, feedId, postId, chosenFeedId, text, images } = data;
    const reFeedRef = db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("posts").doc(postId).collection("reFeeds").doc(uid);
    const reFeed = await reFeedRef.get();
    if (!reFeed.exists) {
      const feedPost = db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("posts").doc(postId);
      const post = await db.collection("users").doc(uid).collection("feeds").doc(chosenFeedId).collection("posts").add({
        text,
        images,
        reFeededFrom: feedPost.path,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      await reFeedRef.set({ 
        pathToPost: post.path,
        createdAt: admin.firestore.FieldValue.serverTimestamp() 
      });
      if (uid != userId) {
        await sendDatabaseNotification(uid, userId, 9, uid, chosenFeedId, post.id);
        await sendPush(userId, "ReFeed", "Someone reFeeded your hoot", {
          type: "9",
          userId: uid,
          feedId: chosenFeedId,
          postId: post.id,
        });
      }
    }
    return true;
  } catch (e) {
    error(e);
    return false;
  }
});
