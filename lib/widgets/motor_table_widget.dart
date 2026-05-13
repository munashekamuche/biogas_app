import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MotorTableWidget extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onMotorsChanged;
  final List<Map<String, dynamic>>? initialMotors;

  const MotorTableWidget({
    super.key,
    required this.onMotorsChanged,
    this.initialMotors,
  });

  @override
  State<MotorTableWidget> createState() => _MotorTableWidgetState();
}

class _MotorTableWidgetState extends State<MotorTableWidget> {
  final List<Map<String, TextEditingController>> _motorControllers = [];
  final TextEditingController _totalHpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize 5 rows for motors
    for (int i = 0; i < 5; i++) {
      _motorControllers.add({
        'hp': TextEditingController(),
        'plantDriven': TextEditingController(),
        'hoursPerDay': TextEditingController(),
        'daysPerMonth': TextEditingController(),
      });
    }

    // Load initial data if provided
    if (widget.initialMotors != null) {
      for (int i = 0; i < widget.initialMotors!.length && i < 5; i++) {
        final motor = widget.initialMotors![i];
        _motorControllers[i]['hp']!.text = motor['hp']?.toString() ?? '';
        _motorControllers[i]['plantDriven']!.text = motor['plantDriven']?.toString() ?? '';
        _motorControllers[i]['hoursPerDay']!.text = motor['hoursPerDay']?.toString() ?? '';
        _motorControllers[i]['daysPerMonth']!.text = motor['daysPerMonth']?.toString() ?? '';
      }
      _totalHpController.text = widget.initialMotors!
          .map((m) => double.tryParse(m['hp']?.toString() ?? '0') ?? 0)
          .fold(0.0, (sum, hp) => sum + hp)
          .toString();
    }

    // Add listeners to calculate total HP
    for (var controllers in _motorControllers) {
      controllers['hp']!.addListener(_calculateTotalHp);
    }
  }

  void _calculateTotalHp() {
    double total = 0;
    for (var controllers in _motorControllers) {
      final hp = double.tryParse(controllers['hp']!.text) ?? 0;
      total += hp;
    }
    _totalHpController.text = total.toStringAsFixed(2);
    _notifyChange();
  }

  void _notifyChange() {
    final motors = _motorControllers.map((controllers) {
      return {
        'hp': controllers['hp']!.text,
        'plantDriven': controllers['plantDriven']!.text,
        'hoursPerDay': controllers['hoursPerDay']!.text,
        'daysPerMonth': controllers['daysPerMonth']!.text,
      };
    }).toList();
    widget.onMotorsChanged(motors);
  }

  @override
  void dispose() {
    for (var controllers in _motorControllers) {
      for (var controller in controllers.values) {
        controller.dispose();
      }
    }
    _totalHpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MOTOR AND RUNNING TIME',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            SizedBox(height: 16.h),
            // Table Header
            Table(
              border: TableBorder.all(
                color: Colors.grey,
                width: 1,
                borderRadius: BorderRadius.circular(4.r),
              ),
              children: [
                // First header row - all 4 cells
                TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  children: [
                    _buildHeaderCell('H.P. OF MOTOR'),
                    _buildHeaderCell('PLANT DRIVEN'),
                    _buildHeaderCell('Hours per day'),
                    _buildHeaderCell('Days per month'),
                  ],
                ),
                // Motor rows
                ...List.generate(5, (index) {
                  return TableRow(
                    children: [
                      _buildCell(_motorControllers[index]['hp']!),
                      _buildCell(_motorControllers[index]['plantDriven']!),
                      _buildCell(_motorControllers[index]['hoursPerDay']!),
                      _buildCell(_motorControllers[index]['daysPerMonth']!),
                    ],
                  );
                }),
                // Total HP row
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  children: [
                    _buildTotalCell('TOTAL H.P', _totalHpController),
                    const SizedBox.shrink(),
                    const SizedBox.shrink(),
                    const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCell(TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
        keyboardType: controller == _motorControllers.first['hp'] ||
                controller == _motorControllers.first['hoursPerDay'] ||
                controller == _motorControllers.first['daysPerMonth']
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        ),
        onChanged: (_) => _notifyChange(),
      ),
    );
  }

  Widget _buildTotalCell(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

