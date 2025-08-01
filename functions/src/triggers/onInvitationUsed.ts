import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { FieldValue } from "firebase-admin/firestore";
import { db } from "../config";

export const onInvitationUsed = onDocumentWritten(
  "users/{userId}",
  async (event) => {
    const { userId } = event.params;
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!after) return;

    if (!before?.invitedBy && after.invitedBy) {
      const inviterId = after.invitedBy as string;
      const userData = { ...after, uid: userId };
      await db
        .collection("users")
        .doc(inviterId)
        .collection("notifications")
        .add({
          user: userData,
          type: 5,
          read: false,
          createdAt: FieldValue.serverTimestamp(),
        });
    }
  }
);
