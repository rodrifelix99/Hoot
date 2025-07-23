import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const top10MostSubscribedFeeds = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    // Fetch the top 10 most subscribed feeds
    const subRefs = await db.collectionGroup("subscribers").get();
    const feedIds = [];
    for (const subRef of subRefs.docs) {
      const feedId = subRef.ref.parent.parent.id;
      if (feedIds.includes(feedId)) {
        continue;
      }
      feedIds.push({ feedId, userId: subRef.ref.parent.parent.parent.parent.id });
    }
    
    const feedSubs = {};
    for (const feedId of feedIds) {
      if (feedSubs[feedId.feedId]) {
        feedSubs[feedId.feedId].count++;
      } else {
        feedSubs[feedId.feedId] = { count: 1, userId: feedId.userId };
      }
    }

    const feedSubsArr = [];
    for (const feedId in feedSubs) {
      feedSubsArr.push({ feedId, ...feedSubs[feedId] });
    }

    feedSubsArr.sort((a, b) => b.count - a.count);

    const results = [];
    for (let i = 0; i < 10; i++) {
      const feedSub = feedSubsArr[i];
      if (!feedSub) {
        break;
      }
      const feed = await getFeedObject(feedSub.userId, feedSub.feedId, false, true, true);
      if (feed != null) {
        results.push(feed);
      }
    }
    
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});
