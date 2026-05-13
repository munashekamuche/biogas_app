import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/user_provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/theme.dart';

class ClientManagementScreen extends StatefulWidget {
  /// When set, only clients assigned to this office are loaded.
  final String? officeIdFilter;

  /// When true, no [Scaffold] wrapper (for embedding in office portal tabs).
  final bool embedded;

  const ClientManagementScreen({
    super.key,
    this.officeIdFilter,
    this.embedded = false,
  });

  @override
  State<ClientManagementScreen> createState() => _ClientManagementScreenState();
}

class _ClientManagementScreenState extends State<ClientManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final oid = widget.officeIdFilter;
      userProvider.loadClients(officeId: oid);
      if (oid != null && oid.isNotEmpty) {
        appProvider.loadApplications(officeId: oid);
      } else {
        appProvider.loadApplications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(20.w),
            color: Theme.of(context).cardColor,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search clients...',
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppTheme.textSecondary),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              style: TextStyle(fontSize: 16.sp),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Clients List
          Expanded(
            child: Consumer2<UserProvider, AppProvider>(
              builder: (context, userProvider, appProvider, _) {
                if (userProvider.isLoading) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.h),
                      child: const CircularProgressIndicator(),
                    ),
                  );
                }

                final clients = userProvider.clients;
                final applications = appProvider.applications;
                
                final filteredClients = _searchQuery.isEmpty
                    ? clients
                    : clients.where((c) {
                        final query = _searchQuery.toLowerCase();
                        return c.fullName.toLowerCase().contains(query) ||
                            c.surname.toLowerCase().contains(query) ||
                            c.email.toLowerCase().contains(query) ||
                            c.phoneNumber.contains(query);
                      }).toList();

                if (filteredClients.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64.sp,
                          color: AppTheme.textSecondary,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No clients yet'
                              : 'No clients found',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(20.w),
                  itemCount: filteredClients.length,
                  itemBuilder: (context, index) {
                    final client = filteredClients[index];
                    final clientApps = applications.where((a) => a.userId == client.id).toList();
                    final pendingApps = clientApps.where((a) => a.status.toLowerCase() == 'pending').length;
                    final approvedApps = clientApps.where((a) => a.status.toLowerCase() == 'approved').length;

                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        leading: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.person_outline,
                            color: Colors.blue,
                            size: 24.sp,
                          ),
                        ),
                        title: Text(
                          '${client.fullName} ${client.surname}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.email_outlined, size: 12.sp, color: AppTheme.textSecondary),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    client.email,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppTheme.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.phone_outlined, size: 12.sp, color: AppTheme.textSecondary),
                                SizedBox(width: 4.w),
                                Text(
                                  client.phoneNumber,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    '${clientApps.length} Applications',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (pendingApps > 0) ...[
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      '$pendingApps Pending',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                                if (approvedApps > 0) ...[
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      '$approvedApps Approved',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: AppTheme.textSecondary),
                          onSelected: (value) {
                            if (value == 'delete') {
                              _showDeleteDialog(client.id, client.fullName);
                            } else if (value == 'view_apps') {
                              _showClientApplications(client.id, client.fullName, clientApps);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'view_apps',
                              child: Row(
                                children: [
                                  Icon(Icons.description_outlined, color: AppTheme.primaryGreen, size: 20.sp),
                                  SizedBox(width: 12.w),
                                  Text('View Applications', style: TextStyle(fontSize: 14.sp)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: Colors.red, size: 20.sp),
                                  SizedBox(width: 12.w),
                                  Text('Delete', style: TextStyle(fontSize: 14.sp)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
    );
    return widget.embedded ? body : Scaffold(body: body);
  }

  void _showDeleteDialog(String clientId, String clientName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Delete Client', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete $clientName? This action cannot be undone.',
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              final success = await userProvider.deleteUser(
                clientId,
                'client',
                officeId: widget.officeIdFilter,
              );
              
              if (!mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? 'Client deleted successfully' : 'Failed to delete client'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  void _showClientApplications(String clientId, String clientName, List applications) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$clientName\'s Applications',
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: applications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64.sp, color: AppTheme.textSecondary),
                          SizedBox(height: 16.h),
                          Text(
                            'No applications',
                            style: TextStyle(fontSize: 16.sp, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(20.w),
                      itemCount: applications.length,
                      itemBuilder: (context, index) {
                        final app = applications[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    app.serviceType == 'biogas' ? Icons.eco : Icons.solar_power,
                                    color: AppTheme.primaryGreen,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    app.serviceType.toUpperCase().replaceAll('_', ' '),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(app.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      app.status,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: _getStatusColor(app.status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Submitted: ${_formatDate(app.submittedAt)}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

