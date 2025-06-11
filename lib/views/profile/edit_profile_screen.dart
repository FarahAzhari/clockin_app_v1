import 'package:flutter/material.dart';
import 'package:clockin_app/core/constants/app_colors.dart';
import 'package:clockin_app/data/models/user_model.dart';
import 'package:clockin_app/controllers/auth_controller.dart';
import 'package:intl/intl.dart';
import 'package:clockin_app/widgets/custom_input_field.dart'; // Import CustomInputField
import 'package:clockin_app/widgets/custom_date_input_field.dart'; // Import CustomDateInputField
import 'package:clockin_app/widgets/custom_dropdown_input_field.dart'; // Import CustomDropdownInputField
import 'package:clockin_app/widgets/primary_button.dart'; // Import PrimaryButton
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // For File operations

class EditProfileScreen extends StatefulWidget {
  final UserModel currentUser;

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthController _authController = AuthController();
  final _formKey = GlobalKey<FormState>();

  // Controllers for text input fields (removed _profileImageUrlController)
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileNoController;
  late TextEditingController _designationController;

  // State for image picker
  XFile? _pickedImageFile; // Holds the file picked by the user
  final ImagePicker _picker = ImagePicker(); // Image picker instance

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

    // If there's an existing profile image URL and it's a local file,
    // initialize _pickedImageFile so the preview shows it.
    if (widget.currentUser.profileImageUrl != null &&
        widget.currentUser.profileImageUrl!.isNotEmpty &&
        !widget.currentUser.profileImageUrl!.startsWith('http')) {
      final File existingImage = File(widget.currentUser.profileImageUrl!);
      if (existingImage.existsSync()) {
        _pickedImageFile = XFile(existingImage.path);
      }
    }

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
        // FIX: Corrected DateFormat to 'MMM yyyy' for consistency
        _selectedJoinedDate = DateFormat(
          'MMM yyyy', // Corrected format string
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
    super.dispose();
  }

  // Method to pick an image from gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImageFile = image;
      });
    }
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

      // Manually create a new UserModel instance since copyWith is not available
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
        // FIX: Corrected DateFormat to 'MMM yyyy' for consistency when saving
        joinedDate: _selectedJoinedDate == null
            ? null
            : DateFormat(
                'MMM yyyy',
              ).format(_selectedJoinedDate!), // Corrected format string
        // Use _pickedImageFile.path directly. If null, set profileImageUrl to null.
        profileImageUrl: _pickedImageFile != null
            ? _pickedImageFile!.path
            : null,
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
    ImageProvider? profileImageProvider; // Make ImageProvider nullable

    // Determine the image to display in the CircleAvatar
    if (_pickedImageFile != null) {
      profileImageProvider = FileImage(File(_pickedImageFile!.path));
    } else if (widget.currentUser.profileImageUrl != null &&
        widget.currentUser.profileImageUrl!.isNotEmpty) {
      // If there's an existing profile URL, check if it's a network image or local path
      if (widget.currentUser.profileImageUrl!.startsWith('http')) {
        profileImageProvider = NetworkImage(
          widget.currentUser.profileImageUrl!,
        );
      } else {
        // Assume it's a previously saved local file path from image picker
        // Ensure the file exists before trying to load it
        final File localFile = File(widget.currentUser.profileImageUrl!);
        if (localFile.existsSync()) {
          profileImageProvider = FileImage(localFile);
        } else {
          profileImageProvider = null; // File not found, use default icon
        }
      }
    }
    // If profileImageProvider is still null, the CircleAvatar's child (Icons.person) will be shown.

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
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primary.withOpacity(
                        0.2,
                      ), // Light background for avatar
                      backgroundImage: profileImageProvider,
                      // Show default icon ONLY if no valid backgroundImage is set
                      child: profileImageProvider == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.textLight,
                            ) // Default icon if no image
                          : null, // No child if an image is loading
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(
                        Icons.camera_alt,
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        'Change Photo',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 24,
              ), // Space between image section and first input
              // Username (editable) using CustomInputField
              CustomInputField(
                controller: _usernameController,
                hintText: 'Username', // This is hintText
                labelText: 'Username', // This is labelText
                icon: Icons.person,
                customValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email (editable) using CustomInputField
              CustomInputField(
                controller: _emailController,
                hintText: 'Email', // This is hintText
                labelText: 'Email', // This is labelText
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                customValidator: (value) {
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

              // Mobile Number using CustomInputField
              CustomInputField(
                controller: _mobileNoController,
                hintText: 'Mobile Number', // This is hintText
                labelText: 'Mobile Number', // This is labelText
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Date of Birth using CustomDateInputField
              CustomDateInputField(
                labelText: 'Date of Birth',
                icon: Icons.calendar_today,
                selectedDate: _selectedDob,
                onTap: () => _selectDate(
                  context,
                  _selectedDob,
                  (date) => _selectedDob = date,
                ),
                hintText: 'Select DOB',
              ),
              const SizedBox(height: 16),

              // Blood Group Dropdown using CustomDropdownInputField
              CustomDropdownInputField<String>(
                labelText: 'Blood Group',
                icon: Icons.bloodtype,
                value: _selectedBloodGroup,
                hintText: 'Select Blood Group',
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

              // Designation using CustomInputField
              CustomInputField(
                controller: _designationController,
                hintText: 'Designation', // This is hintText
                labelText: 'Designation', // This is labelText
                icon: Icons.work,
              ),
              const SizedBox(height: 16),

              // Joined Date using CustomDateInputField
              CustomDateInputField(
                labelText: 'Joined Date',
                icon: Icons.date_range,
                selectedDate: _selectedJoinedDate,
                onTap: () => _selectDate(
                  context,
                  _selectedJoinedDate,
                  (date) => _selectedJoinedDate = date,
                ),
                hintText: 'Select Joined Date',
              ),
              const SizedBox(height: 24),

              // Save Button using PrimaryButton
              PrimaryButton(label: 'Save Profile', onPressed: _saveProfile),
            ],
          ),
        ),
      ),
    );
  }
}
