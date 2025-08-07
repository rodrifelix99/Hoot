import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { defineSecret } from "firebase-functions/params";
import { db } from "../config";

const onesignalApiKey = defineSecret("ONESIGNAL_API_KEY");
const onesignalAppId = defineSecret("ONESIGNAL_APP_ID");

export const onFeedRequestCreated = onDocumentCreated(
  {
    document: "feeds/{feedId}/requests/{userId}",
    secrets: [onesignalApiKey, onesignalAppId],
  },
  async (event) => {
    const { feedId, userId } = event.params;
    const appId = onesignalAppId.value();
    const apiKey = onesignalApiKey.value();
    if (!appId || !apiKey) return;

    const feedSnap = await db.collection("feeds").doc(feedId).get();
    if (!feedSnap.exists) return;
    const ownerId = feedSnap.get("userId") as string | undefined;
    if (!ownerId || ownerId === userId) return;

    const payload: Record<string, unknown> = {
      app_id: appId,
      include_aliases: { external_id: [ownerId] },
      target_channel: "push",
      headings: { en: "New Feed Request" },
      contents: { en: "Someone requested to join your feed" },
      android_channel_id: "b6b704fe-d3eb-40d7-ba28-9870ad6820cc",
      ios_sound: "notification.wav",
      ios_badgeType: "Increase",
      ios_badgeCount: 1,
      data: {
        action: "view_feed_requests",
      },
    };

    const res = await fetch(
      "https://api.onesignal.com/notifications?c=push",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          Authorization: `Key ${apiKey}`,
        },
        body: JSON.stringify(payload),
      }
    ).catch(() => undefined);

    if (!res || !res.ok) {
      const json = JSON.parse((await res?.text()) || "{}");
      console.error("Failed to send feed request notification", json);
    }
  }
);
