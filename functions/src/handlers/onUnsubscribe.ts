import { onDocumentDeleted } from 'firebase-functions/v2/firestore';
import { error } from '../common';

// Without duplicated posts there is nothing to clean up when a user unsubscribes.
export const onUnsubscribe = onDocumentDeleted(
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
