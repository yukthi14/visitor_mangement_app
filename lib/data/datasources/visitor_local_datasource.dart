import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../models/visitor_model.dart';

abstract class VisitorLocalDataSource {
  Future<List<VisitorModel>> getCachedVisitors();
  Future<void> cacheVisitors(List<VisitorModel> visitors);
  Future<VisitorModel?> getVisitorById(String id);
  Future<void> saveVisitorLocally(VisitorModel visitor);
  Future<void> deleteVisitorLocally(String id);
  Future<String> getBaseUrl();
  Future<void> saveBaseUrl(String url);
}

class VisitorLocalDataSourceImpl implements VisitorLocalDataSource {
  final SharedPreferences sharedPreferences;

  VisitorLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<String> getBaseUrl() async {
    return sharedPreferences.getString(AppConstants.prefBaseUrl) ?? ApiConstants.defaultBaseUrl;
  }

  @override
  Future<void> saveBaseUrl(String url) async {
    await sharedPreferences.setString(AppConstants.prefBaseUrl, url);
  }

  @override
  Future<List<VisitorModel>> getCachedVisitors() async {
    final rawJson = sharedPreferences.getString(AppConstants.prefCachedVisitors);
    if (rawJson == null || rawJson.isEmpty) {
      // Return default initial demo visitors matching the wireframes
      final initialList = _getInitialSampleVisitors();
      await cacheVisitors(initialList);
      return initialList;
    }
    try {
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded.map((item) => VisitorModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getInitialSampleVisitors();
    }
  }

  @override
  Future<void> cacheVisitors(List<VisitorModel> visitors) async {
    final listJson = visitors.map((v) => v.toJson()).toList();
    await sharedPreferences.setString(AppConstants.prefCachedVisitors, jsonEncode(listJson));
  }

  @override
  Future<VisitorModel?> getVisitorById(String id) async {
    final list = await getCachedVisitors();
    try {
      return list.firstWhere((v) => v.id.toLowerCase() == id.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveVisitorLocally(VisitorModel visitor) async {
    final list = await getCachedVisitors();
    final index = list.indexWhere((v) => v.id == visitor.id);
    if (index >= 0) {
      list[index] = visitor;
    } else {
      list.insert(0, visitor);
    }
    await cacheVisitors(list);
  }

  @override
  Future<void> deleteVisitorLocally(String id) async {
    final list = await getCachedVisitors();
    list.removeWhere((v) => v.id == id);
    await cacheVisitors(list);
  }

  List<VisitorModel> _getInitialSampleVisitors() {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    return [
      VisitorModel(
        id: 'VST001',
        name: 'Aarav Sharma',
        mobile: '9876543210',
        email: 'aarav@gmail.com',
        visitorType: 'Customer',
        project: 'Project A',
        purpose: 'Meeting',
        status: 'Checked In',
        createdAt: '${todayStr}T09:15:00',
        checkInTime: '${todayStr}T09:30:00',
        checkOutTime: null,
      ),
      VisitorModel(
        id: 'VST002',
        name: 'Neha Patel',
        mobile: '9123456789',
        email: 'neha.patel@gmail.com',
        visitorType: 'Vendor',
        project: 'Project B',
        purpose: 'Material Delivery',
        status: 'Registered',
        createdAt: '${todayStr}T10:00:00',
        checkInTime: null,
        checkOutTime: null,
      ),
      VisitorModel(
        id: 'VST003',
        name: 'Rohit Kumar',
        mobile: '9988776655',
        email: 'rohit.kumar@outlook.com',
        visitorType: 'Customer',
        project: 'Project A',
        purpose: 'Flat Inspection',
        status: 'Checked Out',
        createdAt: '${todayStr}T08:30:00',
        checkInTime: '${todayStr}T08:45:00',
        checkOutTime: '${todayStr}T10:15:00',
      ),
      VisitorModel(
        id: 'VST004',
        name: 'Sneha Iyer',
        mobile: '9012345678',
        email: 'sneha.iyer@gmail.com',
        visitorType: 'Other',
        project: 'Project C',
        purpose: 'Maintenance Check',
        status: 'Checked In',
        createdAt: '${todayStr}T09:45:00',
        checkInTime: '${todayStr}T10:10:00',
        checkOutTime: null,
      ),
      VisitorModel(
        id: 'VST005',
        name: 'Vikram Singh',
        mobile: '8765432109',
        email: 'vikram.singh@vendor.com',
        visitorType: 'Vendor',
        project: 'Project B',
        purpose: 'HVAC Inspection',
        status: 'Registered',
        createdAt: '${todayStr}T10:20:00',
        checkInTime: null,
        checkOutTime: null,
      ),
    ];
  }
}
