import { setGlobalOptions } from "firebase-functions";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

setGlobalOptions({ maxInstances: 10 });
initializeApp();

export const db = getFirestore();
