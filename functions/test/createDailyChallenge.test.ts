import test, { mock } from "node:test";
import assert from "node:assert";
import functionsTest from "firebase-functions-test";
import { createDailyChallenge } from "../src/createDailyChallenge";
import { db } from "../src/config";
import { CloudTasksClient } from "@google-cloud/tasks";

process.env.GCLOUD_PROJECT = "demo-project";
process.env.FUNCTION_REGION = "us-central1";

const testEnv = functionsTest();

test.after(() => {
  testEnv.cleanup();
});

test("creates challenge immediately when createAt is past", async () => {
  const add = mock.fn(async () => ({}));
  const restoreCollection = mock.method(db, "collection", () => ({ add }));
  const wrapped = testEnv.wrap(createDailyChallenge);
  await wrapped({
    data: {
      prompt: "Prompt",
      hashtag: "#tag",
      expiresAt: Date.now() + 3600,
      createAt: Date.now() - 1000,
    },
  } as any);
  assert.equal(add.mock.callCount(), 1);
  restoreCollection.mock.restore();
});

test("schedules challenge via Cloud Tasks when createAt in future", async () => {
  const add = mock.fn(async () => ({}));
  const restoreCollection = mock.method(db, "collection", () => ({ add }));
  const restoreTask = mock.method(
    CloudTasksClient.prototype,
    "createTask",
    async () => [{}]
  );
  const wrapped = testEnv.wrap(createDailyChallenge);
  const future = Date.now() + 60000;
  await wrapped({
    data: {
      prompt: "Prompt",
      hashtag: "#tag",
      expiresAt: Date.now() + 3600,
      createAt: future,
    },
  } as any);
  assert.equal(restoreTask.mock.callCount(), 1);
  assert.equal(add.mock.callCount(), 0);
  restoreTask.mock.restore();
  restoreCollection.mock.restore();
});
