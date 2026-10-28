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
    final isDark = AppColors.isDark(context);

    switch (status) {
      case 'Checked In':
        bg = isDark ? AppColors.metricGreenBgDark : AppColors.statusCheckedInBg;
        text = isDark ? AppColors.metricGreenTextDark : AppColors.statusCheckedInText;
        break;
      case 'Checked Out':
        bg = isDark ? AppColors.metricPurpleBgDark : AppColors.statusCheckedOutBg;
        text = isDark ? AppColors.metricPurpleTextDark : AppColors.statusCheckedOutText;
        break;
      case 'Registered':
      default:
        bg = isDark ? AppColors.metricBlueBgDark : AppColors.statusRegisteredBg;
        text = isDark ? AppColors.metricBlueTextDark : AppColors.statusRegisteredText;
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
