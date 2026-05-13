import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/app_router.dart';
import '../../utils/theme.dart';

class ServiceRequestScreen extends StatefulWidget {
  const ServiceRequestScreen({super.key});

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  void _navigateToApplicationForm(
    String serviceType, {
    String? connectionType,
  }) {
    Navigator.pushNamed(
      context,
      AppRouter.applicationForm,
      arguments: {
        'serviceType': serviceType,
        'biogasType': connectionType,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Service Type'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppTheme.primaryGreenDark,
                    const Color(0xFF121212),
                  ]
                : [
                    AppTheme.primaryGreen.withOpacity(0.05),
                    AppTheme.backgroundLight,
                  ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.construction,
                          size: 48.sp,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Choose a Service',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Select the type of service you need',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Grid Option
                _buildServiceCard(
                  context: context,
                  title: 'GRID',
                  subtitle: 'Power grid connection services',
                  icon: Icons.grid_on_outlined,
                  imagePath: 'assets/images/grid_solar.png',
                  gradientColors: [
                    AppTheme.accentBlue,
                    AppTheme.primaryGreen,
                  ],
                  onTap: () => _showConnectionTypeDialog('grid'),
                ),
                SizedBox(height: 20.h),

                // Solar Option
                _buildServiceCard(
                  context: context,
                  title: 'SOLAR',
                  subtitle: 'Solar power installation',
                  icon: Icons.solar_power,
                  imagePath: 'assets/images/grid_solar.png',
                  gradientColors: [
                    AppTheme.accentOrange,
                    Colors.orangeAccent,
                  ],
                  onTap: () => _showConnectionTypeDialog('solar'),
                ),
                SizedBox(height: 20.h),

                // Biogas Option
                _buildServiceCard(
                  context: context,
                  title: 'BIOGAS',
                  subtitle: 'Biogas energy systems',
                  icon: Icons.eco,
                  imagePath: 'assets/images/biogas.png',
                  gradientColors: [
                    AppTheme.primaryGreen,
                    AppTheme.primaryGreenLight,
                  ],
                  onTap: () => _showConnectionTypeDialog('biogas'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String imagePath,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Stack(
              children: [
                // Background Pattern
                Positioned(
                  right: -20.w,
                  top: -20.h,
                  child: Container(
                    width: 150.w,
                    height: 150.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: 32.sp,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white.withOpacity(0.8),
                            size: 20.sp,
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Container(
                          height: 180.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Icon(
                                  icon,
                                  size: 80.sp,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConnectionTypeDialog(String serviceType) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home_repair_service_outlined,
                  size: 48.sp,
                  color: AppTheme.primaryGreen,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Select Connection Type',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),
              _buildBiogasOption(
                icon: Icons.home,
                title: 'Homestead',
                subtitle: 'For household / residential systems',
                onTap: () {
                  Navigator.pop(context);
                  _navigateToApplicationForm(
                    serviceType,
                    connectionType: 'homestead',
                  );
                },
              ),
              SizedBox(height: 12.h),
              _buildBiogasOption(
                icon: Icons.business,
                title: 'Institutional',
                subtitle: 'For schools, clinics and other institutions',
                onTap: () {
                  Navigator.pop(context);
                  _navigateToApplicationForm(
                    serviceType,
                    connectionType: 'institutional',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiogasOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppTheme.primaryGreen.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryGreen,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
