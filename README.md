# Biogas Service Management App (REA Service Application)

A **Flutter** digital service delivery platform for **Grid**, **Solar**, and **Biogas** solutions. It supports **clients** (mobile), **field staff**, **national administrators**, and **regional office** users who see only their territory. The same codebase runs on **Android**, **iOS**, and **Web** (office portal and admin-friendly layout).

---

## Table of contents

1. [Features](#features)
2. [User roles](#user-roles)
3. [Multi-office model](#multi-office-model)
4. [Tech stack](#tech-stack)
5. [Architecture](#architecture)
6. [Firebase data model](#firebase-data-model)
7. [Project structure](#project-structure)
8. [Getting started](#getting-started)
9. [Web build](#web-build)
10. [Firestore security and indexes](#firestore-security-and-indexes)
11. [Offline sync](#offline-sync)
12. [Navigation routes](#navigation-routes)
13. [Security and production notes](#security-and-production-notes)
14. [Troubleshooting](#troubleshooting)
15. [Roadmap and limitations](#roadmap-and-limitations)
16. [Related docs](#related-docs)

---

## Features

### Clients (mobile)

- Registration and login (including phone-based pseudo-email flow for clients).
- **Regional office** selection at registration (from `offices` where `active == true`).
- Service request flow: Grid / Solar / Biogas (with homestead / institutional where applicable).
- Dynamic-style application forms (`FormConfigService`: Firestore `form_configs`, assets, or code defaults).
- Application list, details, export helpers.
- In-app notifications (Firestore `notifications` stream; push via FCM not wired in `pubspec` yet).
- Profile, gallery, theme (light/dark via `ThemeProvider`).

### Staff (mobile)

- Login with email (Firebase Auth).
- Station and optional **office** assignment (created by admin).
- Field **reports** with offline queue and sync.

### Admin (national)

- Dashboard: applications, reports, staff, clients, **Offices** tab.
- **Office management**: create offices, toggle `active`, open flow to add **office portal** users.
- **Add staff** with optional regional office link.
- Client management, PDF/print flows where implemented.
- `CreateAdminScreen` exists for development; **remove or gate for production**.

### Office portal (`role: office`)

- **`OfficeDashboardScreen`**: applications, reports, and clients **filtered by `officeId`**.
- Can update application status (approve / reject / in progress) for their office.
- Intended for **web** (`flutter run -d chrome` / `flutter build web`) and large screens; mobile login with same credentials also works.

---

## User roles

| Role       | Typical surface      | Scope |
|-----------|----------------------|--------|
| `client`  | Mobile               | Own applications; `officeId` on user and applications. |
| `staff`   | Mobile               | Own reports; optional `officeId` and `station`. |
| `admin`   | Mobile / Web         | All offices, users, applications, reports. |
| `office`  | Web (recommended)    | Single `officeId`; applications, reports, clients for that office only. |

Role is stored on the Firestore **`users/{uid}`** document and used after Firebase Auth sign-in.

---

## Multi-office model

- **`offices`** documents: `id`, `name`, `region`, `active`, `createdAt` (see `OfficeService`, `OfficeModel`).
- **`officeId`** on:
  - `users` (clients, staff, office portal users),
  - `applications`,
  - `reports`.
- **Clients** must pick an office when active offices exist (see `RegisterScreen`).
- **Admins** create offices and **office portal accounts** (`AddOfficePortalUserScreen`).
- **Queries** for office users use `where('officeId', isEqualTo: ...)` plus `orderBy('submittedAt')` where required; see [Firestore indexes](#firestore-security-and-indexes).

---

## Tech stack

| Area            | Technology |
|----------------|------------|
| Framework      | Flutter (Dart SDK `>=3.0.0 <4.0.0`) |
| State          | `provider` |
| Local DB       | **Isar** (`lib/models/isar_models.dart` + generated `isar_models.g.dart`) |
| Cloud          | **Firebase** Auth, Firestore, Storage |
| Connectivity   | `connectivity_plus` for online/offline branching |
| Navigation     | `MaterialApp` + `Navigator` named routes (`AppRouter`); `go_router` is listed in `pubspec` but not the primary router |
| UI scaling     | `flutter_screenutil` |
| PDF / share    | `pdf`, `printing`, `share_plus` |

---

## Architecture

```
lib/
├── main.dart                 # Firebase + Isar init, MultiProvider, MaterialApp (web-aware builder)
├── database/                 # Isar singleton
├── models/                   # Domain + Isar collections
├── providers/                # Auth, App, User, Theme, Notifications
├── services/                 # Firestore, sync, offices, forms, export, etc.
├── screens/                  # auth/, client/, staff/, admin/, office/
├── utils/                    # theme, app_router, responsive helpers
└── widgets/
```

**Flow (simplified)**

1. **Auth**: `AuthProvider` uses `AuthService` + Firestore `users/{uid}`; caches user in Isar via `SyncService` when possible.
2. **Applications / reports**: `ApplicationService` / `ReportService` read Firestore when online, **Isar** when offline; pending rows use `needsSync` and `SyncService.syncPending*`.
3. **AppProvider** tracks last application query (`_lastApplicationsUserId` / `_lastApplicationsOfficeId`) so updates reload the same scope.

---

## Firebase data model

Collections used (non-exhaustive; align rules with your usage):

| Collection        | Purpose |
|------------------|---------|
| `users`          | Profile + `role`, `officeId`, `station`, etc. |
| `offices`        | Regional offices |
| `applications`   | Service requests + `officeId`, `formData`, `status` |
| `reports`        | Staff reports + `officeId` |
| `notifications`  | In-app notifications |
| `form_configs`   | Optional dynamic form definitions |

---

## Project structure (high level)

| Path | Description |
|------|-------------|
| `lib/main.dart` | Entry, providers, `SplashScreen`, web `MaterialApp.builder` |
| `lib/utils/app_router.dart` | Named routes |
| `lib/screens/office/office_dashboard_screen.dart` | Regional portal |
| `lib/screens/admin/office_management_screen.dart` | CRUD-style office list + add |
| `lib/screens/admin/add_office_portal_user_screen.dart` | Create `office` role user |
| `firestore.rules` | **Template** security rules (deploy and customize) |
| `firestore.indexes.json` | **Composite index** definitions (deploy with Firebase CLI) |
| `SETUP_GUIDE.md` | Step-by-step Firebase, assets, Isar, testing |

---

## Getting started

### Prerequisites

- Flutter SDK **3.0+** (`flutter doctor`)
- Firebase project (Auth email/password, Firestore, optional Storage)
- IDE: VS Code or Android Studio

### Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Firebase app setup

1. Add **Android** app → download `google-services.json` → `android/app/`
2. Add **iOS** app → download `GoogleService-Info.plist` → `ios/Runner/`
3. Enable **Firestore** and **Authentication** (Email/Password)

### Assets

Declared in `pubspec.yaml`:

- `assets/images/`
- `assets/logo/` (e.g. `company_logo.png`)
- `assets/config/` (e.g. `form_fields.json`)

### Run (mobile)

```bash
flutter devices
flutter run -d <device-id>
```

### First-time onboarding

- Splash → intro once (`SharedPreferences` `hasSeenIntro`) → login or auto-route by role if session exists.

More detail: **`SETUP_GUIDE.md`**.

---

## Web build

Same Flutter app; constrained width for large screens in `main.dart` when `kIsWeb`.

```bash
flutter run -d chrome
# or
flutter build web
```

Host the `build/web` output on your static host or Firebase Hosting. Office users log in with **`office`** role accounts created from **Admin → Offices → Office web login** (or route `/add-office-portal-user`).

---

## Firestore security and indexes

1. **Indexes**: Deploy `firestore.indexes.json` (includes `users` role+`officeId`, `applications` and `reports` `officeId`+`submittedAt`). Without deployment, some office-scoped queries will fail with a missing index link in the console.

2. **Rules**: `firestore.rules` is a **starting point** for admin / office / client separation. **Review** with your security requirements; extend for comments, audit logs, or other collections before production.

Deploy (Firebase CLI example):

```bash
firebase deploy --only firestore:indexes
firebase deploy --only firestore:rules
```

---

## Offline sync

- **Isar** stores users, applications, and reports locally.
- **`needsSync`** flags pending uploads when connectivity was offline.
- `ApplicationService` / `ReportService` use `connectivity_plus` to choose Firestore vs local reads/writes.
- Call pending sync paths from your UX where appropriate (e.g. after reconnect); services expose `syncPendingApplications` / `syncPendingReports`.

---

## Navigation routes

Defined in `lib/utils/app_router.dart` (excerpt):

| Route | Screen |
|-------|--------|
| `/login` | Login |
| `/register` | Register |
| `/client-home` | Client home |
| `/staff-home` | Staff home |
| `/admin-dashboard` | Admin dashboard |
| `/office-dashboard` | Office portal |
| `/office-management` | Office list (standalone route) |
| `/add-office-portal-user` | Create office portal user |
| `/add-staff` | Add staff |
| `/create-admin` | Dev-only admin bootstrap (remove for production) |

---

## Security and production notes

- **Firestore rules** and **indexes** must be deployed for multi-office queries and safe access.
- **`CreateAdminScreen`**: treat as development-only; remove from routes or protect in release builds.
- **Role trust**: any “fallback” login paths in `AuthProvider` must align with rules so roles cannot be escalated server-side.
- **Secrets**: never commit real `google-services.json` / plist / API keys to public repos.

---

## Troubleshooting

| Issue | Suggestion |
|-------|------------|
| Isar codegen fails | Fix all **syntax errors** in `lib/` first, then `flutter clean`, `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs` |
| Missing Firestore index | Deploy `firestore.indexes.json` or create the suggested index from the console link |
| Firebase init errors | Check plist/json placement and package name / bundle ID |
| Web layout | Adjust `MaterialApp.builder` in `main.dart` |

---

## Roadmap and limitations

**Implemented in this repo (high level):** multi-office fields, office portal UI, admin office management, staff office link, web-friendly shell, starter rules/indexes, offline-first create path for applications/reports.

**Not fully implemented (examples):** push notifications (`firebase_messaging` commented out), SMS, in-app chat, GIS, payments, full audit log, Excel export, separate non-Flutter HQ web app, AI screening, government API integrations.

---

## Related docs

| File | Content |
|------|---------|
| [SETUP_GUIDE.md](SETUP_GUIDE.md) | Detailed Firebase, assets, Isar, offline testing |
| [firestore.rules](firestore.rules) | Firestore security rules template |
| [firestore.indexes.json](firestore.indexes.json) | Composite indexes for office queries |

---

## License / publishing

`publish_to: 'none'` in `pubspec.yaml` — configure for your distribution model.

---

## Contributing / versioning

- Run `dart analyze` and fix **errors** before merging.
- After changing `lib/models/isar_models.dart`, always re-run **build_runner** (Isar schema change may require clearing local app data on test devices).
