import { db, error } from '../common';
import { getUser } from './getUser';
import { getFeedObject } from './getFeedObject';

export async function getHootObj(
  uid: string,
  userId: string,
  feedId: string,
  postId: string,
  addUserObj = true,
  addFeedObj = true,
  addComments = true,
  addLikes = true,
  addReFeeds = true,
  addReFeedObj = true
): Promise<any | null> {
  try {
    const doc = await db.collection('users').doc(userId).collection('feeds').doc(feedId).collection('posts').doc(postId).get();
    if (!doc.exists) {
      return null;
    }
    const post: any = doc.data();
    post.id = doc.id;
    post.userId = userId;
    post.feedId = feedId;
    if (addUserObj) {
      post.user = await getUser(userId, true);
      if (post.user === null) return null;
    }
    if (addFeedObj) {
      post.feed = await getFeedObject(userId, feedId, false, false, false);
    }
    if (addLikes) {
      const liked = await db.collection('users').doc(userId).collection('feeds').doc(feedId).collection('posts').doc(postId).collection('likes').doc(uid).get();
      post.liked = liked.exists;
      const likeCount = await db.collection('users').doc(userId).collection('feeds').doc(feedId).collection('posts').doc(postId).collection('likes').get();
      post.likes = likeCount.size || 0;
    }
    if (addReFeeds) {
      const reFeeded = await db.collection('users').doc(userId).collection('feeds').doc(feedId).collection('posts').doc(postId).collection('reFeeds').doc(uid).get();
      post.reFeeded = reFeeded.exists;
      const reFeedCount = await db.collection('users').doc(userId).collection('feeds').doc(feedId).collection('posts').doc(postId).collection('reFeeds').get();
      post.reFeeds = reFeedCount.size || 0;
    }
    if (addComments) {
      const commentCount = await db.collection('users').doc(userId).collection('feeds').doc(feedId).collection('posts').doc(postId).collection('comments').get();
      post.comments = commentCount.size || 0;
    }
    if (addReFeedObj && post.reFeededFrom) {
      const userid = post.reFeededFrom.split('/')[1];
      const feedid = post.reFeededFrom.split('/')[3];
      const postid = post.reFeededFrom.split('/')[5];
      post.reFeededFrom = await getHootObj(userid, userid, feedid, postid, true, false, false, false, false, false);
      post.reFeedError = post.reFeededFrom ? false : true;
    }
    return post;
  } catch (e) {
    error(e);
  }
  return null;
}
