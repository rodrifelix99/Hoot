import { auth } from "firebase-functions/v1";
import { FieldValue } from "firebase-admin/firestore";
import { db } from "../config";

export const onAuthUserDeleted = auth.user().onDelete(async (user) => {
  const uid = user.uid;

  // Remove the main user document if it still exists.
  await db.collection("users").doc(uid).delete().catch(() => undefined);

  // Helper to commit batched deletes/updates (max 400 operations).
  async function commitBatches(
    refs: FirebaseFirestore.DocumentReference[],
    update?: (
      batch: FirebaseFirestore.WriteBatch,
      ref: FirebaseFirestore.DocumentReference
    ) => void
  ) {
    const batches: FirebaseFirestore.WriteBatch[] = [];
    let batch = db.batch();
    let count = 0;
    for (const ref of refs) {
      update ? update(batch, ref) : batch.delete(ref);
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

  // Delete all posts created by the user.
  const postsSnap = await db
    .collection("posts")
    .where("userId", "==", uid)
    .get();
  await commitBatches(postsSnap.docs.map((d) => d.ref));

  // Delete notifications belonging to the user.
  const notifsSnap = await db
    .collection("users")
    .doc(uid)
    .collection("notifications")
    .get();
  await commitBatches(notifsSnap.docs.map((d) => d.ref));

  // Remove subscriptions from user profile and feeds.
  const subsSnap = await db
    .collection("users")
    .doc(uid)
    .collection("subscriptions")
    .get();

  const batches: FirebaseFirestore.WriteBatch[] = [];
  let batch = db.batch();
  let count = 0;
  for (const doc of subsSnap.docs) {
    const feedId = doc.id;
    batch.delete(doc.ref);
    batch.delete(db.collection("feeds").doc(feedId).collection("subscribers").doc(uid));
    batch.update(db.collection("feeds").doc(feedId), {
      subscriberCount: FieldValue.increment(-1),
    });
    count += 3;
    if (count >= 400) {
      batches.push(batch);
      batch = db.batch();
      count = 0;
    }
  }
  if (count > 0) batches.push(batch);
  for (const b of batches) {
    await b.commit();
  }

  // EU GDPR: ensure complete personal data removal after account deletion.
});
