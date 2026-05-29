# Test user accounts

**Shared password (all accounts):** `Test@123456`

**Test office:** `test-office-harare` — Harare Test Office

Enable **Email/Password** in [Firebase Authentication](https://console.firebase.google.com/project/bgasapp/authentication/providers).

---

## Credentials

| Role | Email | Where to sign in |
|------|-------|------------------|
| **Admin** | `admin@test.rea.local` | Web portal → `/login` |
| **Office** | `office@test.rea.local` | Web portal → `/login` |
| **Staff** | `staff@test.rea.local` | Mobile app |
| **Client** | `client@test.rea.local` | Mobile app |

- Web portal (`web-portal`): only **admin** and **office**.
- Mobile: **client** and **staff** (and other roles if routed there).

---

## Seed into Firebase (Auth + Firestore)

### Option A — Admin SDK (recommended if seed fails with permission denied)

1. [Generate a service account key](https://console.firebase.google.com/project/bgasapp/settings/serviceaccounts/adminsdk) for project **bgasapp**.
2. Save it as `web-portal/service-account.json` (never commit this file).
3. From `web-portal`:

```bash
npm install
npm run seed:test-users:admin
```

This creates all four Auth users, `users/{uid}` profiles, and the test office.

### Option B — Client SDK (needs deployed rules)

Deploy rules from the repo root (requires `firebase login --reauth`):

```bash
firebase deploy --only firestore:rules --project bgasapp
```

Then:

```bash
cd web-portal
npm run seed:test-users
```

If you see `PERMISSION_DENIED`, Firestore rules on the project are likely still **expired test mode** or not deployed — use **Option A** or deploy rules first.

---

## Security

For **development and demos only**. Delete or disable these accounts before production.
