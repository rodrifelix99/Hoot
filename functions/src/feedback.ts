import { onCall } from "firebase-functions/v2/https";
import { FieldValue } from "firebase-admin/firestore";
import { db } from "./config";

export const submitFeedback = onCall(async (request) => {
  const screenshot = request.data.screenshot as string | undefined;
  const message = request.data.message as string | undefined;
  await db.collection("feedback").add({
    screenshot,
    message,
    userId: request.auth?.uid ?? null,
    createdAt: FieldValue.serverTimestamp(),
  });
  return { success: true };
});
