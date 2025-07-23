import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import {info, error} from 'firebase-functions/logger';

admin.initializeApp();
export const db = admin.firestore();
export { functions, admin, info, error };
