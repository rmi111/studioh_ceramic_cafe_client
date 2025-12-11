import 'package:flutter/material.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/custom_text.dart';
import '../../model/user.dart';
import '../../utils/constant/app_colors.dart';

class UserDetailPage extends StatelessWidget {
  final UserModel user;

  const UserDetailPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios ,color: Colors.white,),
          onPressed: ()=>Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: _getUserTypeColor(user.userType),
        centerTitle: true,
        title: CustomText(text:  'User Details',color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold,),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getUserTypeColor(user.userType),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Hero(
                    tag: 'user-avatar-${user.uid}',
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage:
                      user.imageUrl != null
                          ? NetworkImage(user.imageUrl!)
                          : null,
                      child:
                      user.imageUrl == null
                          ? Text(
                        user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _getUserTypeColor(user.userType),
                        ),
                      )
                          : null,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.userType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoCard(
                    icon: Icons.email,
                    title: 'Email',
                    value: user.email,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.phone,
                    title: 'Phone Number',
                    value: user.phoneNumber ?? 'Not provided',
                    color: Colors.green,
                  ),
                  SizedBox(height: 12),


                  SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.fingerprint,
                    title: 'User ID',
                    value: user.uid,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    void Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[900],
                      fontWeight: FontWeight.w600,
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

  Color _getUserTypeColor(String userType) {
    switch (userType.toLowerCase()) {
      case 'admin':
        return AppColors.background;
    // case 'staff':
    //   return Colors.grey[700]!;
      case 'customer':
        return const Color.fromARGB(255, 185, 113, 41)!;
      default:
        return Colors.grey[100]!;
    }
  }
}
