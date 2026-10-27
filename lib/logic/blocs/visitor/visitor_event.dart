import 'package:equatable/equatable.dart';
import '../../../data/models/visitor_model.dart';

abstract class VisitorEvent extends Equatable {
  const VisitorEvent();

  @override
  List<Object?> get props => [];
}

class LoadVisitors extends VisitorEvent {
  final bool isRefresh;
  const LoadVisitors({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class SearchVisitors extends VisitorEvent {
  final String query;
  const SearchVisitors(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterVisitors extends VisitorEvent {
  final String? project;
  final String? status;
  const FilterVisitors({this.project, this.status});

  @override
  List<Object?> get props => [project, status];
}

class RegisterVisitorSubmitted extends VisitorEvent {
  final String name;
  final String mobile;
  final String? email;
  final String visitorType;
  final String project;
  final String purpose;

  const RegisterVisitorSubmitted({
    required this.name,
    required this.mobile,
    this.email,
    required this.visitorType,
    required this.project,
    required this.purpose,
  });

  @override
  List<Object?> get props => [name, mobile, email, visitorType, project, purpose];
}

class UpdateVisitorSubmitted extends VisitorEvent {
  final VisitorModel visitor;
  const UpdateVisitorSubmitted(this.visitor);

  @override
  List<Object?> get props => [visitor];
}

class CheckInVisitorRequested extends VisitorEvent {
  final String visitorId;
  const CheckInVisitorRequested(this.visitorId);

  @override
  List<Object?> get props => [visitorId];
}

class CheckOutVisitorRequested extends VisitorEvent {
  final String visitorId;
  const CheckOutVisitorRequested(this.visitorId);

  @override
  List<Object?> get props => [visitorId];
}

class DeleteVisitorRequested extends VisitorEvent {
  final String visitorId;
  const DeleteVisitorRequested(this.visitorId);

  @override
  List<Object?> get props => [visitorId];
}

class ScanVisitorRequested extends VisitorEvent {
  final String rawQrCode;
  const ScanVisitorRequested(this.rawQrCode);

  @override
  List<Object?> get props => [rawQrCode];
}

class SelectVisitor extends VisitorEvent {
  final VisitorModel visitor;
  const SelectVisitor(this.visitor);

  @override
  List<Object?> get props => [visitor];
}

class ClearSelectedVisitor extends VisitorEvent {}

class UpdateBaseUrlRequested extends VisitorEvent {
  final String newBaseUrl;
  const UpdateBaseUrlRequested(this.newBaseUrl);

  @override
  List<Object?> get props => [newBaseUrl];
}
