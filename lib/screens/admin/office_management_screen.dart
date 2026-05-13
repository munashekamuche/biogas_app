import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/office_model.dart';
import '../../services/office_service.dart';
import '../../utils/app_router.dart';
import '../../utils/theme.dart';

class OfficeManagementScreen extends StatelessWidget {
  final bool embedded;

  const OfficeManagementScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final officeService = OfficeService();

    final streamBody = StreamBuilder<List<OfficeModel>>(
      stream: officeService.watchAllOffices(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final offices = snap.data!;
        if (offices.isEmpty) {
          return Center(
            child: Text(
              'No offices yet. Tap Add office.',
              style: TextStyle(fontSize: 15.sp),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 80.h),
          itemCount: offices.length,
          itemBuilder: (context, i) {
            final o = offices[i];
            return Card(
              child: SwitchListTile(
                title: Text(o.name),
                subtitle: Text(o.region ?? '—'),
                value: o.active,
                onChanged: (v) =>
                    officeService.updateOfficeActive(officeId: o.id, active: v),
              ),
            );
          },
        );
      },
    );

    final fab = FloatingActionButton.extended(
      onPressed: () => _promptAddOffice(context, officeService),
      icon: const Icon(Icons.add),
      label: const Text('Add office'),
    );

    if (embedded) {
      return Stack(
        children: [
          Positioned.fill(child: streamBody),
          Positioned(
            right: 16,
            bottom: 16,
            child: fab,
          ),
          Positioned(
            left: 12,
            top: 8,
            child: TextButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRouter.addOfficePortalUser),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Office web login'),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offices'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Add office portal user',
            onPressed: () =>
                Navigator.pushNamed(context, AppRouter.addOfficePortalUser),
          ),
        ],
      ),
      body: streamBody,
      floatingActionButton: fab,
    );
  }

  Future<void> _promptAddOffice(BuildContext context, OfficeService svc) async {
    final nameCtrl = TextEditingController();
    final regionCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New regional office'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Office name'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: regionCtrl,
                decoration: const InputDecoration(labelText: 'Region (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final err = await svc.createOffice(
                name: nameCtrl.text,
                region: regionCtrl.text.trim().isEmpty ? null : regionCtrl.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(err ?? 'Office created')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
