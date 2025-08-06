import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { FieldValue } from "firebase-admin/firestore";
import { db } from "../config";

export const onPostCreated = onDocumentCreated(
  "posts/{postId}",
  async (event) => {
    const { postId } = event.params;
    const post = event.data?.data();
    if (!post) return;

    const userId = post.userId;
    const user = post.user;
    const feed = post.feed;

    // Notify original author when their hoot is reFeeded
    if (post.reFeeded && post.reFeededFrom?.id) {
      const originalId = post.reFeededFrom.id as string;
      const originalSnap = await db.collection("posts").doc(originalId).get();
      if (originalSnap.exists) {
        const ownerId = originalSnap.get("userId");
        if (ownerId && ownerId !== userId) {
          await db
            .collection("users")
            .doc(ownerId)
            .collection("notifications")
            .add({
              user,
              ...(feed ? { feed } : {}),
              postId: originalId,
              type: 4,
              read: false,
              createdAt: FieldValue.serverTimestamp(),
            });
        }
      }
    }

    const text = post.text as string | undefined;
    if (text && text.includes("@")) {
      const regex = /@([A-Za-z0-9_]+)/g;
      let match;
      while ((match = regex.exec(text)) !== null) {
        const username = match[1];
        const userQuery = await db
          .collection("users")
          .where("username", "==", username)
          .limit(1)
          .get();
        if (userQuery.empty) continue;
        const targetId = userQuery.docs[0].id;
        if (targetId === userId) continue;
        await db
          .collection("users")
          .doc(targetId)
          .collection("notifications")
          .add({
            user,
            ...(feed ? { feed } : {}),
            postId,
            type: 2,
            read: false,
            createdAt: FieldValue.serverTimestamp(),
          });
      }
    }
    const updates: Record<string, unknown> = {
      activityScore: FieldValue.increment(1),
    };

    if (post.challengeId) {
      updates.challengeCount = FieldValue.increment(1);
    }

    await db.collection("users").doc(userId).update(updates);
  }
);
