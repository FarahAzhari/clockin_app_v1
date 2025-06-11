import 'package:clockin_app/views/home_screen.dart';
import 'package:clockin_app/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:clockin_app/widgets/custom_bottom_navigation_bar.dart'; // Your custom nav bar
// Your defined named routes (not directly used by MainBottomNavigationBar for tab switching)
// Import your actual screen widgets that will be displayed as tabs
// Your HomeScreen content
import 'package:clockin_app/views/attendance/attendance_list_screen.dart'; // Your AttendanceListScreen content
import 'package:clockin_app/views/reports/person_report_screen.dart'; // Your PersonReportScreen content

class MainBottomNavigationBar extends StatefulWidget {
  const MainBottomNavigationBar({super.key});

  // FIX: Declare ValueNotifiers as static final members of the StatefulWidget itself
  // This makes them globally accessible using MainBottomNavigationBar.notifierName
  static final ValueNotifier<bool> refreshHomeNotifier = ValueNotifier<bool>(
    false,
  );
  static final ValueNotifier<bool> refreshAttendanceNotifier =
      ValueNotifier<bool>(false);
  // NEW: ValueNotifier for PersonReportScreen
  static final ValueNotifier<bool> refreshReportsNotifier = ValueNotifier<bool>(
    false,
  );

  @override
  State<MainBottomNavigationBar> createState() =>
      _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> {
  int _selectedIndex = 0; // Start with Home tab (index 0)

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      // HomeScreen is now the actual content for the first tab.
      // We pass the refreshHomeNotifier to it so it can listen for external refresh signals.
      HomeScreen(
        refreshNotifier: MainBottomNavigationBar.refreshHomeNotifier,
      ), // Access via widget name
      // AttendanceListScreen: Now accepts refreshAttendanceNotifier to listen for updates.
      AttendanceListScreen(
        refreshNotifier: MainBottomNavigationBar.refreshAttendanceNotifier,
      ), // Access via widget name
      // FIX: Pass the new refreshReportsNotifier to PersonReportScreen
      PersonReportScreen(
        refreshNotifier: MainBottomNavigationBar.refreshReportsNotifier,
      ), // Content for the third tab
      const ProfileScreen(), // Content for the fourth tab
    ];
  }

  /// Handles the tap event on a BottomNavigationBarItem.
  ///
  /// Updates the [_selectedIndex] to switch the displayed screen in the IndexedStack.
  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    // Special handling for when navigating TO the Home tab (index 0)
    // This signal tells HomeScreen to refresh its data (e.g., if you came from Attendance tab).
    if (index == 0) {
      MainBottomNavigationBar.refreshHomeNotifier.value =
          true; // Set value via widget name
    }
    // Special handling for when navigating TO the Attendance tab (index 1)
    // This signal tells AttendanceListScreen to refresh its data.
    else if (index == 1) {
      MainBottomNavigationBar.refreshAttendanceNotifier.value =
          true; // Set value via widget name
    }
    // NEW: Special handling for when navigating TO the Reports tab (index 2)
    else if (index == 2) {
      MainBottomNavigationBar.refreshReportsNotifier.value =
          true; // Set value via widget name
    }
    // You can add more `else if` blocks for other tabs if they also need a refresh
    // when they are explicitly tapped from the bottom navigation bar.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex:
            _selectedIndex, // Pass the current selected index for highlighting
        onTap: _onItemTapped, // Pass the callback to handle tab taps
      ),
    );
  }
}
