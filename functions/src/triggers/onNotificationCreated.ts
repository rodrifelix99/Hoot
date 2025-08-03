import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { defineSecret } from "firebase-functions/params";

const onesignalApiKey = defineSecret("ONESIGNAL_API_KEY");
const onesignalAppId = defineSecret("ONESIGNAL_APP_ID");

export const onNotificationCreated = onDocumentCreated(
  {
    document: "users/{userId}/notifications/{notificationId}",
    secrets: [ onesignalApiKey, onesignalAppId ]
  },
  async (event) => {
    const { userId } = event.params;
    const data = event.data?.data();
    if (!data) return;

    const appId = onesignalAppId.value();
    const apiKey = onesignalApiKey.value();
    if (!appId || !apiKey) return;

    const titles: Record<number, string> = {
      0: "New Like",
      1: "New Comment",
      2: "New Mention",
      3: "New Subscriber",
      4: "New ReHoot",
      5: "Friend Joined",
      6: "New Report",
    };
    const title = titles[data.type as number];
    if (!title) return;

    const user = data.user;
    const username = user?.username ? `@${user.username}` : "Someone";
    const avatar = user?.bigAvatar as string | undefined;

    const trimmedData: Record<string, unknown> = {
      type: data.type,
    };
    if (data.postId) trimmedData.postId = data.postId;
    if (data.feed?.id) trimmedData.feedId = data.feed.id;
    if (user?.uid) trimmedData.uid = user.uid;
    if (user?.username) trimmedData.username = user.username;
    if (user?.bigAvatar) trimmedData.bigAvatar = user.bigAvatar;
    const bodyTemplates: Record<number, string> = {
      0: `${username} liked your post`,
      1: `${username} commented on your post`,
      2: `${username} mentioned you in a comment`,
      3: `${username} subscribed to your feed`,
      4: `${username} reFeeded your post`,
      5: `${username} joined Hoot using your invite code`,
      6: `${username} submitted a report`,
    };
    const body =
      bodyTemplates[data.type as number] ?? "You have a new notification";

    const payload: Record<string, unknown> = {
      "app_id": appId,
      "include_aliases": {
        "external_id": [userId],
      },
        "target_channel": "push",
      "headings": {
        en: title,
      },
      "contents": {
        "en": body,
      },
      "android_channel_id": "b6b704fe-d3eb-40d7-ba28-9870ad6820cc",
      "ios_sound": "notification.wav",
      "data": trimmedData,
    };
    if (avatar) {
      (payload as Record<string, unknown>)["chrome_web_image"] = avatar;
    }

    console.log('Going to send OneSignal payload:', JSON.stringify(payload, null, 2));
    var res = await fetch("https://api.onesignal.com/notifications?c=push", {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": `Key ${apiKey}`,
      },
      body: JSON.stringify(payload),
    }).catch(() => undefined);

    if (!res || !res.ok) {
        const json = JSON.parse(await res?.text() || "{}");
      console.error("Failed to send notification", json);
      return;
    }
  }
);
