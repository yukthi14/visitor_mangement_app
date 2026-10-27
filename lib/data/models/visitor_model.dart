import 'dart:convert';
import 'package:equatable/equatable.dart';

class VisitorModel extends Equatable {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String visitorType;
  final String project;
  final String purpose;
  final String status;
  final String createdAt;
  final String? checkInTime;
  final String? checkOutTime;

  const VisitorModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    required this.visitorType,
    required this.project,
    required this.purpose,
    required this.status,
    required this.createdAt,
    this.checkInTime,
    this.checkOutTime,
  });

  bool get isRegistered => status == 'Registered';
  bool get isCheckedIn => status == 'Checked In';
  bool get isCheckedOut => status == 'Checked Out';

  bool get canCheckIn => isRegistered;
  bool get canCheckOut => isCheckedIn;

  VisitorModel copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? visitorType,
    String? project,
    String? purpose,
    String? status,
    String? createdAt,
    String? checkInTime,
    String? checkOutTime,
  }) {
    return VisitorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      visitorType: visitorType ?? this.visitorType,
      project: project ?? this.project,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
    );
  }

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      email: json['email'] as String?,
      visitorType: (json['visitor_type'] ?? json['visitorType'] ?? 'Customer') as String,
      project: (json['project'] ?? 'Project A') as String,
      purpose: (json['purpose'] ?? '') as String,
      status: (json['status'] ?? 'Registered') as String,
      createdAt: (json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()) as String,
      checkInTime: (json['check_in_time'] ?? json['checkInTime']) as String?,
      checkOutTime: (json['check_out_time'] ?? json['checkOutTime']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'visitor_type': visitorType,
      'project': project,
      'purpose': purpose,
      'status': status,
      'created_at': createdAt,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
    };
  }

  /// For check-in PATCH/PUT
  Map<String, dynamic> toCheckInJson(String time) {
    return {
      'status': 'Checked In',
      'check_in_time': time,
    };
  }

  /// For check-out PATCH/PUT
  Map<String, dynamic> toCheckOutJson(String time) {
    return {
      'status': 'Checked Out',
      'check_out_time': time,
    };
  }

  /// Formats visitor data for QR encoding so scanning displays visitor ID, status, and details
  String toQrData() {
    return jsonEncode({
      'visitor_id': id,
      'name': name,
      'status': status,
      'mobile': mobile,
      if (email != null && email!.isNotEmpty) 'email': email,
      'visitor_type': visitorType,
      'project': project,
      'purpose': purpose,
      if (checkInTime != null) 'check_in_time': checkInTime,
      if (checkOutTime != null) 'check_out_time': checkOutTime,
    });
  }

  @override
  List<Object?> get props => [
        id,
        name,
        mobile,
        email,
        visitorType,
        project,
        purpose,
        status,
        createdAt,
        checkInTime,
        checkOutTime,
      ];
}
