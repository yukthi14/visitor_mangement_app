import 'package:equatable/equatable.dart';
import '../../../data/models/visitor_model.dart';

abstract class VisitorState extends Equatable {
  const VisitorState();

  @override
  List<Object?> get props => [];
}

class VisitorInitial extends VisitorState {}

class VisitorLoading extends VisitorState {}

class VisitorLoaded extends VisitorState {
  final List<VisitorModel> allVisitors;
  final List<VisitorModel> filteredVisitors;
  final String searchQuery;
  final String? selectedProject;
  final String? selectedStatus;
  final VisitorModel? selectedVisitor;
  final VisitorModel? scannedVisitor;
  final bool isSubmitting;
  final String baseUrl;
  final String? successMessage;
  final String? errorMessage;
  final String? operationType; // 'check_in', 'check_out', 'register', 'update', 'delete'

  const VisitorLoaded({
    required this.allVisitors,
    required this.filteredVisitors,
    this.searchQuery = '',
    this.selectedProject,
    this.selectedStatus,
    this.selectedVisitor,
    this.scannedVisitor,
    this.isSubmitting = false,
    required this.baseUrl,
    this.successMessage,
    this.errorMessage,
    this.operationType,
  });

  // Today statistics
  int get totalVisitorsToday {
    final now = DateTime.now();
    return allVisitors.where((v) {
      try {
        final date = DateTime.parse(v.createdAt).toLocal();
        return date.year == now.year && date.month == now.month && date.day == now.day;
      } catch (_) {
        return false;
      }
    }).length;
  }

  int get currentlyCheckedIn {
    return allVisitors.where((v) => v.status == 'Checked In').length;
  }

  int get checkedOutToday {
    final now = DateTime.now();
    return allVisitors.where((v) {
      if (v.status != 'Checked Out') return false;
      if (v.checkOutTime != null) {
        try {
          final date = DateTime.parse(v.checkOutTime!).toLocal();
          return date.year == now.year && date.month == now.month && date.day == now.day;
        } catch (_) {
          return true;
        }
      }
      return true;
    }).length;
  }

  VisitorLoaded copyWith({
    List<VisitorModel>? allVisitors,
    List<VisitorModel>? filteredVisitors,
    String? searchQuery,
    String? selectedProject,
    String? selectedStatus,
    VisitorModel? selectedVisitor,
    bool clearSelectedVisitor = false,
    VisitorModel? scannedVisitor,
    bool clearScannedVisitor = false,
    bool? isSubmitting,
    String? baseUrl,
    String? successMessage,
    bool clearSuccessMessage = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? operationType,
  }) {
    return VisitorLoaded(
      allVisitors: allVisitors ?? this.allVisitors,
      filteredVisitors: filteredVisitors ?? this.filteredVisitors,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedProject: selectedProject ?? this.selectedProject,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedVisitor: clearSelectedVisitor ? null : (selectedVisitor ?? this.selectedVisitor),
      scannedVisitor: clearScannedVisitor ? null : (scannedVisitor ?? this.scannedVisitor),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      baseUrl: baseUrl ?? this.baseUrl,
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      operationType: operationType ?? this.operationType,
    );
  }

  @override
  List<Object?> get props => [
        allVisitors,
        filteredVisitors,
        searchQuery,
        selectedProject,
        selectedStatus,
        selectedVisitor,
        scannedVisitor,
        isSubmitting,
        baseUrl,
        successMessage,
        errorMessage,
        operationType,
      ];
}

class VisitorError extends VisitorState {
  final String message;
  const VisitorError(this.message);

  @override
  List<Object?> get props => [message];
}
