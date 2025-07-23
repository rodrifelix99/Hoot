import { onDocumentDeleted } from 'firebase-functions/v2/firestore';
import { db, admin, error } from '../common';

// Old implementation removed duplicated posts from each subscriber's `mainFeed`.
// The new architecture stores posts only once so this trigger simply updates the
// parent feed timestamp for consistency.
export const onDeletePost = onDocumentDeleted(
  { document: 'users/{userId}/feeds/{feedId}/posts/{postId}', region: 'europe-west1' },
  async (event) => {
    const { userId, feedId } = event.params;
    try {
      const feedRef = db.collection('users').doc(userId).collection('feeds').doc(feedId);
      await feedRef.update({
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      error(e);
    }
  },
);
