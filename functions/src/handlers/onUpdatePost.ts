import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { db, admin, error } from '../common';

// With posts no longer copied to user feeds there is only a single document to
// update. This trigger updates the feed timestamp when a post changes.
export const onUpdatePost = onDocumentUpdated(
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
