import { db, error } from '../common';

export async function getUser(uid: string, addSubscribed = true, built: any = null): Promise<any | null> {
  try {
    if (built !== null) {
      const user: any = built;
      user.uid = uid;
      const subscribedSnapshot = await db.collection('users').doc(uid).collection('subscriptions').get();
      user.subscriptions = subscribedSnapshot.docs.map((subscription) => subscription.id);
      return user;
    } else {
      const doc = await db.collection('users').doc(uid).get();
      if (doc.exists) {
        const user: any = doc.data();
        user.uid = doc.id;
        if (addSubscribed) {
          const subscribedSnapshot = await db.collection('users').doc(uid).collection('subscriptions').get();
          user.subscriptions = subscribedSnapshot.docs.map((subscription) => subscription.id);
        }
        return user;
      } else {
        return null;
      }
    }
  } catch (e) {
    error(e);
  }
  return null;
}
