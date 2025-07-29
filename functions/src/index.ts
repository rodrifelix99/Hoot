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
import {onDocumentCreated} from "firebase-functions/v2/firestore";

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
    if (!text || !text.includes("@")) return;

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
  }
);

