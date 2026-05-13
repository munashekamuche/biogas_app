import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_router.dart';
import '../../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isClientLogin = false; // Toggle between client and staff/admin login
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    String emailToUse;
    final password = _passwordController.text;
    final inputValue = _emailController.text.trim();

    // Auto-detect login type: if input looks like phone number, use client login
    final phoneDigits = inputValue.replaceAll(RegExp(r'[^0-9]'), '');
    final isPhoneNumber = phoneDigits.length >= 9 && !inputValue.contains('@');

    if (isPhoneNumber || _isClientLogin) {
      // Client login: use phone number from either email field or phone field
      final phone = _phoneController.text.isNotEmpty 
          ? _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '')
          : phoneDigits;
      emailToUse = '$phone@rea.client';
    } else {
      // Staff/Admin login: use email directly
      emailToUse = inputValue;
    }

    // Login without role parameter - system will detect role from user profile
    final errorMessage = await authProvider.login(
      email: emailToUse,
      password: password,
      role: null, // Let system auto-detect role
    );

    if (!mounted) return;

    if (errorMessage == null) {
      // Success - navigate based on detected role
      final user = authProvider.currentUser!;

      // For clients, additionally verify entered name & surname match.
      final phoneDigits = _emailController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final isClientLoginAttempt = phoneDigits.length >= 9 && !_emailController.text.contains('@');
      
      if (user.role == 'client' && (isClientLoginAttempt || _isClientLogin)) {
        final enteredFullName = _fullNameController.text.trim().toLowerCase();
        final enteredSurname = _surnameController.text.trim().toLowerCase();

        if (enteredFullName.isNotEmpty &&
            enteredSurname.isNotEmpty &&
            (user.fullName.toLowerCase() != enteredFullName ||
                user.surname.toLowerCase() != enteredSurname)) {
          await authProvider.logout();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'The name or surname does not match this account. Please check your details.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 4),
            ),
          );
          return;
        }
      }

      // Auto-navigate based on user's role
      switch (user.role) {
        case 'client':
          Navigator.pushReplacementNamed(context, AppRouter.clientHome);
          break;
        case 'staff':
          Navigator.pushReplacementNamed(context, AppRouter.staffHome);
          break;
        case 'admin':
          Navigator.pushReplacementNamed(context, AppRouter.adminDashboard);
          break;
        case 'office':
          Navigator.pushReplacementNamed(context, AppRouter.officeDashboard);
          break;
        default:
          await authProvider.logout();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Unknown user role. Please contact support.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 4),
            ),
          );
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppTheme.primaryGreenDark,
                    const Color(0xFF121212),
                  ]
                : [
                    AppTheme.primaryGreen.withOpacity(0.1),
                    AppTheme.backgroundLight,
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo Section
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo/company_logo.png',
                          width: 80.w,
                          height: 80.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to icon if image fails to load
                            return Icon(
                              Icons.eco,
                              size: 64.sp,
                              color: AppTheme.primaryGreen,
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    
                    // Welcome Text
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Sign in to continue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40.h),
                    
                    // Email/Phone Login Field (for Staff/Admin or Client)
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address or Phone Number',
                        prefixIcon: Icon(Icons.email_outlined,
                            color: AppTheme.primaryGreen),
                        helperText: _isClientLogin 
                            ? 'Enter your phone number' 
                            : 'Enter your email address',
                      ),
                      style: TextStyle(fontSize: 16.sp),
                      onChanged: (value) {
                        // Auto-detect if it's a phone number (all digits) or email
                        final phoneDigits = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (phoneDigits.length >= 9 && !value.contains('@')) {
                          setState(() => _isClientLogin = true);
                        } else if (value.contains('@')) {
                          setState(() => _isClientLogin = false);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email or phone number';
                        }
                        // If it looks like a phone number, require client fields
                        final phoneDigits = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (phoneDigits.length >= 9 && !value.contains('@')) {
                          // Phone number - client login, but we'll handle validation in _handleLogin
                          return null;
                        }
                        // Email validation
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email or phone number';
                        }
                        return null;
                      },
                    ),
                    
                    // Client fields (shown when phone number is detected)
                    if (_isClientLogin) ...[
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person_outline,
                              color: AppTheme.primaryGreen),
                        ),
                        style: TextStyle(fontSize: 16.sp),
                        validator: (value) {
                          if (_isClientLogin && (value == null || value.isEmpty)) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _surnameController,
                        decoration: InputDecoration(
                          labelText: 'Surname',
                          prefixIcon: Icon(Icons.person_outline,
                              color: AppTheme.primaryGreen),
                        ),
                        style: TextStyle(fontSize: 16.sp),
                        validator: (value) {
                          if (_isClientLogin && (value == null || value.isEmpty)) {
                            return 'Please enter your surname';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_outlined,
                              color: AppTheme.primaryGreen),
                        ),
                        style: TextStyle(fontSize: 16.sp),
                        onChanged: (value) {
                          // Sync phone to email field if it's different
                          final phoneDigits = value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (phoneDigits.isNotEmpty && _emailController.text != value) {
                            _emailController.text = value;
                          }
                        },
                        validator: (value) {
                          if (_isClientLogin && (value == null || value.isEmpty)) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                    ],
                    SizedBox(height: 20.h),
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryGreen),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppTheme.textSecondary,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      style: TextStyle(fontSize: 16.sp),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32.h),
                    
                    // Login Button
                    Selector<AuthProvider, bool>(
                      selector: (context, authProvider) => authProvider.isLoading,
                      builder: (context, isLoading, _) {
                        return ElevatedButton(
                          key: const ValueKey('login_button'),
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 18.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 4,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 24.h,
                                  width: 24.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    
                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.forgotPassword);
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    
                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        Flexible(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRouter.register);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    // Development: Create Admin Button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.createAdmin);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.admin_panel_settings_outlined,
                              size: 14.sp,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 6.w),
                            Flexible(
                              child: Text(
                                'Create Admin Account (Dev)',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
