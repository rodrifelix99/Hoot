import { onCall, onRequest } from "firebase-functions/v2/https";
import { FieldValue } from "firebase-admin/firestore";
import { CloudTasksClient } from "@google-cloud/tasks";
import { db } from "./config";

const tasksClient = new CloudTasksClient();

export const createDailyChallenge = onCall(async (request) => {
  const prompt = request.data.prompt as string | undefined;
  const hashtag = request.data.hashtag as string | undefined;
  const expiresAt = request.data.expiresAt as number | string | undefined;
  const createAt = request.data.createAt as number | string | undefined;

  if (!prompt || !expiresAt || !createAt) {
    throw new Error("Missing parameters");
  }

  const createDate = new Date(createAt);
  if (createDate.getTime() <= Date.now()) {
    await db.collection("daily_challenges").add({
      prompt,
      ...(hashtag ? { hashtag } : {}),
      expiresAt: new Date(expiresAt),
      createdAt: FieldValue.serverTimestamp(),
    });
    return { scheduled: false };
  }

  const project = process.env.GCLOUD_PROJECT || process.env.GCP_PROJECT || "";
  const location = process.env.FUNCTION_REGION || "us-central1";
  const queue = process.env.DAILY_CHALLENGE_QUEUE || "daily-challenge";
  const url =
    process.env.CREATE_DAILY_CHALLENGE_URL ||
    `https://${location}-${project}.cloudfunctions.net/createDailyChallengeTask`;

  const task = {
    httpRequest: {
      httpMethod: "POST" as const,
      url,
      headers: { "Content-Type": "application/json" },
      body: Buffer.from(
        JSON.stringify({ prompt, hashtag, expiresAt })
      ).toString("base64"),
    },
    scheduleTime: { seconds: Math.floor(createDate.getTime() / 1000) },
  };

  await tasksClient.createTask({
    parent: tasksClient.queuePath(project, location, queue),
    task,
  });
  return { scheduled: true };
});

export const createDailyChallengeTask = onRequest(async (req, res) => {
  const { prompt, hashtag, expiresAt } = req.body as {
    prompt: string;
    hashtag?: string;
    expiresAt: number | string;
  };
  await db.collection("daily_challenges").add({
    prompt,
    ...(hashtag ? { hashtag } : {}),
    expiresAt: new Date(expiresAt),
    createdAt: FieldValue.serverTimestamp(),
  });
  res.status(200).json({ success: true });
});
