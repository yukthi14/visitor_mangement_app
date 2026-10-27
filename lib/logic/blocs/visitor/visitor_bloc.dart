import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/visitor_model.dart';
import '../../../data/repositories/visitor_repository.dart';
import 'visitor_event.dart';
import 'visitor_state.dart';

class VisitorBloc extends Bloc<VisitorEvent, VisitorState> {
  final VisitorRepository repository;

  VisitorBloc({required this.repository}) : super(VisitorInitial()) {
    on<LoadVisitors>(_onLoadVisitors);
    on<SearchVisitors>(_onSearchVisitors);
    on<FilterVisitors>(_onFilterVisitors);
    on<RegisterVisitorSubmitted>(_onRegisterVisitorSubmitted);
    on<UpdateVisitorSubmitted>(_onUpdateVisitorSubmitted);
    on<CheckInVisitorRequested>(_onCheckInVisitorRequested);
    on<CheckOutVisitorRequested>(_onCheckOutVisitorRequested);
    on<DeleteVisitorRequested>(_onDeleteVisitorRequested);
    on<ScanVisitorRequested>(_onScanVisitorRequested);
    on<SelectVisitor>(_onSelectVisitor);
    on<ClearSelectedVisitor>(_onClearSelectedVisitor);
    on<UpdateBaseUrlRequested>(_onUpdateBaseUrlRequested);
  }

  List<VisitorModel> _applyFilters({
    required List<VisitorModel> list,
    required String query,
    String? project,
    String? status,
  }) {
    return list.where((visitor) {
      // Search query filter (matches name or mobile or visitor ID)
      final cleanQuery = query.trim().toLowerCase();
      final matchesSearch = cleanQuery.isEmpty ||
          visitor.name.toLowerCase().contains(cleanQuery) ||
          visitor.mobile.contains(cleanQuery) ||
          visitor.id.toLowerCase().contains(cleanQuery);

      // Project filter
      final matchesProject = project == null || project.isEmpty || visitor.project == project;

      // Status filter
      final matchesStatus = status == null || status.isEmpty || visitor.status == status;

      return matchesSearch && matchesProject && matchesStatus;
    }).toList();
  }

  Future<void> _onLoadVisitors(LoadVisitors event, Emitter<VisitorState> emit) async {
    final current = state;
    final currentQuery = current is VisitorLoaded ? current.searchQuery : '';
    final currentProject = current is VisitorLoaded ? current.selectedProject : null;
    final currentStatus = current is VisitorLoaded ? current.selectedStatus : null;

    if (!event.isRefresh && current is! VisitorLoaded) {
      emit(VisitorLoading());
    }

    try {
      final visitors = await repository.getVisitors();
      final baseUrl = await repository.getBaseUrl();
      final filtered = _applyFilters(
        list: visitors,
        query: currentQuery,
        project: currentProject,
        status: currentStatus,
      );

      // Preserve or update currently selected visitor
      VisitorModel? updatedSelected;
      if (current is VisitorLoaded && current.selectedVisitor != null) {
        try {
          updatedSelected = visitors.firstWhere((v) => v.id == current.selectedVisitor!.id);
        } catch (_) {
          updatedSelected = null;
        }
      }

      emit(VisitorLoaded(
        allVisitors: visitors,
        filteredVisitors: filtered,
        searchQuery: currentQuery,
        selectedProject: currentProject,
        selectedStatus: currentStatus,
        selectedVisitor: updatedSelected,
        baseUrl: baseUrl,
      ));
    } catch (e) {
      emit(VisitorError(e.toString()));
    }
  }

  void _onSearchVisitors(SearchVisitors event, Emitter<VisitorState> emit) {
    if (state is VisitorLoaded) {
      final loaded = state as VisitorLoaded;
      final filtered = _applyFilters(
        list: loaded.allVisitors,
        query: event.query,
        project: loaded.selectedProject,
        status: loaded.selectedStatus,
      );
      emit(loaded.copyWith(
        searchQuery: event.query,
        filteredVisitors: filtered,
      ));
    }
  }

  void _onFilterVisitors(FilterVisitors event, Emitter<VisitorState> emit) {
    if (state is VisitorLoaded) {
      final loaded = state as VisitorLoaded;
      final filtered = _applyFilters(
        list: loaded.allVisitors,
        query: loaded.searchQuery,
        project: event.project,
        status: event.status,
      );
      emit(loaded.copyWith(
        selectedProject: event.project,
        selectedStatus: event.status,
        filteredVisitors: filtered,
      ));
    }
  }

