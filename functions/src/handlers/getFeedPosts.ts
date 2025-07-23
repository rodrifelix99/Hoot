import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const getFeedPosts = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    let { startAfter, uid: userId, feedId } = data;
    const startAfterTimestamp = startAfter ? admin.firestore.Timestamp.fromDate(new Date(startAfter)) : admin.firestore.Timestamp.fromDate(new Date());
    const feedPosts = await db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("posts").orderBy("createdAt", "desc").startAfter(startAfterTimestamp).limit(10).get();
    const results = [];
    for (const feedPost of feedPosts.docs) {
      const feedPostObj = feedPost.data();
      feedPostObj.id = feedPost.id;
      const liked = await db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("posts").doc(feedPost.id).collection("likes").doc(uid).get();
      feedPostObj.liked = liked.exists;
      const likeCount = await db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("posts").doc(feedPost.id).collection("likes").get();
      feedPostObj.likes = likeCount.size || 0;
      const refeeded = await db.collection("users").doc(userId).collection("mainFeed").doc(feedPost.id).collection("refeeds").doc(uid).get();
      feedPostObj.refeeded = refeeded.exists;
      const refeedCount = await db.collection("users").doc(userId).collection("mainFeed").doc(feedPost.id).collection("refeeds").get();
      feedPostObj.refeeds = refeedCount.size || 0;
      const commentCount = await db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("posts").doc(feedPost.id).collection("comments").get();
      feedPostObj.comments = commentCount.size || 0;
      if (feedPostObj.reFeededFrom) {
        // reFeededFrom is a path string to the original post
        //separate the path into userId, feedId and postId
        const path = feedPostObj.reFeededFrom.split("/");
        const reFeededFromUserId = path[1];
        const reFeededFromFeedId = path[3];
        const reFeededFromPostId = path[5];
        const isEmptyRefeed = feedPostObj.text === "" && feedPostObj.images.length === 0;
        feedPostObj.reFeededFrom = await getHootObj(uid, reFeededFromUserId, reFeededFromFeedId, reFeededFromPostId, true, isEmptyRefeed, isEmptyRefeed, isEmptyRefeed, isEmptyRefeed, false) || null;
        feedPostObj.reFeedError = feedPostObj.reFeededFrom ? false : true;
      }
      results.push(feedPostObj);
    }
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});
