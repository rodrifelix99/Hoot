import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

export const onReportCreated = onDocumentCreated(
  "reports/{reportId}",
  async (event) => {
    const reportId = event.params.reportId;
    const reportData = event.data?.data();
    if (!reportData) return;

    // Buscar todos os usuários com papel de staff
    const staffQuery = await admin.firestore().collection("users").where("role", "==", "staff").get();
    const staffMembers = staffQuery.docs.map(doc => ({
      uid: doc.id,
      ...doc.data()
    }));

    // Criar notificação para cada membro da equipe
    const notificationPromises = staffMembers.map(staff => {
      return admin.firestore()
        .collection("users")
        .doc(staff.uid)
        .collection("notifications")
        .add({
          type: 99, // Defina um tipo único para "report_created"
          reportId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          message: "Um novo relatório foi criado."
        });
    });
    await Promise.all(notificationPromises);
  }
);
