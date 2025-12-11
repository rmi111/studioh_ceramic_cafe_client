import 'package:flutter/material.dart';
import 'package:studioh_ceramic_cafe_client/utils/constant/app_colors.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/custom_text.dart';


class DefaultAppBar extends StatelessWidget {
  final Widget? trailing;
  final Widget? leading;
  final String title;
  const DefaultAppBar({
    super.key,
    required this.title,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 15, right: 15, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          leading ??
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: AppColors.button,
                ),
              ),
          SizedBox(width: 10),
          CustomText(
              text: title, fontSizeFactor: 1.2, fontWeight: FontWeight.bold),
          Spacer(),
          trailing ?? SizedBox.shrink(),
        ],
      ),
    );
  }
}
