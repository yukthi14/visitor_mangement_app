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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryColor(context),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

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

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              context.read<VisitorBloc>().add(const ClearSelectedVisitor());
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.backgroundColor(context),
            appBar: AppBar(
              backgroundColor: AppColors.surfaceColor(context),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.textPrimaryColor(context)),
                onPressed: () {
                  context.read<VisitorBloc>().add(const ClearSelectedVisitor());
                  Navigator.of(context).pop();
                },
              ),
            title: Text(
              AppConstants.titleVisitorInfo,
              style: TextStyle(
                color: AppColors.textPrimaryColor(context),
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
                      color: isDark ? AppColors.metricBlueBgDark : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.metricBlueBorderDark : AppColors.metricBlueBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppConstants.labelExtractedVisitorId,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.metricBlueTextDark : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currentVisitor.id,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.metricBlueTextDark : AppColors.primary,
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
                      color: AppColors.cardBgColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor(context)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: AppColors.textSecondaryColor(context), size: 20),
                            const SizedBox(width: 10),
                            Text(
                              AppConstants.labelStatusWithColon,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondaryColor(context),
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
                      color: AppColors.cardBgColor(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderColor(context)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.sectionOtherVisitorInfo,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryColor(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(context, AppConstants.labelVisitorName, currentVisitor.name),
                        Divider(height: 16, color: AppColors.dividerColor(context)),
                        _buildInfoRow(context, AppConstants.labelMobileNumber, currentVisitor.mobile),
                        Divider(height: 16, color: AppColors.dividerColor(context)),
                        _buildInfoRow(context, AppConstants.labelEmail, currentVisitor.email ?? '--'),
                        Divider(height: 16, color: AppColors.dividerColor(context)),
                        _buildInfoRow(context, AppConstants.labelVisitorType, currentVisitor.visitorType),
                        Divider(height: 16, color: AppColors.dividerColor(context)),
                        _buildInfoRow(context, AppConstants.labelProject, currentVisitor.project),
                        Divider(height: 16, color: AppColors.dividerColor(context)),
                        _buildInfoRow(context, AppConstants.labelPurpose, currentVisitor.purpose),
                        Divider(height: 16, color: AppColors.dividerColor(context)),
                        _buildInfoRow(
                          context,
                          AppConstants.labelRegisteredOn,
                          DateFormatter.formatDateTime(currentVisitor.createdAt),
                        ),
                        if (currentVisitor.checkInTime != null) ...[
                          Divider(height: 16, color: AppColors.dividerColor(context)),
                          _buildInfoRow(
                            context,
                            AppConstants.labelCheckInTime,
                            DateFormatter.formatDateTime(currentVisitor.checkInTime),
                          ),
                        ],
                        if (currentVisitor.checkOutTime != null) ...[
                          Divider(height: 16, color: AppColors.dividerColor(context)),
                          _buildInfoRow(
                            context,
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
                    backgroundColor: AppColors.cardBgColor(context),
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
                    backgroundColor: AppColors.cardBgColor(context),
                    borderColor: AppColors.borderColor(context),
                    textColor: AppColors.textPrimaryColor(context),
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
        ),
      );
    },
  );
}
}
