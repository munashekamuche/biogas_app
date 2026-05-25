import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../services/application_service.dart';
import '../services/report_service.dart';
import '../utils/app_router.dart';
import '../utils/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
    _navigateToNext();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNext() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      // Check if this is the first launch to show introduction screen
      final prefs = await SharedPreferences.getInstance();
      final hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;

      if (!hasSeenIntro) {
        await prefs.setBool('hasSeenIntro', true);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRouter.intro);
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.loadUser();

      if (!kIsWeb) {
        try {
          await ApplicationService().syncPendingApplications();
          await ReportService().syncPendingReports();
        } catch (e) {
          debugPrint('Pending sync on startup: $e');
        }
      }
      
      if (!mounted) return;
      
      if (authProvider.isAuthenticated) {
        final user = authProvider.currentUser!;
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
            Navigator.pushReplacementNamed(context, AppRouter.login);
        }
      } else {
        Navigator.pushReplacementNamed(context, AppRouter.login);
      }
    } catch (e) {
      debugPrint('Error in splash navigation: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.login);
      }
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
                    AppTheme.primaryGreen,
                    AppTheme.primaryGreenLight,
                  ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final logoSize = kIsWeb ? 96.0 : 120.w;
              final logoPadding = kIsWeb ? 24.0 : 32.w;

              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32,
                    ),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(logoPadding),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100.r),
                                    child: Image.asset(
                                      'assets/logo/company_logo.png',
                                      height: logoSize,
                                      width: logoSize,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: logoSize,
                                          width: logoSize,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryGreen
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.eco,
                                            size: kIsWeb ? 48.0 : 60.sp,
                                            color: AppTheme.primaryGreen,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: kIsWeb ? 24 : 40.h),
                                Text(
                                  'REA Service Application',
                                  style: TextStyle(
                                    fontSize: kIsWeb ? 24 : 28.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: kIsWeb ? 8 : 8.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                                  child: Text(
                                    'Rural Electrification Fund & Installation Services',
                                    style: TextStyle(
                                      fontSize: kIsWeb ? 14 : 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.9),
                                      letterSpacing: 0.8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: kIsWeb ? 32 : 48.h),
                                SizedBox(
                                  width: kIsWeb ? 36 : 40.w,
                                  height: kIsWeb ? 36 : 40.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
