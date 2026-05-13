import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../models/application_model.dart';
import '../../utils/theme.dart';
import '../../utils/app_router.dart';
import '../admin/client_management_screen.dart';

/// Web / desktop-friendly portal for regional office users (`role: office`).
/// Sees applications, reports, and clients for [AuthProvider.currentUser.officeId] only.
class OfficeDashboardScreen extends StatefulWidget {
  const OfficeDashboardScreen({super.key});

  @override
  State<OfficeDashboardScreen> createState() => _OfficeDashboardScreenState();
}

class _OfficeDashboardScreenState extends State<OfficeDashboardScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  void _reload() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final app = Provider.of<AppProvider>(context, listen: false);
    final oid = auth.currentUser?.officeId;
    if (oid == null || oid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your account has no office assigned. Contact admin.')),
      );
      return;
    }
    app.loadApplications(officeId: oid);
    app.loadReports(officeId: oid);
  }

  Future<void> _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final officeId = auth.currentUser?.officeId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Regional office portal'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: officeId.isEmpty
          ? const Center(child: Text('Missing office assignment'))
          : Column(
              children: [
                Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Row(
                    children: [
                      _tabBtn(0, 'Applications'),
                      _tabBtn(1, 'Reports'),
                      _tabBtn(2, 'Clients'),
                    ],
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _tab,
                    children: [
                      _ApplicationsPanel(officeId: officeId),
                      const _ReportsPanel(),
                      ClientManagementScreen(
                        officeIdFilter: officeId,
                        embedded: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _tabBtn(int i, String label) {
    final sel = _tab == i;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tab = i),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: sel ? AppTheme.primaryGreen : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              color: sel ? AppTheme.primaryGreen : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplicationsPanel extends StatelessWidget {
  final String officeId;

  const _ApplicationsPanel({required this.officeId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        if (app.isLoading && app.applications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final apps = app.applications;
        if (apps.isEmpty) {
          return const Center(child: Text('No applications for this office yet.'));
        }
        return ListView.builder(
          padding: EdgeInsets.all(12.w),
          itemCount: apps.length,
          itemBuilder: (context, i) {
            final a = apps[i];
            return Card(
              child: ListTile(
                title: Text(a.serviceType.replaceAll('_', ' ').toUpperCase()),
                subtitle: Text('${a.status} · ${DateFormat.yMMMd().format(a.submittedAt)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openApp(context, a),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openApp(BuildContext context, ApplicationModel a) async {
    final appProv = Provider.of<AppProvider>(context, listen: false);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (_, scroll) {
            return ListView(
              controller: scroll,
              padding: EdgeInsets.all(20.w),
              children: [
                Text('Application', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 12.h),
                Text('Status: ${a.status}'),
                Text('Service: ${a.serviceType}'),
                SizedBox(height: 16.h),
                if (a.status.toLowerCase() == 'pending') ...[
                  Text('Update status', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        label: const Text('Approve'),
                        onPressed: () async {
                          await appProv.updateApplicationStatus(
                            applicationId: a.id,
                            status: 'approved',
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                      ),
                      ActionChip(
                        label: const Text('Reject'),
                        onPressed: () async {
                          await appProv.updateApplicationStatus(
                            applicationId: a.id,
                            status: 'rejected',
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                      ),
                      ActionChip(
                        label: const Text('In progress'),
                        onPressed: () async {
                          await appProv.updateApplicationStatus(
                            applicationId: a.id,
                            status: 'in_progress',
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _ReportsPanel extends StatelessWidget {
  const _ReportsPanel();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        if (app.isLoading && app.reports.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final reports = app.reports;
        if (reports.isEmpty) {
          return const Center(child: Text('No reports for this office yet.'));
        }
        return ListView.builder(
          padding: EdgeInsets.all(12.w),
          itemCount: reports.length,
          itemBuilder: (context, i) {
            final r = reports[i];
            return Card(
              child: ListTile(
                title: Text(r.staffName),
                subtitle: Text(
                  '${DateFormat.yMMMd().format(r.submittedAt)}\n${r.content}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
