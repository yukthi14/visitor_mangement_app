import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsets padding;

  const StatusChip({
    super.key,
    required this.status,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;

    switch (status) {
      case 'Checked In':
        bg = AppColors.statusCheckedInBg;
        text = AppColors.statusCheckedInText;
        break;
      case 'Checked Out':
        bg = AppColors.statusCheckedOutBg;
        text = AppColors.statusCheckedOutText;
        break;
      case 'Registered':
      default:
        bg = AppColors.statusRegisteredBg;
        text = AppColors.statusRegisteredText;
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
