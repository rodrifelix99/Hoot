import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const deletePost = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    const { feedId, postId } = data;
    // get post and check if reFeededFrom has a reference to another document
    const post = await db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("posts").doc(postId).get();
    const reFeededFrom = post.data().reFeededFrom;
    if (reFeededFrom) {
      // reFeededFrom is the path string to the original post
      const userid = reFeededFrom.split("/")[1];
      const feedid = reFeededFrom.split("/")[3];
      const postid = reFeededFrom.split("/")[5];
      await db.collection("users").doc(userid).collection("feeds").doc(feedid).collection("posts").doc(postid).collection("reFeeds").doc(uid).delete();
    }
    // delete the post
    await db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("posts").doc(postId).delete();
    return true;
  } catch (e) {
    error(e);
  }
});
