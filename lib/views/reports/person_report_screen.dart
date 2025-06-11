import 'dart:async';

import 'package:clockin_app/core/constants/app_colors.dart';
import 'package:clockin_app/data/local_storage/session_manager.dart';
import 'package:clockin_app/data/models/attendance_model.dart';
import 'package:clockin_app/data/services/attendance_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart

class PersonReportScreen extends StatefulWidget {
  const PersonReportScreen({super.key});

  @override
  State<PersonReportScreen> createState() => _PersonReportScreenState();
}

class _PersonReportScreenState extends State<PersonReportScreen> {
  final SessionManager _sessionManager = SessionManager();
  final AttendanceService _attendanceService = AttendanceService();

  late Future<List<AttendanceModel>> _monthlyAttendanceFuture;
  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  // Summary counts for the selected month - Initialized directly to avoid LateInitializationError
  int _presentCount = 0;
  int _absentCount = 0; // Will now include all non-regular attendance types
  int _lateInCount = 0;
  int _totalWorkingDaysInMonth = 0;
  String _totalWorkingHours = '0hr'; // Changed default to reflect new format

  // Data for Pie Chart
  List<PieChartSectionData> _pieChartSections = [];

  @override
  void initState() {
    super.initState();
    _monthlyAttendanceFuture = _fetchAndCalculateMonthlyReports();
  }

