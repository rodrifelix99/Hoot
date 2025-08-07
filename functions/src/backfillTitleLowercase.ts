import { db } from "./config";

async function backfillTitleLowercase() {
  const snapshot = await db.collection("feeds").get();
  const updates = snapshot.docs.map((doc) => {
    const title = doc.get("title");
    if (typeof title === "string") {
      return doc.ref.update({ titleLowercase: title.toLowerCase() });
    }
    return Promise.resolve();
  });
  await Promise.all(updates);
}

backfillTitleLowercase()
  .then(() => {
    console.log("Backfill completed");
    process.exit(0);
  })
  .catch((err) => {
    console.error("Backfill failed", err);
    process.exit(1);
  });
