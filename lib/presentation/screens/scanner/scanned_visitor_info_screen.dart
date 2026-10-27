import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/visitor_model.dart';
import '../../../logic/blocs/visitor/visitor_bloc.dart';
import '../../../logic/blocs/visitor/visitor_event.dart';
import '../../../logic/blocs/visitor/visitor_state.dart';
import '../success/status_success_screen.dart';
import '../visitors/visitor_details_screen.dart';

class ScannedVisitorInfoScreen extends StatelessWidget {
  final VisitorModel visitor;

  const ScannedVisitorInfoScreen({super.key, required this.visitor});

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VisitorBloc, VisitorState>(
      listener: (context, state) {
        if (state is VisitorLoaded) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.danger,
              ),
            );
          } else if (state.operationType == 'check_in' || state.operationType == 'check_out') {
            final activeVisitor = state.selectedVisitor ?? visitor;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => StatusSuccessScreen(
                  visitor: activeVisitor,
                  isCheckIn: state.operationType == 'check_in',
                ),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        // Fetch up to date model if available
        VisitorModel currentVisitor = visitor;
        if (state is VisitorLoaded) {
          try {
            currentVisitor = state.allVisitors.firstWhere((v) => v.id == visitor.id);
          } catch (_) {}
        }

        final isSubmitting = state is VisitorLoaded && state.isSubmitting;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              AppConstants.titleVisitorInfo,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Extracted Visitor ID Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.metricBlueBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          AppConstants.labelExtractedVisitorId,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currentVisitor.id,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Status Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 20),
                            SizedBox(width: 10),
                            Text(
                              AppConstants.labelStatusWithColon,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        StatusChip(
                          status: currentVisitor.status,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          fontSize: 13,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Other Visitor Information Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppConstants.sectionOtherVisitorInfo,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(AppConstants.labelVisitorName, currentVisitor.name),
                        const Divider(height: 16, color: AppColors.divider),
                        _buildInfoRow(AppConstants.labelMobileNumber, currentVisitor.mobile),
                        const Divider(height: 16, color: AppColors.divider),
                        _buildInfoRow(AppConstants.labelEmail, currentVisitor.email ?? '--'),
                        const Divider(height: 16, color: AppColors.divider),
                        _buildInfoRow(AppConstants.labelVisitorType, currentVisitor.visitorType),
                        const Divider(height: 16, color: AppColors.divider),
                        _buildInfoRow(AppConstants.labelProject, currentVisitor.project),
                        const Divider(height: 16, color: AppColors.divider),
                        _buildInfoRow(AppConstants.labelPurpose, currentVisitor.purpose),
                        const Divider(height: 16, color: AppColors.divider),
                        _buildInfoRow(
                          AppConstants.labelRegisteredOn,
                          DateFormatter.formatDateTime(currentVisitor.createdAt),
                        ),
                        if (currentVisitor.checkInTime != null) ...[
                          const Divider(height: 16, color: AppColors.divider),
                          _buildInfoRow(
                            AppConstants.labelCheckInTime,
                            DateFormatter.formatDateTime(currentVisitor.checkInTime),
                          ),
                        ],
                        if (currentVisitor.checkOutTime != null) ...[
                          const Divider(height: 16, color: AppColors.divider),
                          _buildInfoRow(
                            AppConstants.labelCheckOutTime,
                            DateFormatter.formatDateTime(currentVisitor.checkOutTime),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Check In Button
                  CustomButton(
                    text: AppConstants.actionCheckIn,
                    icon: Icons.login_rounded,
                    backgroundColor: AppColors.statusCheckedInText,
                    isLoading: isSubmitting && state.operationType == 'check_in',
                    onPressed: currentVisitor.canCheckIn
                        ? () {
                            context.read<VisitorBloc>().add(
                                  CheckInVisitorRequested(currentVisitor.id),
                                );
                          }
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Check Out Button
                  CustomButton(
                    text: AppConstants.actionCheckOut,
                    icon: Icons.logout_rounded,
                    isOutlined: true,
                    backgroundColor: AppColors.white,
                    textColor: AppColors.statusCheckedOutText,
                    borderColor: AppColors.purpleLight,
                    isLoading: isSubmitting && state.operationType == 'check_out',
                    onPressed: currentVisitor.canCheckOut
                        ? () {
                            context.read<VisitorBloc>().add(
                                  CheckOutVisitorRequested(currentVisitor.id),
                                );
                          }
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // View Details Button
                  CustomButton(
                    text: AppConstants.viewDetails,
                    isOutlined: true,
                    borderColor: AppColors.border,
                    textColor: AppColors.textPrimary,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VisitorDetailsScreen(visitor: currentVisitor),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
