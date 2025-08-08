import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { FieldValue } from "firebase-admin/firestore";
import { db } from "../config";
import { updateStreak } from "../utils/updateStreak";

export const onCommentCreated = onDocumentCreated(
  "posts/{postId}/comments/{commentId}",
  async (event) => {
    const { postId } = event.params;
    const comment = event.data?.data();
    if (!comment) return;
    const userId = comment.userId;
    const user = comment.user;
    const text = comment.text as string | undefined;
    const postSnap = await db.collection("posts").doc(postId).get();
    if (!postSnap.exists) return;
    const ownerId = postSnap.get("userId");
    const feedData = postSnap.data()?.feed;
    if (ownerId && ownerId !== userId) {
      await db
        .collection("users")
        .doc(ownerId)
        .collection("notifications")
        .add({
          user,
          ...(feedData ? { feed: feedData } : {}),
          postId,
          type: 1,
          read: false,
          createdAt: FieldValue.serverTimestamp(),
        });
    }
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
            ...(feedData ? { feed: feedData } : {}),
            postId,
            type: 2,
            read: false,
            createdAt: FieldValue.serverTimestamp(),
          });
      }
    }
    if (ownerId) {
      await db
        .collection("users")
        .doc(ownerId)
        .update({ popularityScore: FieldValue.increment(1) });
    }
    await db
      .collection("users")
      .doc(userId)
      .update({ activityScore: FieldValue.increment(1) });
    await updateStreak(userId);
  }
);
