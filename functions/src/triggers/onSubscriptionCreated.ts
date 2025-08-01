import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { FieldValue } from "firebase-admin/firestore";
import { db } from "../config";

export const onSubscriptionCreated = onDocumentCreated(
  "feeds/{feedId}/subscribers/{userId}",
  async (event) => {
    const { feedId, userId } = event.params;
    const feedSnap = await db.collection("feeds").doc(feedId).get();
    if (!feedSnap.exists) return;
    const ownerId = feedSnap.get("userId");
    if (ownerId === userId) return;
    const userSnap = await db.collection("users").doc(userId).get();
    const userData = userSnap.data();
    if (!userData) return;
    userData["uid"] = userId;
    const feedData = feedSnap.data();
    if (feedData) feedData["id"] = feedId;
    await db
      .collection("users")
      .doc(ownerId)
      .collection("notifications")
      .add({
        user: userData,
        ...(feedData ? { feed: feedData } : {}),
        type: 3,
        read: false,
        createdAt: FieldValue.serverTimestamp(),
      });
    await db
      .collection("users")
      .doc(ownerId)
      .update({ popularityScore: FieldValue.increment(1) });
  }
);
