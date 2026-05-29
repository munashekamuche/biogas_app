/**
 * Seeds test users via Firebase Admin SDK (bypasses Firestore security rules).
 *
 * Setup once:
 *   Firebase Console → Project settings → Service accounts → Generate new private key
 *   Save as: web-portal/service-account.json  (gitignored)
 *
 * Run: npm run seed:test-users:admin
 */
import { readFileSync, existsSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import admin from 'firebase-admin';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '..');
const SERVICE_ACCOUNT_PATH = join(ROOT, 'service-account.json');

const TEST_OFFICE_ID = 'test-office-harare';
const TEST_PASSWORD = 'Test@123456';

const USERS = [
  {
    email: 'admin@test.rea.local',
    role: 'admin',
    fullName: 'Test',
    surname: 'Admin',
    nationalId: 'ADM000001',
    phoneNumber: '+263770000001',
    station: null,
    officeId: null,
  },
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

function loadProjectId() {
  const envPath = join(ROOT, '.env');
  if (existsSync(envPath)) {
    for (const line of readFileSync(envPath, 'utf8').split('\n')) {
      const t = line.trim();
      if (t.startsWith('VITE_FIREBASE_PROJECT_ID=')) {
        return t.split('=')[1].trim();
      }
    }
  }
  return 'bgasapp';
}

async function ensureAuthUser(auth, user) {
  try {
    const existing = await auth.getUserByEmail(user.email);
    await auth.updateUser(existing.uid, { password: TEST_PASSWORD });
    console.log(`Auth user updated: ${user.email}`);
    return existing.uid;
  } catch (e) {
    if (e.code === 'auth/user-not-found') {
      const created = await auth.createUser({
        email: user.email,
        password: TEST_PASSWORD,
        displayName: `${user.fullName} ${user.surname}`,
      });
      console.log(`Auth user created: ${user.email}`);
      return created.uid;
    }
    throw e;
  }
}

async function main() {
  if (!existsSync(SERVICE_ACCOUNT_PATH)) {
    console.error(`
Missing ${SERVICE_ACCOUNT_PATH}

1. Open https://console.firebase.google.com/project/bgasapp/settings/serviceaccounts/adminsdk
2. Click "Generate new private key"
3. Save the file as web-portal/service-account.json
4. Run: npm run seed:test-users:admin
`);
    process.exit(1);
  }

  const serviceAccount = JSON.parse(readFileSync(SERVICE_ACCOUNT_PATH, 'utf8'));
  const projectId = serviceAccount.project_id || loadProjectId();

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId,
  });

  const auth = admin.auth();
  const db = admin.firestore();

  console.log('Seeding (Admin SDK) project:', projectId);

  await db.collection('offices').doc(TEST_OFFICE_ID).set(
    {
      id: TEST_OFFICE_ID,
      name: 'Harare Test Office',
      region: 'Harare',
      active: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  console.log(`Office: ${TEST_OFFICE_ID}`);

  for (const user of USERS) {
    const uid = await ensureAuthUser(auth, user);
    await db
      .collection('users')
      .doc(uid)
      .set(
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
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    console.log(`Firestore profile: ${user.email} (${user.role}) uid=${uid}`);
  }

  console.log('\nDone. See docs/TEST_ACCOUNTS.md for login credentials.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
