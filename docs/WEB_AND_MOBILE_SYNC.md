# Web portal + mobile app — shared data

## Architecture (two apps, one backend)

| App | Folder | Users | Tech |
|-----|--------|-------|------|
| **Mobile** | repo root (`flutter run`) | Client, staff | Flutter + Isar offline + Firebase |
| **Web portal** | `web-portal/` | Office, admin | React + Vite + Firebase |

Both use Firebase project **`bgasapp`** and the same Firestore collections:

- `users`, `applications`, `reports`, `offices`

When a **client submits on mobile**, an **office user in the React portal** sees it immediately. When **office/admin updates status on the web**, the **mobile app** sees the change on refresh or live listeners.

## Run web portal (office / admin)

```bash
cd web-portal
cp .env.example .env
npm install
npm run dev
```

Open http://localhost:5173 — sign in with `role: office` or `role: admin`.

## Run mobile app (client / staff)

```bash
# from repo root
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Firebase Web app

1. Firebase Console → project **bgasapp** → add **Web** app if needed.
2. Put config in `web-portal/.env` (see `web-portal/.env.example`).
3. Deploy `firestore.rules` and `firestore.indexes.json` from repo root.

## Roles

| Role | Use |
|------|-----|
| `client` | Mobile only |
| `staff` | Mobile only |
| `office` | **React portal** `/office` |
| `admin` | **React portal** `/admin` |

Create users in Firebase Auth + Firestore `users` with matching `role` and `officeId`.

## Deploy web portal

```bash
cd web-portal
npm run build
# deploy dist/ to Firebase Hosting or static host
```

## Flutter web note

The Flutter project can still run in Chrome for testing, but **production office/admin access should use `web-portal`**, not Flutter web dashboards.
