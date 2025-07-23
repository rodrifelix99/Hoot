import { db, error, admin } from '../common';
import { getUser } from './getUser';

export async function sendPush(uid: string, title: string, body: string, data: any = {}, token: string | null = null): Promise<void> {
  try {
    if (!token) {
      const user = await getUser(uid, false);
      if (!user) {
        return;
      }
      token = user.fcmToken;
    }
    if (token) {
      const message = {
        notification: {
          title,
          body,
        },
        data,
        token,
      } as any;
      await admin.messaging().send(message);
    }
  } catch (e) {
    error(e);
  }
}
