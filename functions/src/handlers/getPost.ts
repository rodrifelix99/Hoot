import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const getPost = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { userId, feedId, postId } = data;
    const post = await getHootObj(uid, userId, feedId, postId);
    return JSON.stringify(post);
  } catch (e) {
    error(e);
  }
});
