import 'package:flutter/material.dart';
import 'package:clockin_app/core/constants/app_colors.dart';
import 'package:clockin_app/data/local_storage/session_manager.dart';
import 'package:clockin_app/routes/app_routes.dart';
// import 'package:intl/intl.dart'; // Keep this import for DateFormat if you use it for displaying dates in UI
import 'package:clockin_app/data/models/user_model.dart'; // Import UserModel
import 'package:clockin_app/controllers/auth_controller.dart'; // Import AuthController
import 'package:clockin_app/views/profile/edit_profile_screen.dart'; // NEW: Import EditProfileScreen

class ProfileScreen extends StatefulWidget {
  // Add a ValueNotifier to the constructor to receive refresh signals
  final ValueNotifier<bool> refreshNotifier;

  const ProfileScreen({super.key, required this.refreshNotifier});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Use AuthController to fetch user data
  final AuthController _authController = AuthController();
  UserModel? _currentUser; // Holds the full user data

  bool _notificationEnabled = true; // State for the notification switch

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Add listener for refresh signals
    widget.refreshNotifier.addListener(_handleRefreshSignal);
  }

  @override
  void dispose() {
    widget.refreshNotifier.removeListener(_handleRefreshSignal);
    super.dispose();
  }

  void _handleRefreshSignal() {
    if (widget.refreshNotifier.value) {
      _loadUserData(); // Re-fetch user data on refresh signal
      widget.refreshNotifier.value = false; // Reset the notifier
    }
  }

  Future<void> _loadUserData() async {
    final user = await _authController.getCurrentUser();
    setState(() {
      _currentUser = user;
      // You might also want to load the notification preference from the user model
      // if you store it there:
      // _notificationEnabled = user?.notificationPreference ?? true;
    });
  }

  void _logout(BuildContext context) async {
    await SessionManager().logout();
    if (context.mounted) {
      // Use pushReplacementNamed to prevent going back to the profile screen after logout
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  // NEW METHOD: Navigate to EditProfileScreen
  void _navigateToEditProfile() async {
    if (_currentUser == null) {
      // Handle case where user data is not loaded yet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data not loaded yet. Please wait.')),
      );
      return;
    }

    // Navigate to the EditProfileScreen, passing the current user data.
    // Await the result to know if data was updated.
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(currentUser: _currentUser!),
      ),
    );

    // If result is true, it means the profile was successfully updated in EditProfileScreen,
    // so refresh the data on this ProfileScreen.
    if (result == true) {
      _loadUserData(); // Refresh profile data
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provide default values if _currentUser is null (e.g., still loading or no user logged in)
    // These defaults will be shown while data is loading or if no user is authenticated.
    final String username = _currentUser?.username ?? 'Guest User';
    final String email = _currentUser?.email ?? 'guest@example.com';
    // Using default placeholders if data is not available from _currentUser
    final String mobileNo = _currentUser?.mobileNo ?? '+91 XXXXX XXXXX';
    final String dob = _currentUser?.dob ?? 'DD-MM-YYYY';
    final String bloodGroup = _currentUser?.bloodGroup ?? 'N/A';
    final String designation = _currentUser?.designation ?? 'Employee';
    final String joinedDate = _currentUser?.joinedDate ?? 'Joined Jan 2023';
    final String profileImageUrl =
        _currentUser?.profileImageUrl ?? ''; // Empty string if null

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Managed by MainBottomNavigationBar
      ),
      body: Stack(
        children: [
          // Blue background wave/area at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 150, // Height of the blue background
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
            ),
          ),
          // Conditional rendering: Show CircularProgressIndicator while _currentUser is null
          _currentUser == null
              ? const Center(
                  child: CircularProgressIndicator(), // Show loading indicator
                )
              : ListView(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  children: [
                    // Profile Header Section (Avatar, Name, Designation, Joined Date)
                    _buildProfileHeader(
                      username,
                      designation,
                      joinedDate,
                      profileImageUrl,
                    ),
                    const SizedBox(height: 20), // Space between sections
                    // User Details Card
                    _buildUserDetailsCard(mobileNo, email, dob, bloodGroup),
                    const SizedBox(height: 20),

                    // Settings and Logout Options
                    _buildActionOptions(),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    String username,
    String designation,
    String joinedDate,
    String profileImageUrl,
  ) {
    return Column(
      children: [
        // Profile Picture
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white, // White border around avatar
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 55, // Larger radius for a prominent profile picture
            backgroundColor: AppColors.primary, // Placeholder background
            backgroundImage: profileImageUrl.isNotEmpty
                ? NetworkImage(profileImageUrl)
                      as ImageProvider // Use NetworkImage if URL is provided
                : const AssetImage(
                    'assets/images/default_profile.png',
                  ), // Fallback to a local asset image
            child: profileImageUrl.isEmpty
                ? const Icon(
                    Icons.person, // Fallback icon if no image URL
                    size: 50,
                    color: Colors.white,
                  )
                : null, // No child if an image is loading
          ),
        ),
        const SizedBox(height: 15),
        // User Name
        Text(
          username,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark, // Dark text color
          ),
        ),
        const SizedBox(height: 4),
        // Designation and Joined Date
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              designation,
              style: const TextStyle(fontSize: 16, color: AppColors.textLight),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '-', // Separator
                style: TextStyle(fontSize: 16, color: AppColors.textLight),
              ),
            ),
            Text(
              joinedDate,
              style: const TextStyle(fontSize: 16, color: AppColors.textLight),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserDetailsCard(
    String mobileNo,
    String email,
    String dob,
    String bloodGroup,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow('Mobile No.', mobileNo),
            const Divider(color: AppColors.border, height: 20),
            _buildDetailRow('Email ID', email),
            const Divider(color: AppColors.border, height: 20),
            _buildDetailRow('DOB', dob),
            const Divider(color: AppColors.border, height: 20),
            _buildDetailRow('Blood Group', bloodGroup),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Notification Toggle
          Card(
            margin: EdgeInsets.zero, // No extra margin for this card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: ListTile(
              leading: const Icon(
                Icons.notifications,
                color: AppColors.primary,
              ),
              title: const Text(
                'Notification',
                style: TextStyle(fontSize: 16, color: AppColors.textDark),
              ),
              trailing: Switch.adaptive(
                value: _notificationEnabled,
                onChanged: (bool newValue) {
                  setState(() {
                    _notificationEnabled = newValue;
                  });
                  // Add logic to save notification preference (e.g., to UserModel or SessionManager)
                },
                activeColor: AppColors.primary,
              ),
              onTap: () {
                // Toggling the switch directly is often enough, but you can add more logic here.
                setState(() {
                  _notificationEnabled = !_notificationEnabled;
                });
              },
            ),
          ),
          const SizedBox(height: 10), // Space between cards
          // Settings Option (now navigates to EditProfileScreen)
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.settings, color: AppColors.primary),
              title: const Text(
                'Settings',
                style: TextStyle(fontSize: 16, color: AppColors.textDark),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: AppColors.textLight,
              ),
              onTap: _navigateToEditProfile, // Call the new navigation method
            ),
          ),
          const SizedBox(height: 10), // Space between cards
          // Logout Option
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error, fontSize: 16),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: AppColors.textLight,
              ),
              onTap: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }
}
