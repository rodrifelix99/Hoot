import { onCall } from 'firebase-functions/v2/https';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const getFeedRequests = onCall({ region: 'europe-west1' }, async (request) => {
  const data = request.data;
  const context = request;
  try {
    const uid = context.auth.uid;
    const { feedId } = data;
    const requests = await db.collection("users").doc(uid).collection("feeds").doc(feedId).collection("requests").get();
    const results = [];
    for (const request of requests.docs) {
      const requestObj = await getUser(request.id, false);
      if (!requestObj) {
        continue;
      }
      results.push(requestObj);
    }
    return JSON.stringify(results);
  } catch (e) {
    error(e);
  }
});
