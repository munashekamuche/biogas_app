# REA Web Portal (Office & Admin)

Separate **React + Vite** app for regional **office** and national **admin** users.  
The **Flutter mobile app** is for **clients** and **field staff** only.

Both apps use the same **Firebase project** (`bgasapp`) and **Firestore** collections, so data stays in sync.

## Setup

```bash
cd web-portal
cp .env.example .env
npm install
npm run dev
```

Open http://localhost:5173 and sign in with an `office` or `admin` user from Firestore `users`.

## Routes

| Path | Role |
|------|------|
| `/login` | Office & admin sign-in |
| `/office` | Regional office dashboard |
| `/admin` | National admin dashboard |

## Production build

```bash
npm run build
npm run preview
```

Deploy the `dist/` folder to Firebase Hosting, Netlify, or any static host.

## Firebase

1. Register a **Web app** in Firebase Console (project `bgasapp`).
2. Copy config into `.env` (see `.env.example`).
3. Deploy `firestore.rules` from the repo root.

## Mobile app

From repo root:

```bash
flutter run
```

Clients submit applications on mobile → office/admin see them in this portal instantly.
