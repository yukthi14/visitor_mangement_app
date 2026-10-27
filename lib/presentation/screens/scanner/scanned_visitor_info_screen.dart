import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
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
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Visitor Information',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Visitor Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            color: AppColors.avatarBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 42,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Name
                        Text(
                          currentVisitor.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Mobile
                        Text(
                          currentVisitor.mobile,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Project & Type
                        Text(
                          '${currentVisitor.project}  •  ${currentVisitor.visitorType}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Status Chip
                        StatusChip(
                          status: currentVisitor.status,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          fontSize: 13,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Check In Button
                  CustomButton(
                    text: 'Check In',
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
                  const SizedBox(height: 14),

                  // Check Out Button
                  CustomButton(
                    text: 'Check Out',
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
                  const SizedBox(height: 14),

                  // View Details Button
                  CustomButton(
                    text: 'View Details',
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

                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
