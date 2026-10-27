import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/visitor_model.dart';
import '../../../logic/blocs/visitor/visitor_bloc.dart';
import '../../../logic/blocs/visitor/visitor_event.dart';
import '../../../logic/blocs/visitor/visitor_state.dart';
import '../success/status_success_screen.dart';
import 'register_visitor_screen.dart';

class VisitorDetailsScreen extends StatelessWidget {
  final VisitorModel visitor;

  const VisitorDetailsScreen({super.key, required this.visitor});

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
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
      ),
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
        // Find latest updated model from state if available
        VisitorModel currentVisitor = visitor;
        if (state is VisitorLoaded) {
          try {
            currentVisitor = state.allVisitors.firstWhere((v) => v.id == visitor.id);
          } catch (_) {}
        }

        final isSubmitting = state is VisitorLoaded && state.isSubmitting;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Visitor Details',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Profile Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE2E8F8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                  size: 34,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentVisitor.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      currentVisitor.mobile,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${currentVisitor.project}  •  ${currentVisitor.visitorType}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              StatusChip(status: currentVisitor.status),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Detail Rows Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow('Visitor ID', currentVisitor.id),
                              const Divider(height: 14, color: AppColors.divider),
                              _buildDetailRow('Email', currentVisitor.email ?? '--'),
                              const Divider(height: 14, color: AppColors.divider),
                              _buildDetailRow('Purpose of Visit', currentVisitor.purpose),
                              const Divider(height: 14, color: AppColors.divider),
                              _buildDetailRow(
                                'Registered On',
                                DateFormatter.formatDateTime(currentVisitor.createdAt),
                              ),
                              if (currentVisitor.checkInTime != null) ...[
                                const Divider(height: 14, color: AppColors.divider),
                                _buildDetailRow(
                                  'Check-In Time',
                                  DateFormatter.formatDateTime(currentVisitor.checkInTime),
                                ),
                              ],
                              if (currentVisitor.checkOutTime != null) ...[
                                const Divider(height: 14, color: AppColors.divider),
                                _buildDetailRow(
                                  'Check-Out Time',
                                  DateFormatter.formatDateTime(currentVisitor.checkOutTime),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // QR Code Box
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: QrImageView(
                              data: currentVisitor.id,
                              version: QrVersions.auto,
                              size: 150.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'ID: ${currentVisitor.id}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Bottom Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      // Action based on status
                      if (currentVisitor.canCheckIn) ...[
                        Expanded(
                          flex: 2,
                          child: CustomButton(
                            text: 'Check In',
                            icon: Icons.login_rounded,
                            backgroundColor: const Color(0xFF16A34A),
                            isLoading: isSubmitting,
                            onPressed: () {
                              context.read<VisitorBloc>().add(
                                    CheckInVisitorRequested(currentVisitor.id),
                                  );
                            },
                          ),
                        ),
                      ] else if (currentVisitor.canCheckOut) ...[
                        Expanded(
                          flex: 2,
                          child: CustomButton(
                            text: 'Scan to Check Out',
                            icon: Icons.qr_code_scanner_rounded,
                            backgroundColor: AppColors.primary,
                            isLoading: isSubmitting,
                            onPressed: () {
                              context.read<VisitorBloc>().add(
                                    CheckOutVisitorRequested(currentVisitor.id),
                                  );
                            },
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Visit Completed',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(width: 12),

                      // Edit Button
                      Expanded(
                        flex: 1,
                        child: CustomButton(
                          text: 'Edit',
                          isOutlined: true,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RegisterVisitorScreen(visitorToEdit: currentVisitor),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
