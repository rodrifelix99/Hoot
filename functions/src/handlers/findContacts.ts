import { functions, db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const findContacts = functions.region("europe-west1").https.onCall(async (data, context) => {
  try {
    const { uid, contacts } = data;
    const results = [];
    for (const contact of contacts) {
      const user = await admin.auth().getUserByPhoneNumber(contact.phoneNumber);
      if (user.uid != uid && !results.find((result) => result.uid === user.uid)) {
        const userObj = await getUser(user.uid, false);
        if (!userObj) {
          continue;
        }
        results.push(userObj);
      }
    }
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});
