import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const top5MostPopularTypes = onCall({ region: 'europe-west1' }, async (request) => {
  try {
    const feeds = await db.collectionGroup("feeds").get();
    const feedTypes = {};
    for (const feed of feeds.docs) {
      const feedType = feed.data().type;
      if (feedTypes[feedType]) {
        feedTypes[feedType].count++;
      } else {
        feedTypes[feedType] = { count: 1 };
      }
    }
    const feedTypesArr = [];
    for (const feedType in feedTypes) {
      feedTypesArr.push({ feedType, ...feedTypes[feedType] });
    }
    feedTypesArr.sort((a, b) => b.count - a.count);
    const results = [];
    for (let i = 0; i < 5; i++) {
      const feedType = feedTypesArr[i];
      if (!feedType) {
        break;
      }
      results.push(feedType.feedType);
    }
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});