  Future<void> _onRegisterVisitorSubmitted(
    RegisterVisitorSubmitted event,
    Emitter<VisitorState> emit,
  ) async {
    if (state is VisitorLoaded) {
      final loaded = state as VisitorLoaded;
      emit(loaded.copyWith(isSubmitting: true, clearErrorMessage: true));

      try {
        final newVisitor = await repository.registerVisitor(
          name: event.name,
          mobile: event.mobile,
          email: event.email,
          visitorType: event.visitorType,
          project: event.project,
          purpose: event.purpose,
        );

        final updatedList = [newVisitor, ...loaded.allVisitors.where((v) => v.id != newVisitor.id)];
        final filtered = _applyFilters(
          list: updatedList,
          query: loaded.searchQuery,
          project: loaded.selectedProject,
          status: loaded.selectedStatus,
        );

        emit(loaded.copyWith(
          allVisitors: updatedList,
          filteredVisitors: filtered,
          selectedVisitor: newVisitor,
          isSubmitting: false,
          successMessage: 'Visitor registered successfully!',
          operationType: 'register',
        ));
      } catch (e) {
        emit(loaded.copyWith(
          isSubmitting: false,
          errorMessage: 'Failed to register visitor: ${e.toString()}',
        ));
      }
    }
  }

  Future<void> _onUpdateVisitorSubmitted(
    UpdateVisitorSubmitted event,
    Emitter<VisitorState> emit,
  ) async {
    if (state is VisitorLoaded) {
      final loaded = state as VisitorLoaded;
      emit(loaded.copyWith(isSubmitting: true, clearErrorMessage: true));

      try {
        final updated = await repository.updateVisitor(event.visitor);

        final updatedList = loaded.allVisitors.map((v) => v.id == updated.id ? updated : v).toList();
        final filtered = _applyFilters(
          list: updatedList,
          query: loaded.searchQuery,
          project: loaded.selectedProject,
          status: loaded.selectedStatus,
        );

        emit(loaded.copyWith(
          allVisitors: updatedList,
          filteredVisitors: filtered,
          selectedVisitor: updated,
          isSubmitting: false,
          successMessage: 'Visitor details updated successfully!',
          operationType: 'update',
        ));
      } catch (e) {
        emit(loaded.copyWith(
          isSubmitting: false,
          errorMessage: 'Failed to update visitor: ${e.toString()}',
        ));
      }
    }
  }

