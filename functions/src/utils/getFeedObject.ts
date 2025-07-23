import { db, error } from '../common';
import { getUser } from './getUser';

export async function getFeedObject(uid: string, feedId: string, requests = false, listSubscriberIds = false, addUserObj = false): Promise<any | null> {
  try {
    const doc = await db.collection('users').doc(uid).collection('feeds').doc(feedId).get();
    if (doc.exists) {
      const feed: any = doc.data();
      feed.id = doc.id;
      if (listSubscriberIds) {
        const subscribersSnapshot = await db.collection('users').doc(uid).collection('feeds').doc(feedId).collection('subscribers').get();
        feed.subscribers = subscribersSnapshot.docs.map((subscriber) => subscriber.id);
      }
      if (requests) {
        const requestsSnapshot = await db.collection('users').doc(uid).collection('feeds').doc(feedId).collection('requests').get();
        feed.requests = requestsSnapshot.docs.map((request) => request.id);
      }
      if (addUserObj) {
        feed.user = await getUser(uid, true);
        if (feed.user === null) {
          return null;
        }
      }
      return feed;
    }
    return null;
  } catch (e) {
    error(e);
  }
  return null;
}
