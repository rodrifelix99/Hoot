import { db } from "../config";
import { FieldValue, Timestamp } from "firebase-admin/firestore";

export async function updateStreak(userId: string) {
  await db.runTransaction(async (tx) => {
    const ref = db.collection("users").doc(userId);
    const snap = await tx.get(ref);
    if (!snap.exists) return;

    const lastAction = snap.get("lastActionAt") as Timestamp | undefined;
    const lastActionDate = lastAction?.toDate();
    const now = new Date();
    const startOfToday = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
    const startOfYesterday = new Date(startOfToday);
    startOfYesterday.setUTCDate(startOfYesterday.getUTCDate() - 1);
    let streak = (snap.get("streakCount") as number) || 0;
    if (!lastActionDate || lastActionDate < startOfToday) {
      if (lastActionDate && lastActionDate >= startOfYesterday) {
        streak += 1;
      } else {
        streak = 1;
      }
    }
    tx.update(ref, {
      streakCount: streak,
      lastActionAt: FieldValue.serverTimestamp(),
    });
  });
}
