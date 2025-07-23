import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const getRefeeds = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const { userId, feedId, postId, startAfter } = data;
    const startAfterTimestamp = startAfter ? admin.firestore.Timestamp.fromDate(new Date(startAfter)) : admin.firestore.Timestamp.fromDate(new Date());
    const reFeeds = await db.collection("users").doc(userId).collection("feeds").doc(feedId).collection("posts").doc(postId).collection("reFeeds").orderBy("createdAt", "desc").startAfter(startAfterTimestamp).limit(10).get();
    const results = [];
    for (const reFeed of reFeeds.docs) {
      const reFeedObj = await getUser(reFeed.id, false);
      if (!reFeedObj) {
        continue;
      }
      results.push(reFeedObj);
    }
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});
