import 'package:flutter/material.dart';
import '../../widgets/custom_widgets.dart';
import '../../core/user_session.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/service_data.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _civilStatusController;
  late TextEditingController _contactController;
  File? _idImage;
  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = UserSession().currentUser;
    _nameController = TextEditingController(text: user?['full_name'] ?? '');
    _emailController = TextEditingController(text: user?['email'] ?? '');
    _dobController = TextEditingController(text: user?['dob'] ?? '');
    _addressController = TextEditingController(text: user?['address'] ?? '');
    _civilStatusController = TextEditingController(text: user?['civil_status'] ?? '');
    _contactController = TextEditingController(text: user?['contact_number'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _civilStatusController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickIdImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 1000,
      maxHeight: 1000,
    );
    if (pickedFile != null) {
      setState(() {
        _idImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 35,
      maxWidth: 600,
      maxHeight: 600,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _updateProfile() async {
    final user = UserSession().currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    final res = await ServiceData.updateProfile(
      userId: user['id'].toString(),
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim().isNotEmpty ? _passwordController.text.trim() : null,
      dob: _dobController.text.trim(),
      address: _addressController.text.trim(),
      civilStatus: _civilStatusController.text.trim(),
      contactNumber: _contactController.text.trim(),
      idImage: _idImage,
      profilePicture: _profileImage,
    );

    setState(() => _isLoading = false);

    if (res['success'] == true && mounted) {
      UserSession().setUser(res['user']);
      
      // Update SharedPreferences cache so the changes persist when the app restarts
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user', json.encode(res['user']));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['error'] ?? 'Update failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickProfileImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (UserSession().currentUser?['profile_picture'] != null
                            ? NetworkImage('${ServiceData.baseUrl.replaceAll('/api', '')}/${UserSession().currentUser!['profile_picture']}')
                            : null) as ImageProvider?,
                    child: _profileImage == null && UserSession().currentUser?['profile_picture'] == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'John Doe',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'john.doe@example.com',
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _dobController,
              label: 'Date of Birth',
              hint: 'YYYY-MM-DD',
              prefixIcon: Icons.calendar_today,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _addressController,
              label: 'Complete Address',
              hint: '123 Main St, City, Province',
              prefixIcon: Icons.home_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _civilStatusController,
              label: 'Civil Status',
              hint: 'Single/Married/Widowed',
              prefixIcon: Icons.people_outline,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _contactController,
              label: 'Contact Information',
              hint: 'Phone Number',
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickIdImage,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Valid ID'),
                  ),
                ),
                if (_idImage != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, color: Colors.green),
                ] else if (UserSession().currentUser?['valid_id_path'] != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, color: Colors.blue),
                ]
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              label: 'New Password (Optional)',
              hint: 'Leave blank to keep current',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
                    text: 'Save Changes',
                    onPressed: _updateProfile,
                  ),
          ],
        ),
      ),
    );
  }
}
