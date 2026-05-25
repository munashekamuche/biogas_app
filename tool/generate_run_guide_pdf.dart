// ignore_for_file: avoid_print
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> main() async {
  final doc = pw.Document(
    title: 'Biogas Service Management App - Complete Run Guide',
    author: 'REA Service Application',
  );

  final sections = _buildSections();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Text(
          'Biogas Service Management App',
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ),
      build: (context) => sections,
    ),
  );

  final outDir = Directory('docs');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);
  final outFile = File('docs/Complete_System_Run_Guide.pdf');
  await outFile.writeAsBytes(await doc.save());
  print('PDF created: ${outFile.path}');
}

List<pw.Widget> _buildSections() {
  return [
  _cover(),
  _h1('Table of Contents'),
  _toc(),
  _h1('1. System Overview'),
  _p(
    'The Biogas Service Management App (branded in the UI as REA Service Application) is a Flutter-based digital service delivery platform for Grid, Solar, and Biogas solutions. One codebase supports Android, iOS, and Web.',
  ),
  _p('The system serves four user roles:'),
  _bullets([
    'Client (mobile): registers, selects a regional office, submits service applications, tracks status.',
    'Staff (mobile): logs in with email, submits field reports, optionally linked to office and station.',
    'Admin (mobile/web): national oversight of all offices, users, applications, and reports.',
    'Office (web recommended): regional portal; sees only data for assigned officeId.',
  ]),
  _p('Backend: Firebase Authentication, Cloud Firestore, Firebase Storage. Local offline storage: Isar database on device.'),
  _h1('2. Prerequisites'),
  _bullets([
    'Flutter SDK 3.0 or higher. Verify with: flutter doctor',
    'Git (to clone from GitHub)',
    'Firebase account and a Firebase project',
    'IDE: VS Code or Android Studio (recommended)',
    'For Android: Android Studio, SDK, emulator or physical device with USB debugging',
    'For iOS (macOS only): Xcode, CocoaPods, simulator or device',
    'For Web: Chrome browser',
    'Optional: Firebase CLI (npm install -g firebase-tools) for deploying rules and indexes',
  ]),
  _h1('3. Get the Source Code'),
  _p('Repository: https://github.com/munashekamuche/biogas_app.git'),
  _code('git clone https://github.com/munashekamuche/biogas_app.git\ncd biogas_app'),
  _p('Open the project folder in your IDE. Project root contains pubspec.yaml, lib/, android/, ios/, web/, firestore.rules, firestore.indexes.json, README.md, and SETUP_GUIDE.md.'),
  _h1('4. Install Flutter Dependencies'),
  _p('From the project root, run:'),
  _code('flutter pub get'),
  _p('This downloads all packages listed in pubspec.yaml including provider, isar, firebase_core, cloud_firestore, firebase_auth, connectivity_plus, pdf, printing, and others.'),
  _h1('5. Generate Isar Database Code'),
  _p('The app uses Isar for offline storage. Generated code is NOT committed to Git (.gitignore excludes *.g.dart). You MUST run code generation after clone:'),
  _code('dart run build_runner build --delete-conflicting-outputs'),
  _p('This creates lib/models/isar_models.g.dart from lib/models/isar_models.dart. Re-run whenever isar_models.dart changes.'),
  _p('If generation fails due to syntax errors in lib/, fix those first, then:'),
  _code('flutter clean\nflutter pub get\ndart run build_runner build --delete-conflicting-outputs'),
  _h1('6. Firebase Project Setup'),
  _h2('6.1 Create Firebase Project'),
  _numbered([
    'Go to https://console.firebase.google.com/',
    'Click Add project and follow the wizard.',
    'Note your project ID (e.g. bgasapp).',
  ]),
  _h2('6.2 Enable Firestore'),
  _numbered([
    'Firebase Console > Build > Firestore Database > Create database.',
    'For development, start in test mode; choose a region close to users.',
    'For production, deploy firestore.rules from this repo and switch to production rules.',
  ]),
  _h2('6.3 Enable Authentication'),
  _numbered([
    'Firebase Console > Build > Authentication > Get started.',
    'Sign-in method > Email/Password > Enable > Save.',
  ]),
  _h2('6.4 Optional: Firebase Storage'),
  _p('Enable Storage if you plan to upload documents or images via storage_service.dart.'),
  _h1('7. Register Mobile Apps in Firebase'),
  _h2('7.1 Android'),
  _p('Current applicationId in android/app/build.gradle.kts: com.ref.bgas_app'),
  _numbered([
    'Firebase Console > Project settings > Your apps > Add app > Android.',
    'Register package name: com.ref.bgas_app (must match applicationId exactly).',
    'Download google-services.json.',
    'Place file at: android/app/google-services.json (NOT android/ root).',
    'The Google Services Gradle plugin is already configured in build.gradle.kts.',
  ]),
  _h2('7.2 iOS (optional)'),
  _numbered([
    'Firebase Console > Add app > iOS.',
    'Use bundle ID from ios/Runner/Info.plist.',
    'Download GoogleService-Info.plist.',
    'Place at: ios/Runner/GoogleService-Info.plist.',
    'Run: cd ios && pod install (on macOS).',
  ]),
  _h2('7.3 Web (optional)'),
  _numbered([
    'Firebase Console > Add app > Web.',
    'Copy Firebase config; Flutter web uses the same google-services / Firebase options as configured for your platform.',
    'Ensure Firebase project allows web auth domain if hosting separately.',
  ]),
  _p('IMPORTANT: google-services.json and GoogleService-Info.plist are gitignored. Each developer and CI machine must add them locally. Never commit secrets to public repos.'),
  _h1('8. Deploy Firestore Rules and Indexes'),
  _p('Multi-office queries require composite indexes. Security requires deployed rules.'),
  _h2('8.1 Install Firebase CLI'),
  _code('npm install -g firebase-tools\nfirebase login\nfirebase init firestore'),
  _p('Select your Firebase project. Use existing firestore.rules and firestore.indexes.json from project root when prompted.'),
  _h2('8.2 Deploy'),
  _code('firebase deploy --only firestore:rules\nfirebase deploy --only firestore:indexes'),
  _p('Indexes in firestore.indexes.json include: users (role + officeId), applications (officeId + submittedAt), reports (officeId + submittedAt). Without indexes, office portal queries may fail with a console link to create the index.'),
  _h1('9. Assets and Branding'),
  _p('Required asset folders (see pubspec.yaml):'),
  _bullets([
    'assets/logo/company_logo.png - splash and login logo (512x512 recommended)',
    'assets/images/grid_solar.png - Grid/Solar service card image',
    'assets/images/biogas.png - Biogas service card image',
    'assets/config/form_fields.json - optional local form field definitions',
  ]),
  _p('After adding assets, run flutter pub get if you changed pubspec.yaml asset paths.'),
  _h1('10. Run the Application'),
  _h2('10.1 List devices'),
  _code('flutter devices'),
  _h2('10.2 Android'),
  _code('flutter run\n# or\nflutter run -d <android-device-id>'),
  _p('First launch: Splash screen > Intro (once) > Login. Ensure emulator/device has Google Play if using Firebase on Android.'),
  _h2('10.3 iOS (macOS)'),
  _code('flutter run -d ios'),
  _h2('10.4 Web (Office portal & Admin)'),
  _code('flutter run -d chrome\n# production build:\nflutter build web'),
  _p('Output in build/web/. Host on Firebase Hosting, Netlify, or any static host. Web layout uses max width 1200px in main.dart MaterialApp.builder.'),
  _h1('11. Bootstrap the System (First Run)'),
  _p('Follow this order before end users can use the system:'),
  _h2('11.1 Create National Admin'),
  _p('Method A - Firebase Console (recommended for production):'),
  _numbered([
    'Authentication > Users > Add user (email + password).',
    'Copy the User UID.',
    'Firestore > users collection > Add document with Document ID = UID.',
    'Fields: id, fullName, surname, nationalId, phoneNumber, email, role: admin, createdAt (timestamp).',
  ]),
  _p('Method B - In-app (development only): Login screen may link to /create-admin (CreateAdminScreen). Remove this route before production.'),
  _h2('11.2 Login as Admin'),
  _numbered([
    'Open app > Login.',
    'Enter admin email and password (role auto-detected from Firestore user document).',
    'You are routed to Admin Dashboard (/admin-dashboard).',
  ]),
  _h2('11.3 Create Regional Offices'),
  _numbered([
    'Admin Dashboard > Offices tab.',
    'Tap Add office. Enter office name and optional region.',
    'Office appears in Firestore offices collection with active: true.',
    'Toggle active switch to disable an office without deleting.',
  ]),
  _p('Clients cannot register until at least one active office exists (Register screen loads active offices).'),
  _h2('11.4 Create Office Portal User (Web)'),
  _numbered([
    'Admin > Offices tab > Office web login (or navigate to /add-office-portal-user).',
    'Select office, enter full name, surname, email, password.',
    'User is created with role: office and officeId set.',
    'Share credentials with regional office staff.',
  ]),
  _h2('11.5 Create Staff Accounts'),
  _numbered([
    'Admin Dashboard > Staff tab > Add Staff (/add-staff).',
    'Fill form including station and optional regional office.',
    'Staff receives email + password; role is staff in Firestore.',
  ]),
  _h2('11.6 Client Registration (Mobile)'),
  _numbered([
    'User opens app > Register.',
    'Select regional office from dropdown.',
    'Enter name, surname, phone, password.',
    'Client login uses phone-based pseudo-email: {phoneDigits}@rea.client',
    'After login, client can request Grid/Solar/Biogas services and submit application forms.',
  ]),
  _h1('12. Daily Operation by Role'),
  _h2('12.1 Client flow'),
  _numbered([
    'Login with name, surname, phone, password.',
    'Home > Service Request > choose Grid/Solar or Biogas.',
    'Complete application form; submit (online or offline).',
    'View applications list and status; check notifications.',
  ]),
  _h2('12.2 Staff flow'),
  _numbered([
    'Login with email and password.',
    'Staff Home > Create Report.',
    'Enter report content; submit (syncs when online).',
    'View own submitted reports.',
  ]),
  _h2('12.3 Office portal flow (Web)'),
  _numbered([
    'Login with office portal email (role: office).',
    'Office Dashboard: Applications, Reports, Clients tabs (filtered by officeId).',
    'Open pending application > Approve, Reject, or In progress.',
  ]),
  _h2('12.4 Admin flow'),
  _numbered([
    'View all applications and reports nationally.',
    'Manage staff, clients, offices.',
    'Export/print where implemented in admin dashboard.',
  ]),
  _h1('13. Data Model Reference'),
  _p('Firestore collections:'),
  _bullets([
    'users: id, fullName, surname, nationalId, phoneNumber, email, role, officeId?, station?, createdAt',
    'offices: id, name, region?, active, createdAt',
    'applications: id, userId, officeId, serviceType, biogasType, formData, status, submittedAt, updatedAt',
    'reports: id, userId, officeId, staffName, station, content, submittedAt',
    'notifications: userId, title, message, type, read, createdAt',
    'form_configs: optional dynamic form definitions per service type',
  ]),
  _h1('14. Offline and Sync'),
  _p('When device is offline:'),
  _bullets([
    'Applications and reports save to Isar with needsSync = true.',
    'Reads fall back to local Isar data.',
    'When connectivity returns, SyncService pushes pending records to Firestore.',
  ]),
  _p('Test offline: disable WiFi/mobile data, submit application or report, re-enable network, verify in Firebase Console.'),
  _h1('15. Application Forms'),
  _p('Forms load via FormConfigService with priority: Firestore form_configs > assets/config/form_fields.json > code defaults in form_config_service.dart.'),
  _p('Grid/Solar uses sectioned form; Biogas/Solar homestead vs institutional fields differ. Customize via Firestore or JSON without code changes where supported.'),
  _h1('16. Troubleshooting'),
  _table([
    ['Problem', 'Solution'],
    ['Isar / build_runner fails', 'Fix lib/ syntax errors; flutter clean; pub get; rebuild runner'],
    ['Firebase init error', 'Verify google-services.json path and package name match'],
    ['User profile not found', 'Create Firestore users/{uid} doc matching Auth UID'],
    ['Missing Firestore index', 'Deploy firestore.indexes.json or use console link'],
    ['Office portal empty', 'Ensure applications have officeId; deploy indexes; check rules'],
    ['Client cannot register', 'Create at least one active office in Admin > Offices'],
    ['Permission denied Firestore', 'Deploy and review firestore.rules for role/officeId'],
    ['Web blank or layout issues', 'flutter build web; check browser console; verify Firebase web config'],
  ]),
  _h1('17. Production Checklist'),
  _bullets([
    'Remove or protect /create-admin route and CreateAdminScreen.',
    'Deploy production Firestore rules (not test mode).',
    'Deploy all composite indexes.',
    'Use strong passwords; never commit Firebase config secrets to public repos.',
    'Configure Android release signing (not debug keys).',
    'Enable Firebase App Check if required.',
    'Set up Firebase Hosting for web portal if using office users on web.',
    'Plan backup and audit strategy for Firestore data.',
    'Push notifications (FCM) not enabled in pubspec yet - add firebase_messaging when needed.',
  ]),
  _h1('18. Quick Command Reference'),
  _code('flutter doctor\nflutter pub get\ndart run build_runner build --delete-conflicting-outputs\nflutter devices\nflutter run\nflutter run -d chrome\nflutter build web\nflutter build apk\nfirebase deploy --only firestore:rules,firestore:indexes\nflutter clean'),
  _h1('19. Support Files in Repository'),
  _bullets([
    'README.md - architecture and feature overview',
    'SETUP_GUIDE.md - setup steps',
    'ADMIN_SETUP.md - admin account creation',
    'ACCOUNT_CREATION_GUIDE.md - admin and staff accounts',
    'FIREBASE_SETUP.md - Firebase registration details',
    'firestore.rules - security rules template',
    'firestore.indexes.json - required composite indexes',
  ]),
  _p('Document generated for Biogas Service Management App. For updates, regenerate with: dart run tool/generate_run_guide_pdf.dart'),
  ];
}

