# Firebase Setup Checklist

## ✅ Completed Steps

- [x] Firebase project created
- [x] Android app registered in Firebase
- [x] `google-services.json` placed in `android/app/`
- [x] Google Services plugin configured in `android/app/build.gradle.kts`
- [x] Firebase initialized in `lib/main.dart`

## 🔍 Verify Firebase Services

### 1. Firestore Database
- [ ] Go to Firebase Console → Firestore Database
- [ ] Click "Create Database" if not already created
- [ ] Start in **Test Mode** (for development)
- [ ] Choose a location (closest to your users)

**Test Mode Rules** (for development):
```json
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 12, 31);
    }
  }
}
```

### 2. Authentication
- [ ] Go to Firebase Console → Authentication
- [ ] Click "Get Started" if not already enabled
- [ ] Enable **Email/Password** sign-in provider
- [ ] Save changes

### 3. Cloud Messaging (Optional - for Push Notifications)
- [ ] Go to Firebase Console → Cloud Messaging
- [ ] Follow setup instructions if you want push notifications

## 🧪 Test Firebase Connection

### Test 1: Run the App
```bash
flutter clean
flutter pub get
flutter run
```

**Expected Result**: App should launch without Firebase errors

### Test 2: Test Registration
1. Open the app
2. Click "Register"
3. Fill in registration form
4. Submit

**Expected Result**: 
- User should be created in Firebase Authentication
- User document should appear in Firestore `users` collection

### Test 3: Test Login
1. Use the credentials you just created
2. Login as "Client"
3. Navigate to home screen

**Expected Result**: Should login successfully and show client dashboard

### Test 4: Test Offline/Online Sync
1. Submit an application while online
2. Check Firestore - should see the application
3. Turn off internet/WiFi
4. Submit another application
5. Turn internet back on
6. Check Firestore - both applications should appear

**Expected Result**: Offline submissions sync when online

## 📋 Firestore Collections Structure

After testing, you should see these collections in Firestore:

### `users` Collection
```
users/
  └── {userId}/
      ├── id: string
      ├── fullName: string
      ├── surname: string
      ├── nationalId: string
      ├── phoneNumber: string
      ├── email: string
      ├── role: string (client/staff/admin)
      ├── station: string (for staff)
      └── createdAt: timestamp
```

### `applications` Collection
```
applications/
  └── {applicationId}/
      ├── id: string
      ├── userId: string
      ├── serviceType: string (grid_solar/biogas)
      ├── biogasType: string (homestead/institutional)
      ├── formData: map
      ├── status: string (pending/approved/rejected)
      ├── submittedAt: timestamp
      └── updatedAt: timestamp
```

### `reports` Collection
```
reports/
  └── {reportId}/
      ├── id: string
      ├── userId: string
      ├── staffName: string
      ├── station: string
      ├── content: string
      ├── submittedAt: timestamp
      └── updatedAt: timestamp
```

## 🚨 Common Issues & Solutions

### Issue: "FirebaseApp not initialized"
**Solution**: Make sure `google-services.json` is in `android/app/` (not `android/`)

### Issue: "Permission denied" in Firestore
**Solution**: Check Firestore rules - should be in test mode for development

### Issue: "Email/Password not enabled"
**Solution**: Enable Email/Password in Firebase Console → Authentication → Sign-in methods

### Issue: Build errors after adding Firebase
**Solution**: 
```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

## ✅ Next Steps After Firebase Setup

1. **Test all user flows**:
   - Client registration and login
   - Service request submission
   - Application form submission
   - Staff login and report creation
   - Admin login and dashboard access

2. **Configure Firestore Security Rules** (for production):
   - Update rules to restrict access based on user roles
   - Remove test mode rules

3. **Set up Admin User**:
   - Create admin user in Firebase Authentication
   - Or implement custom admin validation

4. **Add Assets**:
   - Company logo: `assets/logo/company_logo.png`
   - Service images: `assets/images/grid_solar.png` and `assets/images/biogas.png`

5. **Test Offline/Online Sync**:
   - Verify data syncs correctly when going offline/online

## 📞 Need Help?

If you encounter any issues:
1. Check Firebase Console for error logs
2. Check Flutter console for error messages
3. Verify all services are enabled in Firebase Console
4. Ensure `google-services.json` matches your package name

