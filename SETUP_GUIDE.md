# Setup Guide - Biogas Service Management App

## Prerequisites

1. **Flutter SDK** (3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Firebase Account**
   - Create account at: https://firebase.google.com
   - Create a new Firebase project

3. **IDE** (Recommended: VS Code or Android Studio)

## Step 1: Install Dependencies

```bash
flutter pub get
```

## Step 2: Generate Isar Code

Isar requires code generation. Run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate the necessary Isar database code from `lib/models/isar_models.dart`.

## Step 3: Firebase Setup

### For Android:

1. In Firebase Console, go to Project Settings > Your Apps
2. Click "Add App" and select Android
3. Register your app with package name (e.g., `com.company.bgas_app`io)
4. Download `google-services.json`
5. Place it in `android/app/` directory

### For iOS:

1. In Firebase Console, go to Project Settings > Your Apps
2. Click "Add App" and select iOS
3. Register your app with bundle ID
4. Download `GoogleService-Info.plist`
5. Place it in `ios/Runner/` directory

### Enable Firebase Services:

1. **Firestore Database:**
   - Go to Firestore Database in Firebase Console
   - Click "Create Database"
   - Start in test mode (for development)
   - Choose a location

2. **Authentication:**
   - Go to Authentication in Firebase Console
   - Click "Get Started"
   - Enable "Email/Password" sign-in method

3. **Cloud Messaging (for Push Notifications):**
   - Go to Cloud Messaging in Firebase Console
   - Follow setup instructions for your platform

## Step 4: Add Assets

Create the following directories and add your assets:

```
assets/
├── logo/
│   └── company_logo.png    # Your company logo (recommended: 512x512px)
├── images/
│   ├── grid_solar.png      # Grid/Solar service image
│   └── biogas.png          # Biogas service image
└── icons/
    └── (any additional icons)
```

Update `pubspec.yaml` if you add more asset directories.

## Step 5: Configure Application Form

The application form fields are currently placeholder. To customize:

1. Edit `lib/screens/client/application_form_screen.dart`
2. Modify the `_loadFormFields()` method to load your company's form fields
3. You can load from a JSON file, Firestore document, or hardcode the fields

Example:
```dart
void _loadFormFields() {
  _formFields.addAll([
    {'label': 'Field Name', 'key': 'fieldKey', 'required': true},
    // Add more fields as needed
  ]);
}
```

## Step 6: Admin Password Configuration

To set up admin authentication:

1. Create an admin user in Firebase Authentication manually, OR
2. Modify `lib/screens/auth/login_screen.dart` to add admin-specific validation
3. Store admin credentials securely (consider using environment variables)

## Step 7: Run the App

```bash
# For Android
flutter run

# For iOS
flutter run

# For specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

## Step 8: Testing Offline/Online Sync

1. **Test Offline Mode:**
   - Turn off device internet/WiFi
   - Submit an application or report
   - Data should be saved locally
   - Turn internet back on
   - Data should sync automatically

2. **Test Online Mode:**
   - Ensure device is connected
   - Submit data
   - Check Firebase Console to verify data is saved
   - Check local database is also updated

## Troubleshooting

### Isar Code Generation Issues:
- Run: `flutter clean`
- Then: `flutter pub get`
- Finally: `flutter pub run build_runner build --delete-conflicting-outputs`

### Firebase Issues:
- Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in correct location
- Verify Firebase project is properly configured
- Check Firebase console for any errors

### Build Issues:
- Run `flutter clean`
- Delete `build/` folder
- Run `flutter pub get`
- Try building again

## Next Steps

1. **Customize Theme:** Edit `lib/utils/theme.dart`
2. **Add Form Fields:** Update application form as per company requirements
3. **Configure Notifications:** Set up Firebase Cloud Messaging for push notifications
4. **Add Admin Features:** Implement admin password and additional admin features
5. **Testing:** Test all user flows (Client, Staff, Admin)

## Notes

- The app uses Firebase Firestore for cloud storage (not MongoDB Atlas as initially considered)
- Isar is used for local/offline storage
- Automatic sync happens when device comes online
- Dark theme is set as default (can be changed in `lib/providers/theme_provider.dart`)

