import 'package:clockin_app/controllers/attendance_controller.dart';
import 'package:clockin_app/core/constants/app_colors.dart';
import 'package:clockin_app/data/local_storage/session_manager.dart';
import 'package:clockin_app/data/models/attendance_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final AttendanceController _attendanceController = AttendanceController();
  DateTime? _selectedDate;
  final TextEditingController _reasonController = TextEditingController();
  String? _selectedRequestType; // To store the selected request type

  final List<String> _requestTypes = [
    'Absent',
    'Leave',
    'Sick',
    'Permission',
    'Business Trip',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: AppColors.textDark, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_selectedDate == null) {
      _showSnackBar('Please select a date.');
      return;
    }
    if (_reasonController.text.isEmpty) {
      _showSnackBar('Please enter a reason for the request.');
      return;
    }
    if (_selectedRequestType == null) {
      _showSnackBar('Please select a request type.');
      return;
    }

    final userId = await SessionManager().getUserIdAsInt();
    if (userId == null) {
      _showSnackBar('User not logged in. Cannot submit request.');
      return;
    }

    final requestDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final attendance = AttendanceModel(
      userId: userId,
      date: requestDate,
      status: 'Requested', // A new status for requests
      type: _selectedRequestType,
      reason: _reasonController.text.trim(),
      // timeIn and timeOut are null for requests
    );

    try {
      await _attendanceController.insertRequest(attendance);
      _showSnackBar('Request submitted successfully!');
      Navigator.pop(context, true); // Pop with true to indicate success
    } catch (e) {
      _showSnackBar('Failed to submit request: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Request'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Picker
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Select Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                  ),
                ),
                baseStyle: const TextStyle(color: AppColors.textDark),
                child: Text(
                  _selectedDate == null
                      ? 'No date chosen'
                      : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Request Type Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Request Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: AppColors.inputFill,
                prefixIcon: const Icon(
                  Icons.category,
                  color: AppColors.primary,
                ),
              ),
              value: _selectedRequestType,
              hint: const Text('Select request type'),
              items: _requestTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedRequestType = newValue;
                });
              },
            ),
            const SizedBox(height: 20),

            // Reason Text Field
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Reason for Request',
                hintText: 'e.g., Annual leave, sick leave, personal matters',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: AppColors.inputFill,
                prefixIcon: const Icon(
                  Icons.edit_note,
                  color: AppColors.primary,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),

            // Submit Button
            ElevatedButton.icon(
              onPressed: _submitRequest,
              icon: const Icon(Icons.send, color: AppColors.inputFill),
              label: const Text(
                'Submit Request',
                style: TextStyle(color: AppColors.inputFill, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
