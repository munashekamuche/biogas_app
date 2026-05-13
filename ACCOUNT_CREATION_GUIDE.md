# Account Creation Guide

This guide explains how to create Admin and Staff accounts for the Biogas Service Management App.

## Creating an Admin Account

### Method 1: Using the App (Development Only)

1. **Launch the app** and navigate to the Login screen
2. **Click on "Create Admin Account (Dev)"** button at the bottom of the login screen
3. **Fill in the form** with the following information:
   - Email: `admin@example.com` (or your preferred email)
   - Password: Choose a strong password (minimum 6 characters)
   - Full Name: `Admin`
   - Surname: `User`
   - National ID: `ADMIN001` (or any unique ID)
   - Phone Number: `+1234567890` (or your phone number)
4. **Click "Create Admin Account"**
5. **Save the credentials** displayed in the success message

### Method 2: Direct Navigation

You can also navigate directly to the create admin screen by using the route:
- Route: `/create-admin`
- Or programmatically: `Navigator.pushNamed(context, AppRouter.createAdmin)`

## Creating a Staff Account

### Prerequisites
- You must have an Admin account created first
- You must be logged in as an Admin

### Steps

1. **Login as Admin** using the admin credentials you created
2. **Navigate to the Admin Dashboard** (you'll be automatically redirected after login)
3. **Click on the "Staff" tab** in the top navigation
4. **Click the "Add Staff" floating action button** (green button with + icon)
5. **Fill in the staff form** with:
   - Full Name: `John` (or staff member's first name)
   - Surname: `Doe` (or staff member's surname)
   - National ID: `123456789` (or staff member's ID)
   - Phone Number: `+1234567890` (or staff member's phone)
   - Email: `staff@example.com` (or staff member's email)
   - Password: Choose a strong password (minimum 6 characters)
   - Station: `Main Station` (or the station name where staff works)
6. **Click "Create Staff Account"**
7. **Share the credentials** with the staff member (email and password will be displayed)

## Account Credentials Summary

After creating accounts, you'll receive:
- **Email address** (used for login)
- **Password** (used for login)
- **Role** (admin or staff)

**Important:** Save these credentials securely. The password is only shown once during account creation.

## Login Instructions

### For Admin:
1. Open the app
2. Select "Admin" from the "Login As" dropdown
3. Enter admin email and password
4. Click "Login"
5. You'll be redirected to the Admin Dashboard

### For Staff:
1. Open the app
2. Select "Staff" from the "Login As" dropdown
3. Enter staff email and password
4. Click "Login"
5. You'll be redirected to the Staff Dashboard

## Example Credentials

### Admin Account Example:
```
Email: admin@biogas.com
Password: Admin123!
Full Name: Admin
Surname: User
National ID: ADMIN001
Phone: +1234567890
```

### Staff Account Example:
```
Email: staff@biogas.com
Password: Staff123!
Full Name: John
Surname: Doe
National ID: 123456789
Phone: +1234567890
Station: Main Station
```

## Troubleshooting

### "Email already in use" Error
- The email address is already registered in Firebase Authentication
- Use a different email address or check if the account already exists

### "User does not exist" Error
- Make sure you're using the correct email address
- Verify the account was created successfully

### Can't Access Create Admin Screen
- The create admin screen is a development utility
- In production, this should be removed or protected
- For production, create admin accounts through Firebase Console

## Security Notes

⚠️ **Important Security Considerations:**

1. **Development Only**: The "Create Admin Account" button on the login screen is for development purposes only. Remove or protect this in production.

2. **Password Strength**: Always use strong passwords (minimum 8 characters, mix of letters, numbers, and symbols).

3. **Credential Storage**: Never commit credentials to version control. Store them securely.

4. **Production Deployment**: Before deploying to production:
   - Remove the create admin button from the login screen
   - Protect the `/create-admin` route
   - Use Firebase Admin SDK or Firebase Console for account creation

## Next Steps

After creating accounts:
1. Test login with both admin and staff accounts
2. Verify that admin can access the admin dashboard
3. Verify that staff can access the staff dashboard
4. Test creating a staff account from the admin dashboard
5. Test all admin features (viewing applications, reports, managing staff/clients)

