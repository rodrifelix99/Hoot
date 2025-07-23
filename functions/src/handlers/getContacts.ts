import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const getContacts = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const contacts = data;
    const users = await admin.auth().listUsers();
    const results = [];
    for (const user of users.users) {
      // check if there's a contact and if it has a phoneNumber property that includes the user's phone number
      if (contacts.find(contact => contact.includes(user.phoneNumber)) && context.auth.uid !== user.uid) {
        const userInfo = await getUser(user.uid, true);
        userInfo.phoneNumber = user.phoneNumber;
        results.push(userInfo);
      }
    }
    return results;
  } catch (e) {
    error(e);
  }
});
