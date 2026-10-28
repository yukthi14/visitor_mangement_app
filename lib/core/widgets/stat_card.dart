import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

enum StatCardType { totalToday, checkedIn, checkedOut }

class StatCard extends StatelessWidget {
  final StatCardType type;
  final int count;
  final String? customTitle;

  const StatCard({
    super.key,
    required this.type,
    required this.count,
    this.customTitle,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    Color bgColor;
    Color borderColor;
    Color countColor;
    Widget iconWidget;

    switch (type) {
      case StatCardType.totalToday:
        title = customTitle ?? AppConstants.statTotalToday;
        bgColor = AppColors.metricBlueBg;
        borderColor = AppColors.metricBlueBorder;
        countColor = AppColors.metricBlueText;
        iconWidget = const Icon(Icons.person, size: 20, color: AppColors.primary);
        break;
      case StatCardType.checkedIn:
        title = customTitle ?? AppConstants.statCheckedIn;
        bgColor = AppColors.metricGreenBg;
        borderColor = AppColors.metricGreenBorder;
        countColor = AppColors.metricGreenText;
        iconWidget = Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: AppColors.statusCheckedInText,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 14, color: AppColors.white),
        );
        break;
      case StatCardType.checkedOut:
        title = customTitle ?? AppConstants.statCheckedOut;
        bgColor = AppColors.metricPurpleBg;
        borderColor = AppColors.metricPurpleBorder;
        countColor = AppColors.metricPurpleText;
        iconWidget = const Icon(Icons.logout_rounded, size: 20, color: AppColors.statusCheckedOutText);
        break;
    }

    return Expanded(
      child: Container(
        height: 125,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: countColor,
                  ),
                ),
                iconWidget,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
