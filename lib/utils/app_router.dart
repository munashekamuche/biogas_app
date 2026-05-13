import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/client/client_home_screen.dart';
import '../screens/client/service_request_screen.dart';
import '../screens/client/application_form_screen.dart';
import '../screens/client/notifications_screen.dart';
import '../screens/client/gallery_screen.dart';
import '../screens/client/profile_screen.dart';
import '../screens/client/application_details_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/intro_screen.dart';
import '../models/application_model.dart';
import '../screens/staff/staff_home_screen.dart';
import '../screens/staff/report_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/create_admin_screen.dart';
import '../screens/admin/add_staff_screen.dart';
import '../screens/admin/office_management_screen.dart';
import '../screens/admin/add_office_portal_user_screen.dart';
import '../screens/office/office_dashboard_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String clientHome = '/client-home';
  static const String serviceRequest = '/service-request';
  static const String applicationForm = '/application-form';
  static const String notifications = '/notifications';
  static const String gallery = '/gallery';
  static const String profile = '/profile';
  static const String applicationDetails = '/application-details';
  static const String forgotPassword = '/forgot-password';
  static const String staffHome = '/staff-home';
  static const String staffReport = '/staff-report';
  static const String adminDashboard = '/admin-dashboard';
  static const String createAdmin = '/create-admin'; // Development only - remove in production
  static const String addStaff = '/add-staff';
  static const String officeManagement = '/office-management';
  static const String addOfficePortalUser = '/add-office-portal-user';
  static const String officeDashboard = '/office-dashboard';
  static const String intro = '/intro';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case clientHome:
        return MaterialPageRoute(builder: (_) => const ClientHomeScreen());
      case serviceRequest:
        return MaterialPageRoute(builder: (_) => const ServiceRequestScreen());
      case applicationForm:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ApplicationFormScreen(
            serviceType: args?['serviceType'],
          ),
        );
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case gallery:
        return MaterialPageRoute(builder: (_) => const GalleryScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case applicationDetails:
        final args = settings.arguments as ApplicationModel?;
        if (args == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('Application not found')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ApplicationDetailsScreen(application: args),
        );
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case staffHome:
        return MaterialPageRoute(builder: (_) => const StaffHomeScreen());
      case staffReport:
        return MaterialPageRoute(builder: (_) => const ReportScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case createAdmin:
        return MaterialPageRoute(builder: (_) => const CreateAdminScreen());
      case addStaff:
        return MaterialPageRoute(builder: (_) => const AddStaffScreen());
      case officeManagement:
        return MaterialPageRoute(builder: (_) => const OfficeManagementScreen());
      case addOfficePortalUser:
        return MaterialPageRoute(builder: (_) => const AddOfficePortalUserScreen());
      case officeDashboard:
        return MaterialPageRoute(builder: (_) => const OfficeDashboardScreen());
      case intro:
        return MaterialPageRoute(builder: (_) => const IntroScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

