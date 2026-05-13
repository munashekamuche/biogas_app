import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../models/office_model.dart';
import '../../providers/user_provider.dart';
import '../../services/office_service.dart';
import '../../utils/theme.dart';

class AddOfficePortalUserScreen extends StatefulWidget {
  const AddOfficePortalUserScreen({super.key});

  @override
  State<AddOfficePortalUserScreen> createState() => _AddOfficePortalUserScreenState();
}

class _AddOfficePortalUserScreenState extends State<AddOfficePortalUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _surname = TextEditingController();
  final _nationalId = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _officeService = OfficeService();
  List<OfficeModel> _offices = [];
  String? _officeId;
  bool _loading = true;
  String? _msg;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final o = await _officeService.getAllOfficesOnce();
      if (mounted) {
        setState(() {
          _offices = o;
          if (o.length == 1) _officeId = o.first.id;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _fullName.dispose();
    _surname.dispose();
    _nationalId.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_officeId == null) {
      setState(() => _msg = 'Select an office');
      return;
    }
    setState(() {
      _busy = true;
      _msg = null;
    });
    final err = await Provider.of<UserProvider>(context, listen: false).createOfficePortalAccount(
      fullName: _fullName.text.trim(),
      surname: _surname.text.trim(),
      nationalId: _nationalId.text.trim(),
      phoneNumber: _phone.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      officeId: _officeId!,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _msg = err ?? 'Created. Share email and password with the office.';
    });
    if (err == null) _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add office portal user'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _officeId,
                      decoration: const InputDecoration(labelText: 'Office'),
                      items: _offices
                          .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _officeId = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _fullName,
                      decoration: const InputDecoration(labelText: 'Full name'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _surname,
                      decoration: const InputDecoration(labelText: 'Surname'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _nationalId,
                      decoration: const InputDecoration(labelText: 'National ID'),
                    ),
                    TextFormField(
                      controller: _phone,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'Login email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _password,
                      decoration: const InputDecoration(labelText: 'Temporary password'),
                      obscureText: true,
                      validator: (v) =>
                          v == null || v.length < 6 ? 'Min 6 characters' : null,
                    ),
                    SizedBox(height: 20.h),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create account'),
                    ),
                    if (_msg != null) ...[
                      SizedBox(height: 16.h),
                      Text(
                        _msg!,
                        style: TextStyle(
                          color: _msg!.startsWith('Created') ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

