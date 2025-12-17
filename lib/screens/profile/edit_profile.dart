import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studioh_ceramic_cafe_client/utils/constant/form_validator.dart';

import '../../cubit/auth_cubit/auth_cubit.dart';
import '../../utils/constant/app_colors.dart';
import '../../utils/widget/app_text_field.dart';
import '../../utils/widget/custom_text.dart';
import '../../utils/widget/snacke_bar.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  String? _currentImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    setCurrentInfo();
  }

  void setCurrentInfo() {
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.state.currentUserModel;

    if (user != null) {
      nameController.text = user.name;
      emailController.text = user.email;
      phoneController.text = user.phoneNumber ?? "";
      _currentImageUrl = user.imageUrl;
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      AppSnackbar.showError(context, 'Failed to capture image: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      AppSnackbar.showError(context, 'Failed to pick image: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomText(
                  text: 'Choose Profile Photo',
                  fontSizeFactor: 1.2,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.button.withOpacity(0.1),
                    child: Icon(Icons.camera_alt, color: AppColors.button),
                  ),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.button.withOpacity(0.1),
                    child: Icon(Icons.photo_library, color: AppColors.button),
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
                if (_selectedImage != null || _currentImageUrl != null)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    title: const Text('Remove Photo'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                        _currentImageUrl = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomText(
                      text: 'Edit Profile',
                      fontSizeFactor: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: AppColors.button,
                        child: Icon(
                          Icons.close,
                          size: 15,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Profile Image Section
                Center(
                  child: Stack(
                    children: [
                      // Profile Image
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.button,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _selectedImage != null
                              ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          )
                              : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                              ? Image.network(
                            _currentImageUrl!,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.button.withOpacity(0.1),
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColors.button,
                                ),
                              );
                            },
                          )
                              : Container(
                            color: AppColors.button.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.button,
                            ),
                          ),
                        ),
                      ),

                      // Edit Button
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.button,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(text: "Email", fontSizeFactor: 1.2),
                    AppTextField(
                      label: 'Email',
                      controller: emailController,
                      textInputType: TextInputType.emailAddress,
                      keyboardType: TextInputType.emailAddress,
                      isEnabled: false,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Name Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(text: "Name", fontSizeFactor: 1.2),
                    AppTextField(
                      label: 'Name',
                      controller: nameController,
                      textInputType: TextInputType.name,
                      keyboardType: TextInputType.name,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Phone Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(text: "Phone Number", fontSizeFactor: 1.2),
                    AppTextField(
                      controller: phoneController,
                      label: 'Phone',
                      textInputType: TextInputType.phone,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Update Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _handleUpdateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      disabledBackgroundColor: AppColors.button.withOpacity(0.6),
                    ),
                    child: _isUploading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Update Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpdateProfile() async {
    // Validate inputs
    String email = emailController.text.trim();
    String phone = phoneController.text.trim();
    String name = nameController.text.trim();

    if (!FormValidator.validateUpdateProfile(
      context,
      email: email,
      name: name,
      phone: phone,
    )) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await context.read<AuthCubit>().updateUserProfileInfo(
        context: context,
        name: name,
        phone: phone,
        imageFile: _selectedImage, // Pass the selected image file
      );

      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        AppSnackbar.show(context, 'Profile updated successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        AppSnackbar.showError(context, 'Failed to update profile: $e');
      }
    }
  }
}