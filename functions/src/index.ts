/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {setGlobalOptions} from "firebase-functions";

import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {
  onDocumentCreated,
  onDocumentDeleted,
  onDocumentWritten,
} from "firebase-functions/v2/firestore";
import {onUserDeleted} from "firebase-functions/v2/auth";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });
initializeApp();
const db = getFirestore();

export const onLikeCreated = onDocumentCreated("posts/{postId}/likes/{userId}", async (event) => {
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
});

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
  }
);

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
    await db
      .collection("users")
      .doc(userId)
      .update({ activityScore: FieldValue.increment(1) });
  }
);

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

export const onUserUpdated = onDocumentWritten(
  "users/{userId}",
  async (event) => {
    const { userId } = event.params;
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!before || !after) return;

    if (
      before.smallAvatar === after.smallAvatar &&
      before.bigAvatar === after.bigAvatar
    ) {
      return;
    }

    const postsSnapshot = await db
      .collection("posts")
      .where("userId", "==", userId)
      .get();

    const batches = [] as FirebaseFirestore.WriteBatch[];
    let batch = db.batch();
    let count = 0;
    for (const doc of postsSnapshot.docs) {
      batch.update(doc.ref, {
        "user.smallAvatar": after.smallAvatar,
        "user.bigAvatar": after.bigAvatar,
      });
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
);

export const onFeedUpdated = onDocumentWritten(
  "feeds/{feedId}",
  async (event) => {
    const { feedId } = event.params;
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!before || !after) return;

    if (
      before.smallAvatar === after.smallAvatar &&
      before.bigAvatar === after.bigAvatar
    ) {
      return;
    }

    const feedData = { ...after, id: feedId };
    const postsSnapshot = await db
      .collection("posts")
      .where("feedId", "==", feedId)
      .get();

    const batches = [] as FirebaseFirestore.WriteBatch[];
    let batch = db.batch();
    let count = 0;
    for (const doc of postsSnapshot.docs) {
      batch.update(doc.ref, { feed: feedData });
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
);

// Triggered when an auth user is deleted.
// EU GDPR: ensure all personal data is erased promptly.
export const onAuthUserDeleted = onUserDeleted(async (event) => {
  const uid = event.data.uid;

  // Remove the main user document if it still exists.
  await db.collection("users").doc(uid).delete().catch(() => undefined);

  // Helper to commit batched deletes/updates (max 400 operations).
  async function commitBatches(
    refs: FirebaseFirestore.DocumentReference[],
    update?: (batch: FirebaseFirestore.WriteBatch, ref: FirebaseFirestore.DocumentReference) => void
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

export const onNotificationCreated = onDocumentCreated(
  "users/{userId}/notifications/{notificationId}",
  async (event) => {
    const { userId } = event.params;
    const data = event.data?.data();
    if (!data) return;

    const appId = '3dab4dd7-168b-4059-af79-51a7264f3da2';
    const apiKey = 'os_v2_app_hwvu3vywrnaftl3zkgtsmtz5uja7k7ademaeh5mpi6g5gzhkxon3xc7nfleqrrak7mahyveb2gvhy472lz53m6piz7sqqra65cndrrq';
    if (!appId || !apiKey) return;

    const titles: Record<number, string> = {
      0: "New Like",
      1: "New Comment",
      2: "New Mention",
      3: "New Subscriber",
      4: "New ReHoot",
    };
    const title = titles[data.type as number];
    if (!title) return;

    const bodies: Record<number, string> = {
        0: "Someone liked your post",
        1: "Someone commented on your post",
        2: "Someone mentioned you in a comment",
        3: "Someone subscribed to your feed",
        4: "Someone reFeeded your post",
    };
    const body = bodies[data.type as number] || "You have a new notification";

    await fetch("https://api.onesignal.com/notifications?c=push", {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        Authorization: `Key ${apiKey}`,
      },
      body: JSON.stringify({
        app_id: appId,
        include_aliases: {
            external_id: [userId],
        },
        headings: {
            en: title
        },
        contents: {
            en: body
        },
        data,
      }),
    }).catch(() => undefined);
  }
);

