import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const getPost = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const uid = context.auth.uid;
    const { userId, feedId, postId } = data;
    const post = await getHootObj(uid, userId, feedId, postId);
    return JSON.stringify(post);
  } catch (e) {
    error(e);
  }
});
