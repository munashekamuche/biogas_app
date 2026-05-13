# Firebase Setup Instructions

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name (e.g., "Biogas Service Management")
4. Follow the setup wizard

## Step 2: Add Android App

1. In Firebase Console, click the Android icon
2. **Package Name**: `com.example.biogas_service_app`
   - You can change this in `android/app/build.gradle.kts` if needed
3. **App Nickname**: (Optional) Biogas Service App
4. **Debug Signing Certificate SHA-1**: (Optional, for now)
5. Click "Register App"
6. **Download `google-services.json`**
7. Place it in: `android/app/google-services.json`

## Step 3: Add iOS App (if needed)

1. In Firebase Console, click the iOS icon
2. **Bundle ID**: Check `ios/Runner/Info.plist` for your bundle ID
3. **App Nickname**: (Optional) Biogas Service App
4. Click "Register App"
5. **Download `GoogleService-Info.plist`**
6. Place it in: `ios/Runner/GoogleService-Info.plist`

## Step 4: Enable Firebase Services

### Enable Firestore Database:
1. Go to Firestore Database in Firebase Console
2. Click "Create Database"
3. Start in **test mode** (for development)
4. Choose a location (closest to your users)

### Enable Authentication:
1. Go to Authentication in Firebase Console
2. Click "Get Started"
3. Enable **Email/Password** sign-in method
4. Save

### Enable Cloud Messaging (for Push Notifications):
1. Go to Cloud Messaging in Firebase Console
2. Follow the setup instructions for your platform

## Step 5: Update Package Name (Optional but Recommended)

The default package name is `com.example.biogas_service_app`. You should change it to your own:

1. Update `android/app/build.gradle.kts`:
   ```kotlin
   applicationId = "com.yourcompany.biogas_service_app"
   ```

2. Update the package name in Firebase Console to match

3. Update `android/app/src/main/kotlin/com/example/biogas_service_app/MainActivity.kt`:
   - Change the package declaration to match

## Step 6: Verify Setup

After placing `google-services.json` in `android/app/`, run:

```bash
flutter pub get
flutter run
```

The app should connect to Firebase without errors.

## Troubleshooting

- **File not found**: Make sure `google-services.json` is in `android/app/` (not `android/`)
- **Build errors**: Run `flutter clean` then `flutter pub get`
- **Authentication errors**: Make sure Email/Password is enabled in Firebase Console
- **Firestore errors**: Make sure Firestore is created and in test mode

