import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const isUsernameAvailable = functions.region("europe-west1").https.onCall(async (data) => {
  try {
    const username = data;
    const user = await db.collection("users").where("username", "==", username).get();
    info(user.empty + " " + username);
    return user.empty;
  } catch (e) {
    error(e);
  }
});
