import { db, error, admin } from '../common';

export async function sendDatabaseNotification(from: string, to: string, type: number, feedAuthor: string | null = null, feedId: string | null = null, postId: string | null = null): Promise<void> {
  try {
    const notification = {
      sender: from,
      feedAuthor: feedAuthor,
      feedId: feedId,
      postId: postId,
      type: type,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    await db.collection('users').doc(to).collection('notifications').add(notification);
  } catch (e) {
    error(e);
  }
}
