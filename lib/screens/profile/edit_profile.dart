import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studioh_ceramic_cafe_client/cubit/auth_cubit/auth_cubit.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/snacke_bar.dart';

import '../../utils/constant/app_colors.dart';
import '../../utils/widget/app_text_field.dart';
import '../../utils/widget/custom_text.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String name = '', email = '', phone = '', message = '';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final bool isEnabled = true;
  final bool isPassword = false;
  final IconData? icon = null;


  @override
  void initState() {
    super.initState();
    setCurrentInfo();
  }

  void setCurrentInfo() {
    final authCubit=context.read<AuthCubit>();
    nameController.text = authCubit.state.currentUserModel!.name;
    emailController.text =  authCubit.state.currentUserModel!.email;
    phoneController.text = authCubit.state.currentUserModel!.phoneNumber??" ";
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
                    CustomText(
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
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(text: "Email", fontSizeFactor: 1.2),
                    AppTextField(
                      label: 'Email',
                      controller: emailController,
                      textInputType: TextInputType.emailAddress,
                      keyboardType: TextInputType.emailAddress,
                      isEnabled: false,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(text: "Name", fontSizeFactor: 1.2),
                    AppTextField(
                      label: 'Name',
                      controller: nameController,
                      textInputType: TextInputType.name,
                      keyboardType: TextInputType.name,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(text: "Phone Number", fontSizeFactor: 1.2),
                    AppTextField(
                      controller: phoneController,
                      label: 'Phone',
                      textInputType: TextInputType.phone,
                      //  prefixText: "+27 ",
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle user creation logic here
                      print('Name: ${nameController.text.trim()}');
                      print('Email: ${emailController.text.trim()}');
                      print('Phone: ${phoneController.text.trim()}');
                      // Validate email and phone
                      String email = emailController.text.trim();
                      String phone = phoneController.text.trim();
                      String name = phoneController.text.trim();

                      bool isValidEmail(String email) {
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        return emailRegex.hasMatch(email);
                      }

                      bool isValidPhone(String phone) {

                        final cleanedPhone = phone.replaceAll(
                          RegExp(r'[\s\-\(\)]'),
                          '',
                        );
                        final phoneRegex = RegExp(r'^(?:\+27|27|0)\d{9}$');

                        return phoneRegex.hasMatch(cleanedPhone);
                      }

                      if (email.isEmpty ||
                          phone.isEmpty ||
                          nameController.text.trim().isEmpty) {
                        AppSnackbar.showError(context,
                          'Missing Fields \nPlease fill in all fields.',

                        );
                        return;
                      }

                      if (!isValidEmail(email)) {
                        AppSnackbar.showError(context,
                          'Invalid Email \nPlease enter a valid email address.',

                        );
                        return;
                      }

                      if (!isValidPhone(phone)) {
                        AppSnackbar.showError(context,
                          'Invalid Phone \nPlease enter a valid phone number.',

                        );
                        return;
                      }
                      context.read<AuthCubit>().updateUserProfileInfo(
                        context: context,
                        name: nameController.text,
                        phone: phoneController.text,
                      );


                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Update profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
