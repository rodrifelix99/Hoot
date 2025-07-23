import { onCall } from 'firebase-functions/v2/https';
import { db, admin, error } from '../common';
import { getUser, getHootObj } from '../utils';
export const getMainFeedPosts = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const uid = context.auth.uid;
    let { startAfter } = data || { startAfter: null };
    const startAfterTimestamp = startAfter ? admin.firestore.Timestamp.fromDate(new Date(startAfter)) : admin.firestore.Timestamp.fromDate(new Date());
    const subscriptions = await db.collection('users').doc(uid).collection('subscriptions').get();
    const aggregated: any[] = [];
    for (const sub of subscriptions.docs) {
      const feedUserId = sub.data().userId;
      if (!feedUserId) {
        continue;
      }
      const posts = await db
        .collection('users')
        .doc(feedUserId)
        .collection('feeds')
        .doc(sub.id)
        .collection('posts')
        .orderBy('createdAt', 'desc')
        .startAfter(startAfterTimestamp)
        .limit(10)
        .get();
      for (const p of posts.docs) {
        const obj = p.data();
        obj.id = p.id;
        obj.feedId = sub.id;
        obj.userId = feedUserId;
        aggregated.push(obj);
      }
    }

    aggregated.sort((a, b) => b.createdAt.toMillis() - a.createdAt.toMillis());
    const selected = aggregated.slice(0, 10);

    const results: any[] = [];

    const cachedUsers: any[] = [];
    const cachedFeeds: any[] = [];

    for (const feedPostObj of selected) {
      if (cachedFeeds.find((feed) => feed.id === feedPostObj.feedId)) {
        feedPostObj.feed = cachedFeeds.find((feed) => feed.id === feedPostObj.feedId);
      } else {
        const feedDoc = await db.collection("users").doc(feedPostObj.userId).collection("feeds").doc(feedPostObj.feedId).get();
        if (!feedDoc.exists) {
          continue;
        }
        feedPostObj.feed = feedDoc.data();
        feedPostObj.feed.id = feedPostObj.feedId;
        cachedFeeds.push(feedPostObj.feed);
      }
      if (cachedUsers.find((user) => user.uid === feedPostObj.userId)) {
        feedPostObj.user = cachedUsers.find((user) => user.uid === feedPostObj.userId);
      } else {
        feedPostObj.user = await getUser(feedPostObj.userId);
        if (!feedPostObj.user) {
          continue;
        }
        cachedUsers.push(feedPostObj.user);
      }
      const liked = await db
        .collection('users')
        .doc(feedPostObj.userId)
        .collection('feeds')
        .doc(feedPostObj.feedId)
        .collection('posts')
        .doc(feedPostObj.id)
        .collection('likes')
        .doc(uid)
        .get();
      feedPostObj.liked = liked.exists;
      const likeCount = await db
        .collection('users')
        .doc(feedPostObj.userId)
        .collection('feeds')
        .doc(feedPostObj.feedId)
        .collection('posts')
        .doc(feedPostObj.id)
        .collection('likes')
        .get();
      feedPostObj.likes = likeCount.size || 0;
      const reFeeded = await db
        .collection('users')
        .doc(feedPostObj.userId)
        .collection('feeds')
        .doc(feedPostObj.feedId)
        .collection('posts')
        .doc(feedPostObj.id)
        .collection('reFeeds')
        .doc(uid)
        .get();
      feedPostObj.reFeeded = reFeeded.exists;
      const reFeedCount = await db
        .collection('users')
        .doc(feedPostObj.userId)
        .collection('feeds')
        .doc(feedPostObj.feedId)
        .collection('posts')
        .doc(feedPostObj.id)
        .collection('reFeeds')
        .get();
      feedPostObj.reFeeds = reFeedCount.size || 0;
      const commentCount = await db
        .collection('users')
        .doc(feedPostObj.userId)
        .collection('feeds')
        .doc(feedPostObj.feedId)
        .collection('posts')
        .doc(feedPostObj.id)
        .collection('comments')
        .get();
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
