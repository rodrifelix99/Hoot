import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const searchUsers = functions.region("europe-west1").https.onCall(async (data) => {
  try {
    // query is the search string trimmed and lowercased and remove @
    const query = data.trim().toLowerCase().replace("@", "");
    const users = await db.collection("users").where("username", ">=", query).where("username", "<=", query + "\uf8ff").get();
    const results = [];
    for (const user of users.docs) {
      const userInfo = await getUser(user.id, true, user.data());
      results.push(userInfo);
    }
    return results;
  } catch (e) {
    error(e);
  }
});
