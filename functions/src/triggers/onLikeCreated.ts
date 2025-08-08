import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { FieldValue } from "firebase-admin/firestore";
import { db } from "../config";
import { updateStreak } from "../utils/updateStreak";

export const onLikeCreated = onDocumentCreated(
  "posts/{postId}/likes/{userId}",
  async (event) => {
    const { postId, userId } = event.params;
    const postSnap = await db.collection("posts").doc(postId).get();
    if (!postSnap.exists) return;
    const ownerId = postSnap.get("userId");
    if (ownerId === userId) return;
    const userSnap = await db.collection("users").doc(userId).get();
    const userData = userSnap.data();
    if (!userData) return;
    userData["uid"] = userId;
    const feedData = postSnap.data()?.feed;
    await db
      .collection("users")
      .doc(ownerId)
      .collection("notifications")
      .add({
        user: userData,
        ...(feedData ? { feed: feedData } : {}),
        postId,
        type: 0,
        read: false,
        createdAt: FieldValue.serverTimestamp(),
      });
    await db
      .collection("users")
      .doc(ownerId)
      .update({ popularityScore: FieldValue.increment(1) });
    await updateStreak(userId);
  }
);
