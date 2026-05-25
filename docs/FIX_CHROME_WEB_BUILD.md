# Fix: `flutter run -d chrome` fails with `dartify` / `jsify` errors

## What you saw

```
firebase_storage_web-3.6.22 ... dartify ... isn't defined
firebase_storage_web-3.6.22 ... jsify ... isn't defined
Failed to compile application.
```

This happens on **newer Flutter/Dart** (3.5+) with **old Firebase Storage Web** packages locked in `pubspec.lock`.

## Fix (required)

### 1. Get the latest code

```bash
git pull origin main
```

The project `pubspec.yaml` now uses **Firebase 3.x** packages (compatible with web).

### 2. Clean and refresh dependencies

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Confirm `pubspec.lock` shows **`firebase_storage_web` 3.10.x** (not 3.6.22):

```bash
# PowerShell
Select-String "firebase_storage_web" pubspec.lock -Context 0,3
```

### 3. Configure Firebase for Web (important)

Web needs Firebase config in Dart. From project root:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

- Select your Firebase project.
- Select platforms: **android**, **ios**, **web** (at minimum **web** + android).
- This creates `lib/firebase_options.dart`.

Then update `lib/main.dart` initialization to:

```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

(If `firebase_options.dart` is missing, `Firebase.initializeApp()` often fails on Chrome at runtime.)

### 4. Run on Chrome

```bash
flutter run -d chrome
```

## Isar / web (fixed in codebase)

Web builds **skip Isar** and use **Firestore only** via conditional imports (`database_init.dart`, `sync_service.dart`). Mobile keeps Isar for offline use. See `docs/WEB_AND_MOBILE_SYNC.md`.

The partner’s original `dartify` / `jsify` error is **only** the old `firebase_storage_web` package; pull + `flutter pub get` fixes that part.

## Still failing?

| Check | Action |
|--------|--------|
| Old lock file | Delete `pubspec.lock`, run `flutter pub get` again (only if pull did not update lock) |
| Flutter version | `flutter doctor` — use stable channel, SDK >= 3.0 |
| Isar not generated | Run `build_runner` (see above) |
| Missing `google-services.json` | Android only; web uses `firebase_options.dart` |
| Firebase not enabled | Console: Auth (Email/Password), Firestore created |

## Android / mobile (unchanged)

```bash
flutter run
```

Place `google-services.json` in `android/app/` (not committed in Git).