  // Fetches attendance data and calculates monthly summaries
  Future<List<AttendanceModel>> _fetchAndCalculateMonthlyReports() async {
    final userId = await _sessionManager.getUserIdAsInt();

    if (userId == null) {
      print(
        'Error: User ID is null. Cannot fetch attendance data for reports.',
      );
      _updateSummaryCounts(0, 0, 0, 0, '0hr'); // Reset all counts
      _updatePieChartData(0, 0, 0); // Reset pie chart data
      return Future.value([]);
    }

    try {
      final allAttendances = await _attendanceService.getUserAttendances(
        userId,
      );

      // Filter attendances for the selected month and sort them by date (descending)
      final monthlyAttendances = allAttendances.where((attendance) {
        final attendanceDate = DateTime.parse(attendance.date);
        return attendanceDate.year == _selectedMonth.year &&
            attendanceDate.month == _selectedMonth.month;
      }).toList();

      monthlyAttendances.sort((a, b) => b.date.compareTo(a.date));

      // Calculate summary counts
      int tempPresentCount = 0;
      int tempAbsentCount = 0; // Now includes all non-regular types
      int tempLateInCount = 0;
      Duration totalWorkingDuration = Duration.zero;

      // Identify all holiday dates explicitly marked in the attendance records for the selected month
      Set<String> holidayDates = allAttendances
          .where(
            (att) =>
                att.type?.toLowerCase() == 'holiday' &&
                DateTime.parse(att.date).year == _selectedMonth.year &&
                DateTime.parse(att.date).month == _selectedMonth.month,
          )
          .map((att) => att.date)
          .toSet();

      // Calculate total working days in the month (weekdays excluding holidays)
      final int daysInSelectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        0,
      ).day;
      int actualWorkingDays = 0;
      for (int i = 1; i <= daysInSelectedMonth; i++) {
        DateTime currentDay = DateTime(
          _selectedMonth.year,
          _selectedMonth.month,
          i,
        );
        // Check if it's a weekday (Monday to Friday)
        if (currentDay.weekday >= DateTime.monday &&
            currentDay.weekday <= DateTime.friday) {
          // Check if this day is not explicitly marked as a holiday in the attendance records
          if (!holidayDates.contains(
            DateFormat('yyyy-MM-dd').format(currentDay),
          )) {
            actualWorkingDays++;
          }
        }
      }

      for (var attendance in monthlyAttendances) {
        if (attendance.type == null) {
          // Regular attendance
          if (attendance.timeIn != null &&
              attendance.timeIn!.isNotEmpty &&
              attendance.timeOut != null &&
              attendance.timeOut!.isNotEmpty) {
            tempPresentCount++;
          }
          if (attendance.status.toLowerCase() == 'late') {
            tempLateInCount++;
          }

          // Add to total working duration if workingHours is available
          if (attendance.workingHours != null &&
              attendance.workingHours!.isNotEmpty &&
              attendance.workingHours != '00:00:00') {
            try {
              final parts = attendance.workingHours!.split(':');
              final hours = int.parse(parts[0]);
              final minutes = int.parse(parts[1]);
              final seconds = int.parse(parts[2]);
              totalWorkingDuration += Duration(
                hours: hours,
                minutes: minutes,
                seconds: seconds,
              );
            } catch (e) {
              print(
                'Error parsing working hours for total: ${attendance.workingHours} - $e',
              );
            }
          }
        } else {
          // Request attendance (all types count as 'absent' for this report)
          // Includes 'absent', 'leave', 'sick', 'permission', 'business trip', 'holiday'
          tempAbsentCount++;
        }
      }

      // Format total working hours to only show hours (Xhr)
      final totalHours = totalWorkingDuration.inHours;
      String formattedTotalWorkingHours = '${totalHours}hr';

      _updateSummaryCounts(
        tempPresentCount,
        tempAbsentCount, // Updated calculation
        tempLateInCount,
        actualWorkingDays,
        formattedTotalWorkingHours, // Use the new formatted string
      );

      _updatePieChartData(tempPresentCount, tempAbsentCount, tempLateInCount);

      return monthlyAttendances; // Return the filtered and sorted list for the daily log
    } catch (e) {
      print('Error fetching and calculating monthly reports: $e');
      _updateSummaryCounts(0, 0, 0, 0, '0hr'); // Reset counts on error
      _updatePieChartData(0, 0, 0); // Reset pie chart data on error
      throw Exception('Failed to load reports: $e');
    }
  }

  // Updates the state variables for summary counts
  void _updateSummaryCounts(
    int present,
    int absent,
    int late,
    int totalWorkingDays,
    String totalHrs, // This parameter now expects the "Xhr" string
  ) {
    setState(() {
      _presentCount = present;
      _absentCount = absent;
      _lateInCount = late;
      _totalWorkingDaysInMonth = totalWorkingDays;
      _totalWorkingHours = totalHrs; // Assign the formatted string directly
    });
  }

  // New method to update pie chart data
  void _updatePieChartData(int presentCount, int absentCount, int lateInCount) {
    final total = presentCount + absentCount + lateInCount;
    if (total == 0) {
      setState(() {
        _pieChartSections = [];
      });
      return;
    }

    // Define colors for the pie chart sections
    const Color presentColor = Colors.green;
    const Color absentColor = Colors.red;
    const Color lateColor = Colors.orange;

    setState(() {
      _pieChartSections = [
        // Present
        if (presentCount > 0)
          PieChartSectionData(
            color: presentColor,
            value: presentCount.toDouble(),
            title: '${(presentCount / total * 100).toStringAsFixed(1)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: _buildBadge('Present', presentColor),
            badgePositionPercentageOffset: .98,
          ),
        // Absent
        if (absentCount > 0)
          PieChartSectionData(
            color: absentColor,
            value: absentCount.toDouble(),
            title: '${(absentCount / total * 100).toStringAsFixed(1)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: _buildBadge('Absent', absentColor),
            badgePositionPercentageOffset: .98,
          ),
        // Late In
        if (lateInCount > 0)
          PieChartSectionData(
            color: lateColor,
            value: lateInCount.toDouble(),
            title: '${(lateInCount / total * 100).toStringAsFixed(1)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: _buildBadge('Late', lateColor),
            badgePositionPercentageOffset: .98,
          ),
      ];
    });
  }

  // Helper for PieChart badges (labels)
  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Method to show month picker (only month and year)
  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2101, 12, 31),
      initialDatePickerMode: DatePickerMode.year, // Start with year selection
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final DateTime newSelectedMonth = DateTime(picked.year, picked.month, 1);
      if (newSelectedMonth.year != _selectedMonth.year ||
          newSelectedMonth.month != _selectedMonth.month) {
        setState(() {
          _selectedMonth = newSelectedMonth;
          _monthlyAttendanceFuture =
              _fetchAndCalculateMonthlyReports(); // Trigger re-fetch
        });
      }
    }
  }

  // Helper widget to build summary cards
  Widget _buildSummaryCard(String title, dynamic value, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: Column(
          children: [
            Container(
              height: 5.0,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      value.toString(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 28, // Slightly smaller for fit
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance Reports'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                // Month selector button
                GestureDetector(
                  onTap: () => _selectMonth(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Text(
                          DateFormat(
                            'MMM yyyy',
                          ).format(_selectedMonth).toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(width: 5),
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.textDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Summary cards for the selected month in a 3x2 grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.count(
              crossAxisCount: 3, // 3 columns
              shrinkWrap: true, // Wrap content
              physics:
                  const NeverScrollableScrollPhysics(), // Disable scrolling inside grid
              mainAxisSpacing: 10, // Spacing between rows
              crossAxisSpacing: 10, // Spacing between columns
              childAspectRatio: 1.0, // Make cards square
              children: [
                _buildSummaryCard(
                  'Total Working Days',
                  _totalWorkingDaysInMonth.toString().padLeft(2, '0'),
                  Colors.blueGrey,
                ),
                _buildSummaryCard(
                  'Total Present Days',
                  _presentCount.toString().padLeft(2, '0'),
                  Colors.green,
                ),
                _buildSummaryCard(
                  'Total Absent Days',
                  _absentCount.toString().padLeft(2, '0'),
                  Colors.red,
                ),
                _buildSummaryCard(
                  'Total Late Entries',
                  _lateInCount.toString().padLeft(2, '0'),
                  Colors.orange,
                ),
                _buildSummaryCard(
                  'Total Working Hours',
                  _totalWorkingHours,
                  AppColors.primary,
                ),
                _buildSummaryCard(
                  'Overall Attendance %',
                  '${(_presentCount / (_totalWorkingDaysInMonth == 0 ? 1 : _totalWorkingDaysInMonth) * 100).toStringAsFixed(0)}%',
                  Colors.teal,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
            child: Text(
              'Attendance Status Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.5, // Adjust aspect ratio for chart size
              child: FutureBuilder<List<AttendanceModel>>(
                future: _monthlyAttendanceFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // Use a Consumer if you use Provider for state management,
                  // otherwise direct use of _pieChartSections is fine
                  if (_pieChartSections.isEmpty) {
                    return Center(
                      child: Text(
                        'No attendance data for chart for ${DateFormat('MMMM yyyy').format(_selectedMonth)}.',
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: PieChart(
                      PieChartData(
                        sections: _pieChartSections,
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40, // For donut chart effect
                        // Optional: Add touch interactivity
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    // Reset any highlight
                                    return;
                                  }
                                  // Handle touch events, e.g., show tooltip
                                });
                              },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
