import { auth } from "firebase-functions/v1";
import { UserRecord } from "firebase-functions/v1/auth";

export function onUserDeleted(handler: (event: { data: UserRecord }) => any) {
  return auth.user().onDelete((user) => handler({ data: user }));
}
