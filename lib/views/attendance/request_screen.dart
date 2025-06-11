import 'package:clockin_app/controllers/attendance_controller.dart';
import 'package:clockin_app/core/constants/app_colors.dart';
import 'package:clockin_app/data/local_storage/session_manager.dart';
import 'package:clockin_app/data/models/attendance_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clockin_app/widgets/custom_input_field.dart'; // Import CustomInputField
import 'package:clockin_app/widgets/custom_date_input_field.dart'; // Import CustomDateInputField
import 'package:clockin_app/widgets/custom_dropdown_input_field.dart'; // Import CustomDropdownInputField
import 'package:clockin_app/widgets/primary_button.dart'; // NEW: Import PrimaryButton

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
    // Basic validation
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
      if (mounted) {
        // Check if widget is still in the tree
        _showSnackBar('Request submitted successfully!');
        Navigator.pop(context, true); // Pop with true to indicate success
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to submit request: $e');
      }
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
            // Date Picker using CustomDateInputField
            CustomDateInputField(
              labelText: 'Select Date',
              icon: Icons.calendar_today,
              selectedDate: _selectedDate,
              onTap: () => _selectDate(context),
              hintText: 'No date chosen', // Optional hint text
            ),
            const SizedBox(height: 20),

            // Request Type Dropdown using CustomDropdownInputField
            CustomDropdownInputField<String>(
              labelText: 'Request Type',
              icon: Icons.category,
              value: _selectedRequestType,
              hintText: 'Select request type',
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

            // Reason Text Field using CustomInputField
            CustomInputField(
              controller: _reasonController,
              labelText:
                  'Reason for Request', // This becomes the floating label
              hintText:
                  'e.g., Annual leave, sick leave, personal matters', // This remains the hint text inside the field
              icon: Icons.edit_note,
              maxLines: 3, // Allow multiline input
              keyboardType:
                  TextInputType.multiline, // Set keyboard to multiline
              fillColor: AppColors.inputFill, // Match previous fillColor
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ), // Adjusted vertical padding
              customValidator: (value) {
                // Use customValidator for specific validation
                if (value == null || value.trim().isEmpty) {
                  return 'Reason cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            // Submit Button using PrimaryButton
            PrimaryButton(label: 'Submit Request', onPressed: _submitRequest),
          ],
        ),
      ),
    );
  }
}
