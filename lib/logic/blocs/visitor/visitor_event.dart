import '../../../data/models/visitor_model.dart';

abstract class VisitorEvent {
  const VisitorEvent();
}

class LoadVisitors extends VisitorEvent {
  final bool isRefresh;
  const LoadVisitors({this.isRefresh = false});
}

class SearchVisitors extends VisitorEvent {
  final String query;
  const SearchVisitors(this.query);
}

class FilterVisitors extends VisitorEvent {
  final String? project;
  final String? status;
  const FilterVisitors({this.project, this.status});
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
}

class UpdateVisitorSubmitted extends VisitorEvent {
  final VisitorModel visitor;
  const UpdateVisitorSubmitted(this.visitor);
}

class CheckInVisitorRequested extends VisitorEvent {
  final String visitorId;
  const CheckInVisitorRequested(this.visitorId);
}

class CheckOutVisitorRequested extends VisitorEvent {
  final String visitorId;
  const CheckOutVisitorRequested(this.visitorId);
}

class DeleteVisitorRequested extends VisitorEvent {
  final String visitorId;
  const DeleteVisitorRequested(this.visitorId);
}

class ScanVisitorRequested extends VisitorEvent {
  final String rawQrCode;
  const ScanVisitorRequested(this.rawQrCode);
}

class SelectVisitor extends VisitorEvent {
  final VisitorModel visitor;
  const SelectVisitor(this.visitor);
}

class ClearSelectedVisitor extends VisitorEvent {
  const ClearSelectedVisitor();
}

class UpdateBaseUrlRequested extends VisitorEvent {
  final String newBaseUrl;
  const UpdateBaseUrlRequested(this.newBaseUrl);
}
