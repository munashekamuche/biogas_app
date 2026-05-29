/**
 * Creates test users in Firebase Auth + Firestore (project bgasapp).
 * Run from web-portal: node scripts/seed-test-users.mjs
 */
import { readFileSync, existsSync } from 'fs';
import { initializeApp } from 'firebase/app';
import {
  getAuth,
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut,
} from 'firebase/auth';
import { getFirestore, doc, setDoc, serverTimestamp } from 'firebase/firestore';

const TEST_OFFICE_ID = 'test-office-harare';
const TEST_PASSWORD = 'Test@123456';

const ADMIN_USER = {
  email: 'admin@test.rea.local',
  role: 'admin',
  fullName: 'Test',
  surname: 'Admin',
  nationalId: 'ADM000001',
  phoneNumber: '+263770000001',
  station: null,
  officeId: null,
};

const OTHER_USERS = [
  {
    email: 'office@test.rea.local',
    role: 'office',
    fullName: 'Test',
    surname: 'Office',
    nationalId: 'OFF000001',
    phoneNumber: '+263770000002',
    station: null,
    officeId: TEST_OFFICE_ID,
  },
  {
    email: 'staff@test.rea.local',
    role: 'staff',
    fullName: 'Test',
    surname: 'Staff',
    nationalId: 'STF000001',
    phoneNumber: '+263770000003',
    station: 'Harare Central',
    officeId: TEST_OFFICE_ID,
  },
  {
    email: 'client@test.rea.local',
    role: 'client',
    fullName: 'Test',
    surname: 'Client',
    nationalId: 'CLI000001',
    phoneNumber: '+263770000004',
    station: null,
    officeId: TEST_OFFICE_ID,
  },
];

function loadEnv() {
  const path = '.env';
  if (!existsSync(path)) {
    throw new Error('Missing web-portal/.env — copy .env.example to .env first.');
  }
  const env = {};
  for (const line of readFileSync(path, 'utf8').split('\n')) {
    const t = line.trim();
    if (!t || t.startsWith('#')) continue;
    const i = t.indexOf('=');
    if (i > 0) env[t.slice(0, i).trim()] = t.slice(i + 1).trim();
  }
  return env;
}

async function ensureAuthUser(auth, user) {
  try {
    const cred = await createUserWithEmailAndPassword(auth, user.email, TEST_PASSWORD);
    console.log(`Created Auth user: ${user.email}`);
    return cred.user.uid;
  } catch (e) {
    if (e.code === 'auth/email-already-in-use') {
      const cred = await signInWithEmailAndPassword(auth, user.email, TEST_PASSWORD);
      console.log(`Auth user exists: ${user.email}`);
      return cred.user.uid;
    }
    throw e;
  }
}

async function writeUserProfile(db, uid, user) {
  await setDoc(
    doc(db, 'users', uid),
    {
      id: uid,
      fullName: user.fullName,
      surname: user.surname,
      nationalId: user.nationalId,
      phoneNumber: user.phoneNumber,
      email: user.email,
      role: user.role,
      station: user.station,
      officeId: user.officeId,
      createdAt: serverTimestamp(),
    },
    { merge: true },
  );
  console.log(`Firestore profile: ${user.email} (${user.role})`);
}

async function ensureOffice(db) {
  await setDoc(
    doc(db, 'offices', TEST_OFFICE_ID),
    {
      id: TEST_OFFICE_ID,
      name: 'Harare Test Office',
      region: 'Harare',
      active: true,
      createdAt: serverTimestamp(),
    },
    { merge: true },
  );
  console.log(`Office ready: ${TEST_OFFICE_ID} (Harare Test Office)`);
}

async function main() {
  const env = loadEnv();
  const app = initializeApp({
    apiKey: env.VITE_FIREBASE_API_KEY,
    authDomain: env.VITE_FIREBASE_AUTH_DOMAIN,
    projectId: env.VITE_FIREBASE_PROJECT_ID,
    storageBucket: env.VITE_FIREBASE_STORAGE_BUCKET,
    messagingSenderId: env.VITE_FIREBASE_MESSAGING_SENDER_ID,
    appId: env.VITE_FIREBASE_APP_ID,
  });
  const auth = getAuth(app);
  const db = getFirestore(app);

  console.log('Seeding test data for project:', env.VITE_FIREBASE_PROJECT_ID);

  // 1) Admin (creates own Firestore doc while authenticated)
  const adminUid = await ensureAuthUser(auth, ADMIN_USER);
  await writeUserProfile(db, adminUid, ADMIN_USER);
  await signOut(auth);

  // 2) Office document (requires admin role in rules)
  await signInWithEmailAndPassword(auth, ADMIN_USER.email, TEST_PASSWORD);
  await ensureOffice(db);
  await signOut(auth);

  // 3) Other roles (each creates own Auth + profile)
  for (const user of OTHER_USERS) {
    const uid = await ensureAuthUser(auth, user);
    await writeUserProfile(db, uid, user);
    await signOut(auth);
  }

  console.log('\nDone. Credentials: docs/TEST_ACCOUNTS.md');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
