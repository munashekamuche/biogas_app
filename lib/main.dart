import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'database/isar_service.dart';
import 'models/isar_models.dart';
import 'providers/auth_provider.dart';
import 'providers/app_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_router.dart';
import 'utils/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Continue anyway - app can work offline
  }
  
  // Initialize Isar database with error handling
  try {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [IsarUserSchema, IsarApplicationSchema, IsarReportSchema],
      directory: dir.path,
    );
    IsarService.instance = IsarService(isar);
  } catch (e) {
    debugPrint('Isar initialization error: $e');
    // This is critical - app needs database
    rethrow;
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: 'REA Service Application',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                home: const SplashScreen(),
                onGenerateRoute: AppRouter.generateRoute,
                builder: (context, child) {
                  final content = child ?? const SizedBox.shrink();
                  if (!kIsWeb) return content;
                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: content,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

