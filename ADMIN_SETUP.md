# Admin Account Setup Guide

This guide explains how to create an admin account for the Biogas Service Management App.

## Method 1: Create Admin Account via Firebase Console (Recommended)

### Step 1: Create User in Firebase Authentication

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (`bgasapp`)
3. Navigate to **Authentication** → **Users**
4. Click **Add user**
5. Enter:
   - **Email**: `admin@example.com` (or your admin email)
   - **Password**: Create a strong password
6. Click **Add user**

### Step 2: Create User Document in Firestore

1. In Firebase Console, go to **Firestore Database**
2. Navigate to the `users` collection
3. Click **Add document**
4. Set the **Document ID** to match the **User UID** from Step 1
5. Add the following fields:

```json
{
  "id": "<USER_UID_FROM_STEP_1>",
  "fullName": "Admin",
  "surname": "User",
  "nationalId": "ADMIN001",
  "phoneNumber": "+1234567890",
  "email": "admin@example.com",
  "role": "admin",
  "createdAt": "<CURRENT_TIMESTAMP>"
}
```

6. Click **Save**

### Step 3: Login as Admin

1. Open the app
2. On the login screen, select **Admin** from the role dropdown
3. Enter the email and password you created
4. Click **Login**

---

## Method 2: Create Admin Account Programmatically

You can also create an admin account using the utility function provided in `lib/utils/create_admin.dart`.

### Option A: If user already exists in Firebase Auth

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'lib/utils/create_admin.dart';

// Get the user UID from Firebase Auth
final auth = FirebaseAuth.instance;
final user = await auth.getUserByEmail('admin@example.com');

// Create admin document in Firestore
await createAdminAccount(
  email: 'admin@example.com',
  fullName: 'Admin',
  surname: 'User',
  nationalId: 'ADMIN001',
  phoneNumber: '+1234567890',
  userId: user.uid, // Provide the existing UID
);
```

### Option B: Create user and admin document together

```dart
import 'lib/utils/create_admin.dart';

await createAdminAccountWithAuth(
  email: 'admin@example.com',
  password: 'SecurePassword123!',
  fullName: 'Admin',
  surname: 'User',
  nationalId: 'ADMIN001',
  phoneNumber: '+1234567890',
);
```

**Note:** This method requires Firebase Auth to be initialized and you need to be authenticated as a user with admin privileges in Firebase.

---

## Admin Dashboard Features

Once logged in as admin, you can:

1. **View All Applications**
   - See statistics (Total, Pending, Approved, Rejected)
   - Filter by status (All, Pending, Approved, Rejected)
   - Search applications
   - View detailed application information

2. **Manage Applications**
   - Approve pending applications
   - Reject applications
   - View full form data

3. **View All Reports**
   - See all staff reports
   - Search reports
   - View report details

4. **Analytics**
   - Total applications count
   - Status breakdown
   - Monthly report statistics

---

## Default Admin Credentials (For Testing)

If you need to create a test admin account quickly:

**Email:** `admin@bgasapp.com`  
**Password:** `Admin123!` (change this in production!)

Then create the Firestore document as described in Method 1, Step 2.

---

## Security Notes

⚠️ **Important:**
- Never commit admin credentials to version control
- Use strong passwords for admin accounts
- Consider implementing role-based access control (RBAC) in Firebase Security Rules
- Regularly audit admin accounts
- Use Firebase Authentication's email verification for admin accounts

---

## Troubleshooting

### "User profile not found" error
- Ensure the Firestore document exists in the `users` collection
- Verify the document ID matches the Firebase Auth UID exactly
- Check that the `role` field is set to `"admin"`

### "Access denied" error
- Verify the user's role in Firestore is set to `"admin"`
- Make sure you selected "Admin" from the role dropdown on login
- Check that the user document exists and is properly formatted

### Cannot approve/reject applications
- Ensure you're connected to the internet
- Check Firebase Firestore permissions
- Verify the application document exists

