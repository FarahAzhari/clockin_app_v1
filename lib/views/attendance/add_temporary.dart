import 'package:clockin_app/controllers/attendance_controller.dart';
import 'package:clockin_app/core/constants/app_colors.dart';
import 'package:clockin_app/data/local_storage/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTemporary extends StatefulWidget {
  const AddTemporary({super.key});

  @override
  State<AddTemporary> createState() => _AddTemporaryState();
}

class _AddTemporaryState extends State<AddTemporary> {
  final AttendanceController _attendanceController = AttendanceController();
  final SessionManager _sessionManager =
      SessionManager(); // Add SessionManager here

  // State variables for date, time-in, time-out, and status
  DateTime? _selectedDate;
  TimeOfDay? _selectedTimeIn;
  TimeOfDay? _selectedTimeOut;
  String? _selectedStatus; // For the dropdown menu

  final List<String> _statusOptions = [
    'On Time',
    'Late',
    'Absent',
    'Leave',
    'Manual Entry',
  ]; // Example statuses

  @override
  void initState() {
    super.initState();
    // Initialize with current date and time for convenience
    final now = DateTime.now();
    _selectedDate = now;
    _selectedTimeIn = TimeOfDay.fromDateTime(now);
    _selectedTimeOut = TimeOfDay.fromDateTime(now);
    _selectedStatus = 'Manual Entry'; // Default status for manual entries
  }

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

  Future<void> _selectTime(
    BuildContext context,
    TimeOfDay? initialTime,
    Function(TimeOfDay) onTimeSelected,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
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
    if (picked != null) {
      setState(() {
        onTimeSelected(picked);
      });
    }
  }

  TextStyle _labelStyle() => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Temporary Attendance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Card(
          color: AppColors.background,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Picker
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      labelStyle: _labelStyle(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? 'Select Date'
                              : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Time In Picker
                GestureDetector(
                  onTap: () => _selectTime(context, _selectedTimeIn, (time) {
                    _selectedTimeIn = time;
                  }),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Time In',
                      labelStyle: _labelStyle(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTimeIn == null
                              ? 'Select Time In'
                              : _selectedTimeIn!.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.access_time, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Time Out Picker
                GestureDetector(
                  onTap: () => _selectTime(context, _selectedTimeOut, (time) {
                    _selectedTimeOut = time;
                  }),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Time Out',
                      labelStyle: _labelStyle(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTimeOut == null
                              ? 'Select Time Out'
                              : _selectedTimeOut!.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.access_time, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Status Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    labelStyle: _labelStyle(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: _statusOptions.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatus = newValue;
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Add Attendance Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _selectedDate == null ||
                                _selectedTimeIn == null ||
                                _selectedTimeOut == null ||
                                _selectedStatus == null ||
                                _selectedStatus!.isEmpty
                            ? null // Disable button if any required field is not selected
                            : () async {
                                // Get the current user's ID
                                final userId = await _sessionManager
                                    .getUserIdAsInt();

                                if (userId == null) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Error: User not logged in. Cannot add attendance.',
                                      ),
                                    ),
                                  );
                                  return; // Stop if no user ID
                                }

                                final checkInDateTime = DateTime(
                                  _selectedDate!.year,
                                  _selectedDate!.month,
                                  _selectedDate!.day,
                                  _selectedTimeIn!.hour,
                                  _selectedTimeIn!.minute,
                                );
                                final checkOutDateTime = DateTime(
                                  _selectedDate!.year,
                                  _selectedDate!.month,
                                  _selectedDate!.day,
                                  _selectedTimeOut!.hour,
                                  _selectedTimeOut!.minute,
                                );

                                // Format the strings as expected by AttendanceController.addAttendance
                                final String dateString = DateFormat(
                                  'yyyy-MM-dd',
                                ).format(checkInDateTime);
                                final String timeInString = DateFormat(
                                  'HH:mm:ss',
                                ).format(checkInDateTime);
                                final String timeOutString = DateFormat(
                                  'HH:mm:ss',
                                ).format(checkOutDateTime);
                                final String statusString = _selectedStatus!;

                                try {
                                  // Pass the userId along with other details
                                  await _attendanceController.addAttendance(
                                    userId: userId, // <-- PASS USERID HERE
                                    date: dateString,
                                    timeIn: timeInString,
                                    timeOut: timeOutString,
                                    status: statusString,
                                  );

                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Attendance added successfully!',
                                      ),
                                    ),
                                  );
                                  // Pop the screen and pass true to indicate a successful addition
                                  Navigator.pop(context, true);
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to add attendance: ${e.toString()}',
                                      ),
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(
                          Icons.save,
                          color: AppColors.inputFill,
                        ),
                        label: const Text(
                          'Save Attendance',
                          style: TextStyle(color: AppColors.inputFill),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
