import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { db } from "../config";

export const onFeedUpdated = onDocumentWritten(
  "feeds/{feedId}",
  async (event) => {
    const { feedId } = event.params;
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!before || !after) return;

    if (
      before.smallAvatar === after.smallAvatar &&
      before.bigAvatar === after.bigAvatar
    ) {
      return;
    }

    const feedData = { ...after, id: feedId };
    const postsSnapshot = await db
      .collection("posts")
      .where("feedId", "==", feedId)
      .get();

    const batches = [] as FirebaseFirestore.WriteBatch[];
    let batch = db.batch();
    let count = 0;
    for (const doc of postsSnapshot.docs) {
      batch.update(doc.ref, { feed: feedData });
      count++;
      if (count === 400) {
        batches.push(batch);
        batch = db.batch();
        count = 0;
      }
    }
    if (count > 0) batches.push(batch);
    for (const b of batches) {
      await b.commit();
    }
  }
);
