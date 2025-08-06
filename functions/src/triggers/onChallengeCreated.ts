import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { defineSecret } from "firebase-functions/params";
import { Timestamp } from "firebase-admin/firestore";
import { db } from "../config";

const onesignalApiKey = defineSecret("ONESIGNAL_API_KEY");
const onesignalAppId = defineSecret("ONESIGNAL_APP_ID");

export const onChallengeCreated = onDocumentCreated(
  {
    document: "daily_challenges/{challengeId}",
    secrets: [onesignalApiKey, onesignalAppId],
  },
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const appId = onesignalAppId.value();
    const apiKey = onesignalApiKey.value();
    if (!appId || !apiKey) return;

    const challengeId = event.params.challengeId;
    const prompt = data.prompt as string | undefined;
    const hashtag = data.hashtag as string | undefined;

    const payload: Record<string, unknown> = {
      app_id: appId,
      included_segments: ["Subscribed Users"],
      target_channel: "push",
      headings: { en: "New Daily Challenge" },
      contents: { en: prompt ?? "Check out today's challenge!" },
      data: {
        challengeId,
        ...(hashtag ? { hashtag } : {}),
      },
      android_channel_id: "b6b704fe-d3eb-40d7-ba28-9870ad6820cc",
      ios_sound: "notification.wav",
    };

    console.log(
      "Sending OneSignal payload:",
      JSON.stringify(payload, null, 2)
    );
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
      console.error("Failed to send challenge notification", json);
    }
  }
);

export const createDailyChallenge = onSchedule(
  {
    schedule: "0 0 * * *",
    timeZone: "UTC",
  },
  async () => {
    const prompts = [
      { prompt: "Share a snapshot from your day", hashtag: "DailySnapshot" },
      {
        prompt: "What's something you're grateful for today?",
        hashtag: "Grateful",
      },
      { prompt: "Show us a hobby you love", hashtag: "HobbyTime" },
    ];
    const choice = prompts[Math.floor(Math.random() * prompts.length)];
    const now = Timestamp.now();
    const expiresAt = Timestamp.fromMillis(
      now.toMillis() + 24 * 60 * 60 * 1000
    );
    await db.collection("daily_challenges").add({
      prompt: choice.prompt,
      hashtag: choice.hashtag,
      createdAt: now,
      expiresAt,
    });
  }
);