  Future<void> _onCheckInVisitorRequested(
    CheckInVisitorRequested event,
    Emitter<VisitorState> emit,
  ) async {
    if (state is VisitorLoaded) {
      final loaded = state as VisitorLoaded;
      emit(loaded.copyWith(isSubmitting: true, clearErrorMessage: true));

      try {
        final updated = await repository.checkInVisitor(event.visitorId);

        final updatedList = loaded.allVisitors.map((v) => v.id == updated.id ? updated : v).toList();
        final filtered = _applyFilters(
          list: updatedList,
          query: loaded.searchQuery,
          project: loaded.selectedProject,
          status: loaded.selectedStatus,
        );

        emit(loaded.copyWith(
          allVisitors: updatedList,
          filteredVisitors: filtered,
          selectedVisitor: updated,
          scannedVisitor: updated,
          isSubmitting: false,
          successMessage: 'Visitor checked in successfully!',
          operationType: 'check_in',
        ));
      } catch (e) {
        emit(loaded.copyWith(
          isSubmitting: false,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }

  Future<void> _onCheckOutVisitorRequested(
    CheckOutVisitorRequested event,
    Emitter<VisitorState> emit,
  ) async {
    if (state is VisitorLoaded) {
      final loaded = state as VisitorLoaded;
      emit(loaded.copyWith(isSubmitting: true, clearErrorMessage: true));

      try {
        final updated = await repository.checkOutVisitor(event.visitorId);

        final updatedList = loaded.allVisitors.map((v) => v.id == updated.id ? updated : v).toList();
        final filtered = _applyFilters(
          list: updatedList,
          query: loaded.searchQuery,
          project: loaded.selectedProject,
          status: loaded.selectedStatus,
        );

        emit(loaded.copyWith(
          allVisitors: updatedList,
          filteredVisitors: filtered,
          selectedVisitor: updated,
          scannedVisitor: updated,
          isSubmitting: false,
          successMessage: 'Visitor checked out successfully!',
          operationType: 'check_out',
        ));
      } catch (e) {
        emit(loaded.copyWith(
          isSubmitting: false,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }

  Future<void> _onDeleteVisitorRequested(
    DeleteVisitorRequested event,
    Emitter<VisitorState> emit,
  ) async {
    if (state is VisitorLoaded) {
      final loaded = state as VisitorLoaded;
      emit(loaded.copyWith(isSubmitting: true, clearErrorMessage: true));

      try {
        await repository.deleteVisitor(event.visitorId);

        final updatedList = loaded.allVisitors.where((v) => v.id != event.visitorId).toList();
        final filtered = _applyFilters(
          list: updatedList,
          query: loaded.searchQuery,
          project: loaded.selectedProject,
          status: loaded.selectedStatus,
        );

        emit(loaded.copyWith(
          allVisitors: updatedList,
          filteredVisitors: filtered,
          clearSelectedVisitor: loaded.selectedVisitor?.id == event.visitorId,
          clearScannedVisitor: loaded.scannedVisitor?.id == event.visitorId,
          isSubmitting: false,
          successMessage: 'Visitor record deleted successfully!',
          operationType: 'delete',
        ));
      } catch (e) {
        emit(loaded.copyWith(
          isSubmitting: false,
          errorMessage: 'Failed to delete visitor: ${e.toString()}',
        ));
      }
    }
  }

  String? extractVisitorId(String rawQr) {
    final trimmed = rawQr.trim();
    if (trimmed.isEmpty) return null;

    // 1. JSON payload e.g. {"id": "VST001"} or {"visitor_id": "VST001"}
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          if (decoded['visitor_id'] != null) return decoded['visitor_id'].toString().trim();
          if (decoded['id'] != null) return decoded['id'].toString().trim();
          if (decoded['visitorId'] != null) return decoded['visitorId'].toString().trim();
        }
      } catch (_) {}
    }

    // 2. URL or deep-link parameter e.g. ?visitor_id=VST001 or /visitors/VST001
    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      if (uri.queryParameters.containsKey('visitor_id')) {
        return uri.queryParameters['visitor_id']!.trim();
      }
      if (uri.queryParameters.containsKey('id')) {
        return uri.queryParameters['id']!.trim();
      }
      if (uri.pathSegments.isNotEmpty) {
        final lastSegment = uri.pathSegments.last.trim();
        if (lastSegment.toUpperCase().startsWith('VST') || RegExp(r'^\d+$').hasMatch(lastSegment)) {
          return lastSegment;
        }
      }
    }

    // 3. Formatted VST pattern e.g. VST001, VST123
    final match = RegExp(r'\b(VST\d+)\b', caseSensitive: false).firstMatch(trimmed);
    if (match != null) {
      return match.group(1)!.toUpperCase();
    }

    // 4. Clean alphanumeric ID (3-20 characters without spaces or special symbols)
    if (RegExp(r'^[A-Za-z0-9_-]{3,20}$').hasMatch(trimmed)) {
      return trimmed.toUpperCase();
    }

    return null;
  }

  Future<void> _onScanVisitorRequested(
    ScanVisitorRequested event,
    Emitter<VisitorState> emit,
  ) async {
    if (state is VisitorLoaded) {
      final loaded = state as VisitorLoaded;
      final visitorId = extractVisitorId(event.rawQrCode);

      // Validate format
      if (visitorId == null) {
        emit(loaded.copyWith(
          clearScannedVisitor: true,
          errorMessage: AppConstants.invalidQRMessage,
        ));
        return;
      }

      // Retrieve visitor details from the API / repository
      try {
        final lookedUp = await repository.getVisitorById(visitorId);
        if (lookedUp != null) {
          // Synchronize with local state list
          final existingIndex = loaded.allVisitors.indexWhere((v) => v.id.toLowerCase() == lookedUp.id.toLowerCase());
          List<VisitorModel> updatedList;
          if (existingIndex >= 0) {
            updatedList = List<VisitorModel>.from(loaded.allVisitors)..[existingIndex] = lookedUp;
          } else {
            updatedList = [lookedUp, ...loaded.allVisitors];
          }

          final filtered = _applyFilters(
            list: updatedList,
            query: loaded.searchQuery,
            project: loaded.selectedProject,
            status: loaded.selectedStatus,
          );

          emit(loaded.copyWith(
            allVisitors: updatedList,
            filteredVisitors: filtered,
            scannedVisitor: lookedUp,
            selectedVisitor: lookedUp,
            clearErrorMessage: true,
          ));
        } else {
          emit(loaded.copyWith(
            clearScannedVisitor: true,
            errorMessage: 'No visitor found with ID "$visitorId". Please scan a valid visitor pass.',
          ));
        }
      } catch (e) {
        emit(loaded.copyWith(
          clearScannedVisitor: true,
          errorMessage: 'Failed to retrieve visitor details: ${e.toString()}',
        ));
      }
    }
  }

  void _onSelectVisitor(SelectVisitor event, Emitter<VisitorState> emit) {
    if (state is VisitorLoaded) {
      emit((state as VisitorLoaded).copyWith(
        selectedVisitor: event.visitor,
        clearErrorMessage: true,
      ));
    }
  }

  void _onClearSelectedVisitor(ClearSelectedVisitor event, Emitter<VisitorState> emit) {
    if (state is VisitorLoaded) {
      emit((state as VisitorLoaded).copyWith(
        clearSelectedVisitor: true,
        clearScannedVisitor: true,
      ));
    }
  }

  Future<void> _onUpdateBaseUrlRequested(
    UpdateBaseUrlRequested event,
    Emitter<VisitorState> emit,
  ) async {
    await repository.setBaseUrl(event.newBaseUrl);
    add(const LoadVisitors(isRefresh: true));
  }
}