pw.Widget _cover() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 80),
      pw.Text(
        'Biogas Service Management App',
        style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 8),
      pw.Text(
        'REA Service Application',
        style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
      ),
      pw.SizedBox(height: 24),
      pw.Text(
        'Complete System Run Guide',
        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
      ),
      pw.SizedBox(height: 16),
      pw.Text('Every step to install, configure Firebase, bootstrap offices and users, and run on mobile and web.'),
      pw.SizedBox(height: 40),
      pw.Divider(),
      pw.SizedBox(height: 12),
      pw.Text('Includes: Flutter setup, Isar codegen, Firebase, Firestore rules/indexes, role bootstrap, offline sync, troubleshooting, production checklist.'),
      pw.SizedBox(height: 200),
      pw.Text('GitHub: github.com/munashekamuche/biogas_app', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
    ],
  );
}

pw.Widget _h1(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 16, bottom: 8),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
    );

pw.Widget _h2(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10, bottom: 6),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
    );

pw.Widget _p(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.4)),
    );

pw.Widget _code(String text) => pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.circular(4)),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 9, font: pw.Font.courier())),
    );

pw.Widget _bullets(List<String> items) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: items
          .map((e) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 8, bottom: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('• ', style: const pw.TextStyle(fontSize: 10)),
                    pw.Expanded(child: pw.Text(e, style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.3))),
                  ],
                ),
              ))
          .toList(),
    );

