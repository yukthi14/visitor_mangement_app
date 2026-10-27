import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
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

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = isCheckIn ? 'Check-In Successful' : 'Check-Out Successful';
    final actionWord = isCheckIn ? 'checked in' : 'checked out';
    final timestamp = isCheckIn
        ? (visitor.checkInTime ?? DateFormatter.currentIsoTimestamp())
        : (visitor.checkOutTime ?? DateFormatter.currentIsoTimestamp());

    return Scaffold(
      backgroundColor: AppColors.white,
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
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Visitor ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: visitor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
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
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Visitor ID', visitor.id),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildSummaryRow('Project', visitor.project),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildSummaryRow('Visitor Type', visitor.visitorType),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildSummaryRow(
                      isCheckIn ? 'Check-In Time' : 'Check-Out Time',
                      DateFormatter.formatDateTime(timestamp),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // OK Button
              CustomButton(
                text: 'OK',
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
