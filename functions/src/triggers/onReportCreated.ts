import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { FieldValue, Firestore } from "firebase-admin/firestore";
import { db } from "../config";

export async function notifyStaffOfReport(
  database: Firestore,
  reportId: string,
  report: Record<string, unknown>
): Promise<void> {
  const reporterId = report.userId as string | undefined;
  let reporter: Record<string, unknown> | undefined;
  if (reporterId) {
    const reporterSnap = await database.collection("users").doc(reporterId).get();
    reporter = reporterSnap.data();
    if (reporter) reporter["uid"] = reporterId;
  }

  const staffQuery = await database
    .collection("users")
    .where("role", "==", "staff")
    .get();

  await Promise.all(
    staffQuery.docs.map((doc) =>
      database
        .collection("users")
        .doc(doc.id)
        .collection("notifications")
        .add({
          ...(reporter ? { user: reporter } : {}),
          reportId,
          type: 6,
          read: false,
          createdAt: FieldValue.serverTimestamp(),
        })
    )
  );
}

export const onReportCreated = onDocumentCreated(
  "reports/{reportId}",
  async (event) => {
    const { reportId } = event.params;
    const report = event.data?.data();
    if (!report) return;
    await notifyStaffOfReport(db, reportId, report);
  }
);
