import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const deleteAccount = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const uid = context.auth.uid;
    await admin.auth().deleteUser(uid);
    return true;
  } catch (e) {
    error(e);
  }
});
