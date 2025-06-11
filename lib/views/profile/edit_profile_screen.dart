import 'package:flutter/material.dart';
import 'package:clockin_app/core/constants/app_colors.dart';
import 'package:clockin_app/data/models/user_model.dart';
import 'package:clockin_app/controllers/auth_controller.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel currentUser;

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthController _authController = AuthController();
  final _formKey = GlobalKey<FormState>();

  // Controllers for text input fields
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileNoController;
  late TextEditingController _designationController;
  late TextEditingController _profileImageUrlController;

  // State for date picker
  DateTime? _selectedDob;
  DateTime? _selectedJoinedDate;

  // For dropdowns
  String? _selectedBloodGroup;
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    _usernameController = TextEditingController(
      text: widget.currentUser.username,
    );
    _emailController = TextEditingController(text: widget.currentUser.email);
    _mobileNoController = TextEditingController(
      text: widget.currentUser.mobileNo,
    );
    _designationController = TextEditingController(
      text: widget.currentUser.designation,
    );
    _profileImageUrlController = TextEditingController(
      text: widget.currentUser.profileImageUrl,
    );

    // Parse existing dates if available
    if (widget.currentUser.dob != null && widget.currentUser.dob!.isNotEmpty) {
      try {
        _selectedDob = DateFormat('dd-MM-yyyy').parse(widget.currentUser.dob!);
      } catch (e) {
        print('Error parsing DOB: ${widget.currentUser.dob}, $e');
      }
    }
    if (widget.currentUser.joinedDate != null &&
        widget.currentUser.joinedDate!.isNotEmpty) {
      try {
        // DateFormat('MMM yyyy').parse handles "Feb 2025" or "Jan 2023"
        _selectedJoinedDate = DateFormat(
          'MMM yyyy',
        ).parse(widget.currentUser.joinedDate!);
      } catch (e) {
        print(
          'Error parsing Joined Date: ${widget.currentUser.joinedDate}, $e',
        );
      }
    }

    _selectedBloodGroup = widget.currentUser.bloodGroup;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _mobileNoController.dispose();
    _designationController.dispose();
    _profileImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ), // Allow slight future for joined date if needed
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
    if (picked != null && picked != initialDate) {
      setState(() {
        onDateSelected(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields

      // FIX: Manually create a new UserModel instance since copyWith is not available
      final updatedUser = UserModel(
        id: widget.currentUser.id, // Preserve existing ID
        username: _usernameController.text,
        email: _emailController.text,
        password: widget
            .currentUser
            .password, // Keep existing password (should be hashed in real app)
        role: widget.currentUser.role, // Preserve existing role
        mobileNo: _mobileNoController.text.isEmpty
            ? null
            : _mobileNoController.text,
        dob: _selectedDob == null
            ? null
            : DateFormat('dd-MM-yyyy').format(_selectedDob!),
        bloodGroup: _selectedBloodGroup,
        designation: _designationController.text.isEmpty
            ? null
            : _designationController.text,
        joinedDate: _selectedJoinedDate == null
            ? null
            : DateFormat('MMM yyyy').format(_selectedJoinedDate!),
        profileImageUrl: _profileImageUrlController.text.isEmpty
            ? null
            : _profileImageUrlController.text,
      );

      try {
        // Call the update method in AuthController
        final success = await _authController.updateCurrentUserDetails(
          updatedUser,
        );

        if (!mounted) return; // Check if the widget is still in the tree

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context, true); // Pop with true to signal refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile.')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image URL
              TextFormField(
                controller: _profileImageUrlController,
                decoration: InputDecoration(
                  labelText: 'Profile Image URL (Optional)',
                  labelStyle: const TextStyle(color: AppColors.textLight),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.image, color: AppColors.primary),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  // Basic URL validation
                  if (value != null &&
                      value.isNotEmpty &&
                      !Uri.parse(value).isAbsolute) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Username (editable)
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: AppColors.textLight),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(
                    Icons.person,
                    color: AppColors.primary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email (editable)
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: AppColors.textLight),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.email, color: AppColors.primary),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email cannot be empty';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mobile Number
              TextFormField(
                controller: _mobileNoController,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  labelStyle: const TextStyle(color: AppColors.textLight),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Date of Birth
              GestureDetector(
                onTap: () => _selectDate(
                  context,
                  _selectedDob,
                  (date) => _selectedDob = date,
                ),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: const TextStyle(color: AppColors.textLight),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                    ),
                  ),
                  child: Text(
                    _selectedDob == null
                        ? 'Select DOB'
                        : DateFormat('dd-MM-yyyy').format(_selectedDob!),
                    style: TextStyle(
                      color: _selectedDob == null
                          ? AppColors.placeholder
                          : AppColors.textDark,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Blood Group Dropdown
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: InputDecoration(
                  labelText: 'Blood Group',
                  labelStyle: const TextStyle(color: AppColors.textLight),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(
                    Icons.bloodtype,
                    color: AppColors.primary,
                  ),
                ),
                items: _bloodGroups.map((String group) {
                  return DropdownMenuItem<String>(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBloodGroup = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Designation
              TextFormField(
                controller: _designationController,
                decoration: InputDecoration(
                  labelText: 'Designation',
                  labelStyle: const TextStyle(color: AppColors.textLight),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.work, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),

              // Joined Date
              GestureDetector(
                onTap: () => _selectDate(
                  context,
                  _selectedJoinedDate,
                  (date) => _selectedJoinedDate = date,
                ),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Joined Date',
                    labelStyle: const TextStyle(color: AppColors.textLight),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(
                      Icons.date_range,
                      color: AppColors.primary,
                    ),
                  ),
                  child: Text(
                    _selectedJoinedDate == null
                        ? 'Select Joined Date'
                        : DateFormat('MMM yyyy').format(_selectedJoinedDate!),
                    style: TextStyle(
                      color: _selectedJoinedDate == null
                          ? AppColors.placeholder
                          : AppColors.textDark,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Save Profile',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
