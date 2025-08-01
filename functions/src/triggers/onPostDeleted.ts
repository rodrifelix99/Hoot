import { onDocumentDeleted } from "firebase-functions/v2/firestore";
import { FieldValue } from "firebase-admin/firestore";
import { db } from "../config";

export const onPostDeleted = onDocumentDeleted(
  "posts/{postId}",
  async (event) => {
    const { postId } = event.params;
    const post = event.data?.data();
    if (!post) return;

    // Delete all posts that reFeed this post
    const reFeedSnap = await db
      .collection("posts")
      .where("reFeededFrom.id", "==", postId)
      .get();

    const batches: FirebaseFirestore.WriteBatch[] = [];
    let batch = db.batch();
    let count = 0;
    for (const doc of reFeedSnap.docs) {
      batch.delete(doc.ref);
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

    // If this post is itself a reFeed, decrement the original's count
    if (post.reFeeded && post.reFeededFrom?.id) {
      const originalId = post.reFeededFrom.id as string;
      const originalRef = db.collection("posts").doc(originalId);
      const originalSnap = await originalRef.get();
      if (originalSnap.exists) {
        await originalRef.update({ reFeeds: FieldValue.increment(-1) });
      }
    }
    await db
      .collection("users")
      .doc(post.userId)
      .update({ activityScore: FieldValue.increment(-1) });
  }
);
