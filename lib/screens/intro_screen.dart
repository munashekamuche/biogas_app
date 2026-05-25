import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_router.dart';
import '../utils/theme.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final logoSize = kIsWeb ? 72.0 : 90.w;

              return SingleChildScrollView(
                padding: EdgeInsets.all(kIsWeb ? 24 : 24.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(kIsWeb ? 16 : 20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
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
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: kIsWeb ? 20 : 32.h),
                      Text(
                        'REA Service Application',
                        style: TextStyle(
                          fontSize: kIsWeb ? 22 : 26.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: kIsWeb ? 6 : 8.h),
                      Text(
                        'Rural Electrification Fund & Installation Services',
                        style: TextStyle(
                          fontSize: kIsWeb ? 14 : 16.sp,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: kIsWeb ? 20 : 32.h),
                      _buildIntroCard(
                        title: 'Grid Electrification',
                        description:
                            'Request connections to the national grid for homesteads and institutions, managed through the Rural Electrification Fund.',
                        icon: Icons.electric_bolt_outlined,
                        color: AppTheme.accentBlue,
                      ),
                      SizedBox(height: kIsWeb ? 12 : 16.h),
                      _buildIntroCard(
                        title: 'Solar Energy Solutions',
                        description:
                            'Get clean, reliable solar installations for homes and institutions, tailored to your energy needs.',
                        icon: Icons.solar_power,
                        color: AppTheme.accentOrange,
                      ),
                      SizedBox(height: kIsWeb ? 12 : 16.h),
                      _buildIntroCard(
                        title: 'Biogas Energy Systems',
                        description:
                            'Apply for biogas digesters that convert waste into clean cooking and lighting energy.',
                        icon: Icons.eco_outlined,
                        color: AppTheme.primaryGreen,
                      ),
                      SizedBox(height: kIsWeb ? 20 : 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRouter.login,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: kIsWeb ? 14 : 16.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: kIsWeb ? 16 : 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: kIsWeb ? 8 : 8.h),
                      Text(
                        'You can access this information any time from the Help or About sections in future versions.',
                        style: TextStyle(
                          fontSize: kIsWeb ? 11 : 12.sp,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
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
  }

  Widget _buildIntroCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


