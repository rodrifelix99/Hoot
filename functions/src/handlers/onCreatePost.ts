import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { db, admin, error } from '../common';

// Previously this trigger duplicated every new post to each subscriber's
// `mainFeed` collection which caused a large amount of duplicated data.
// The refactored version simply updates the parent feed timestamp so that
// clients can still detect changes without storing the extra copies.
export const onCreatePost = onDocumentCreated(
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
