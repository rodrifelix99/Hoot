import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const searchFeedsByType = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const { type, startAtId } = data;
    let feeds;
    if(startAtId == 'first') {
      feeds = await db.collectionGroup("feeds").where("type", "==", type).orderBy("createdAt", "desc").limit(10).get();
    } else {
      feeds = await db.collectionGroup("feeds").where("type", "==", type).orderBy("createdAt", "desc").startAt(startAtId).limit(10).get();
    }
    const results = [];
    for (const feed of feeds.docs) {
      const feedObj = await getFeedObject(feed.ref.parent.parent.id, feed.id, false, true, true);
      if (feedObj != null) {
        results.push(feedObj);
      }
    }
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});
