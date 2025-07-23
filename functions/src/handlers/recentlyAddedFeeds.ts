import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const recentlyAddedFeeds = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const feeds = await db.collectionGroup("feeds").get();
    feeds.docs.sort((a, b) => b.data().createdAt - a.data().createdAt);
    const results = [];
    for (let i = 0; i < 10; i++) {
      const feed = feeds.docs[i];
      if (!feed || !feed.data().createdAt) {
        continue;
      }
      const feedObj = await getFeedObject(feed.ref.parent.parent.id, feed.id, false, true, true);
      if (feedObj != null) {
        results.push(feedObj);
      } else {
        i--;
      }
    }
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});
