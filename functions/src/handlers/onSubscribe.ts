import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { error } from '../common';

// In the simplified architecture there is no need to copy existing posts to the
// subscriber's `mainFeed` collection. The client now queries the original posts
// directly, so this trigger does nothing.
export const onSubscribe = onDocumentCreated(
  { document: 'users/{userId}/feeds/{feedId}/subscribers/{subscribedId}', region: 'europe-west1' },
  async () => {
    try {
      // Intentionally left blank.
      return;
    } catch (e) {
      error(e);
    }
  },
);
