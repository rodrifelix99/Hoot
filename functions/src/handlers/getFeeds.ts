import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const getFeeds = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const { uid } = data;
    const feeds = await db.collection("users").doc(uid).collection("feeds").orderBy("updatedAt", "desc").get();
    const results = [];
    for (const feed of feeds.docs) {
      const feedObj = await getFeedObject(uid, feed.id, true, true);
      results.push(feedObj);
    }
    info(results);
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});
