import { onDocumentCreated } from "firebase-functions/v2/firestore";

export const onNotificationCreated = onDocumentCreated(
  "users/{userId}/notifications/{notificationId}",
  async (event) => {
    const { userId } = event.params;
    const data = event.data?.data();
    if (!data) return;

    const appId = '3dab4dd7-168b-4059-af79-51a7264f3da2';
    const apiKey = 'os_v2_app_hwvu3vywrnaftl3zkgtsmtz5uja7k7ademaeh5mpi6g5gzhkxon3xc7nfleqrrak7mahyveb2gvhy472lz53m6piz7sqqra65cndrrq';
    if (!appId || !apiKey) return;

    const titles: Record<number, string> = {
      0: "New Like",
      1: "New Comment",
      2: "New Mention",
      3: "New Subscriber",
      4: "New ReHoot",
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
