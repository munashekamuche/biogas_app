import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Responsive {
  static void init(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
    );
  }
  
  // Width helpers
  static double width(double width) => width.w;
  static double height(double height) => height.h;
  
  // Font size helpers
  static double fontSize(double size) => size.sp;
  
  // Radius helpers
  static double radius(double radius) => radius.r;
  
  // Screen dimensions
  static double get screenWidth => 1.sw;
  static double get screenHeight => 1.sh;
  
  // Responsive breakpoints
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width >= 600 && 
      MediaQuery.of(context).size.width < 1200;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;
}

