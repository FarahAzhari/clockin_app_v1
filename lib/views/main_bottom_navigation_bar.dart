import 'package:clockin_app/views/home_screen.dart';
import 'package:clockin_app/views/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:clockin_app/widgets/custom_bottom_navigation_bar.dart'; // Your custom nav bar
// Your defined named routes
// Import your actual screen widgets that will be displayed as tabs
// Your HomeScreen content
import 'package:clockin_app/views/attendance/attendance_list_screen.dart'; // Your AttendanceListScreen content
import 'package:clockin_app/views/reports/person_report_screen.dart'; // Your PersonReportScreen content

class MainBottomNavigationBar extends StatefulWidget {
  const MainBottomNavigationBar({super.key});

  @override
  State<MainBottomNavigationBar> createState() =>
      _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> {
  // _selectedIndex will control which tab is currently visible in the IndexedStack
  // and which icon is highlighted in the BottomNavigationBar.
  int _selectedIndex = 0; // Start with Home tab (index 0)

  // A ValueNotifier to signal HomeScreen when it needs to refresh its data.
  // This is used for cross-tab communication (e.g., Attendance data submitted -> Home refreshes).
  static final ValueNotifier<bool> refreshHomeNotifier = ValueNotifier<bool>(
    false,
  );

  // List of all top-level screens that will be managed by the BottomNavigationBar.
  // The order here MUST match the order of BottomNavigationBarItems.
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      // HomeScreen is now the actual content for the first tab.
      // We pass the refreshNotifier to it so it can listen for external refresh signals.
      HomeScreen(refreshNotifier: refreshHomeNotifier),
      const AttendanceListScreen(), // Content for the second tab
      const PersonReportScreen(), // Content for the third tab
      const ProfileScreen(), // Content for the fourth tab
    ];
  }

  /// Handles the tap event on a BottomNavigationBarItem.
  ///
  /// Updates the [_selectedIndex] to switch the displayed screen in the IndexedStack.
  void _onItemTapped(int index) {
    // We only update the index if it's different to prevent unnecessary
    // rebuilds if the user taps the already active tab.
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    // Special handling for when returning to Home tab, especially if data
    // might have changed from another tab (e.g., after submitting attendance).
    if (index == 0) {
      // Signal the HomeScreen to refresh its data.
      // HomeScreen will listen to this notifier and execute its refresh logic.
      refreshHomeNotifier.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body of the Scaffold now contains the IndexedStack.
      // IndexedStack keeps all children alive in the widget tree but only displays
      // the one at the current index, preserving their state.
      body: IndexedStack(
        index: _selectedIndex, // Controls which child widget is displayed
        children: _widgetOptions, // The list of your main tab screens
      ),
      // The BottomNavigationBar is placed here, so it persists across all tabs.
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex:
            _selectedIndex, // Pass the current selected index for highlighting
        onTap: _onItemTapped, // Pass the callback to handle tab taps
      ),
    );
  }
}
