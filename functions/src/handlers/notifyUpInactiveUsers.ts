import { onSchedule } from 'firebase-functions/v2/scheduler';
import { db, admin, info, error } from '../common';
import { getUser, getFeedObject, getHootObj, sendPush, sendDatabaseNotification } from '../utils';
export const notifyUpInactiveUsers = onSchedule({ schedule: "every 24 hours", region: "europe-west1" }, async (event) => {
  try {
    const users = await db.collection("users").where("lastOnline", "<", admin.firestore.Timestamp.fromDate(new Date(Date.now() - 48 * 60 * 60 * 1000))).get();
    const tokens = [];
    const uids = [];
    const titles = [
      "We miss you",
      "Come back",
      "We have new content",
      "Hey there",
      "We have new content for you",
      "There's so many new things to see",
      "We have new content for you",
      "How are you doing?",
    ];
    const messages = [
      "Check back in to see what's new",
      "Open Hoot to see what's new",
      "Why not create some new hoots?",
      "Let's take a look at what's new",
      "Let's follow some new feeds",
      "Let's see what's new"
    ];
    
    for (const user of users.docs) {
      if (user.data().fcmToken) {
        const token = user.data().fcmToken;
        tokens.push(token);
        uids.push(user.id);
      }
    }

    for (var i = 0; i < uids.length; i++) {
      const title = titles[Math.floor(Math.random() * titles.length)];
      const message = messages[Math.floor(Math.random() * messages.length)];
      await sendPush(uids[i], title, message, {}, tokens[i]);
    }
  } catch (e) {
    error(e);
  }
});
