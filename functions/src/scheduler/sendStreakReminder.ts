import { onSchedule } from "firebase-functions/v2/scheduler";
import { FieldValue } from "firebase-admin/firestore";
import { db } from "../config";

export const sendStreakReminder = onSchedule("0 18 * * *", async () => {
  const today = new Date();
  today.setUTCHours(0, 0, 0, 0);
  const snapshot = await db
    .collection("users")
    .where("lastActionAt", "<", today)
    .get();
  const writes = snapshot.docs.map((doc) =>
    db
      .collection("users")
      .doc(doc.id)
      .collection("notifications")
      .add({
        type: 9,
        read: false,
        createdAt: FieldValue.serverTimestamp(),
      })
  );
  await Promise.all(writes);
});
