# Web portal + mobile app — shared data

## How they connect

Both **Flutter Web** (office/admin portal in the browser) and **Android/iOS** use the **same Firebase project** (`bgasapp`):

| Layer | Web | Mobile |
|--------|-----|--------|
| Auth | Firebase Auth | Firebase Auth |
| Data | Cloud Firestore (live) | Firestore + Isar cache offline |
| Files | Firebase Storage | Firebase Storage |

When a **client submits an application on mobile**, it is written to Firestore. An **office user on the web** sees it immediately via Firestore queries/listeners. When **staff updates status on web**, the **client mobile app** sees the change on next load or realtime listener.

## Run web portal

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # mobile only; optional for web
flutter run -d chrome
```

Production build:

```bash
flutter build web
# Deploy build/web/ to Firebase Hosting, Netlify, or any static host
```

## Run mobile

```bash
flutter run
```

Ensure `android/app/google-services.json` is present.

## Firebase Web app (required once)

1. [Firebase Console](https://console.firebase.google.com/) → project **bgasapp** → **Add app** → **Web**.
2. Run:

```bash
dart pub global activate flutterfire_cli
dart pub global run flutterfire_cli:flutterfire configure --project=bgasapp
```

This updates `lib/firebase_options.dart` with the correct **Web `appId`**.

## Roles on web

| Role | Route | Use |
|------|--------|-----|
| `office` | `/office-dashboard` | Regional office portal |
| `admin` | `/admin-dashboard` | National overview |
| `staff` | `/staff-home` | Field staff (works on web too) |

Create users in Firebase Auth + Firestore `users` collection with matching `role` and `officeId`.

## Deploy Firestore rules

Upload `firestore.rules` and `firestore.indexes.json` from the project root so office-scoped queries work.

## Architecture

```
Mobile app ──writes──► Firestore ◄──reads/listens── Web portal
     │                      ▲
     └── Isar (offline)     └── same collections: users, applications, reports, offices
```
