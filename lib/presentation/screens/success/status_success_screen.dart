import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/models/visitor_model.dart';

class StatusSuccessScreen extends StatelessWidget {
  final VisitorModel visitor;
  final bool isCheckIn;

  const StatusSuccessScreen({
    super.key,
    required this.visitor,
    required this.isCheckIn,
  });

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = isCheckIn ? AppConstants.titleCheckInSuccess : AppConstants.titleCheckOutSuccess;
    final actionWord = isCheckIn ? AppConstants.successCheckedInWord : AppConstants.successCheckedOutWord;
    final timestamp = isCheckIn
        ? (visitor.checkInTime ?? DateFormatter.currentIsoTimestamp())
        : (visitor.checkOutTime ?? DateFormatter.currentIsoTimestamp());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Green Check Circle
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor(context),
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Visitor ',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryColor(context),
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: visitor.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor(context),
                      ),
                    ),
                    TextSpan(
                      text: ' has been\n$actionWord successfully.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Summary Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBgColor(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderColor(context)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(context, AppConstants.labelVisitorId, visitor.id),
                    Divider(height: 1, color: AppColors.dividerColor(context)),
                    _buildSummaryRow(context, AppConstants.labelProject, visitor.project),
                    Divider(height: 1, color: AppColors.dividerColor(context)),
                    _buildSummaryRow(context, AppConstants.labelVisitorType, visitor.visitorType),
                    Divider(height: 1, color: AppColors.dividerColor(context)),
                    _buildSummaryRow(
                      context,
                      isCheckIn ? AppConstants.labelCheckInTime : AppConstants.labelCheckOutTime,
                      DateFormatter.formatDateTime(timestamp),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // OK Button
              CustomButton(
                text: AppConstants.ok,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
