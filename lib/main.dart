import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'database/database_init.dart';
import 'providers/auth_provider.dart';
import 'providers/app_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_router.dart';
import 'utils/theme.dart';
import 'utils/firebase_bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeFirebase();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    if (kIsWeb) {
      debugPrint(
        'Web requires a Firebase Web app. In Firebase Console → Project settings → '
        'add a Web app, then run: dart pub global run flutterfire_cli:flutterfire configure',
      );
    }
  }

  if (!kIsWeb) {
    try {
      await initLocalDatabase();
    } catch (e) {
      debugPrint('Isar initialization error: $e');
      rethrow;
    }
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