pw.Widget _numbered(List<String> items) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 4, bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 18,
                  child: pw.Text('${i + 1}.', style: const pw.TextStyle(fontSize: 10)),
                ),
                pw.Expanded(child: pw.Text(items[i], style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.3))),
              ],
            ),
          ),
      ],
    );

pw.Widget _table(List<List<String>> rows) => pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: {0: const pw.FlexColumnWidth(2), 1: const pw.FlexColumnWidth(3)},
      children: rows
          .map((row) => pw.TableRow(
                children: row
                    .map((cell) => pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(cell, style: const pw.TextStyle(fontSize: 9)),
                        ))
                    .toList(),
              ))
          .toList(),
    );

pw.Widget _toc() => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final line in [
          '1. System Overview',
          '2. Prerequisites',
          '3. Get the Source Code',
          '4. Install Flutter Dependencies',
          '5. Generate Isar Database Code',
          '6. Firebase Project Setup',
          '7. Register Mobile Apps in Firebase',
          '8. Deploy Firestore Rules and Indexes',
          '9. Assets and Branding',
          '10. Run the Application',
          '11. Bootstrap the System (First Run)',
          '12. Daily Operation by Role',
          '13. Data Model Reference',
          '14. Offline and Sync',
          '15. Application Forms',
          '16. Troubleshooting',
          '17. Production Checklist',
          '18. Quick Command Reference',
          '19. Support Files in Repository',
        ])
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Text(line, style: const pw.TextStyle(fontSize: 10)),
          ),
      ],
    );
