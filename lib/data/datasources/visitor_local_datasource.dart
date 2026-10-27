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
    // One-time purge of old mock sample demo data from prior runs
    final isCleaned = sharedPreferences.getBool(AppConstants.prefSampleDataCleaned) ?? false;
    if (!isCleaned) {
      await sharedPreferences.remove(AppConstants.prefCachedVisitors);
      await sharedPreferences.setBool(AppConstants.prefSampleDataCleaned, true);
      return [];
    }

    final rawJson = sharedPreferences.getString(AppConstants.prefCachedVisitors);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded.map((item) => VisitorModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
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
}
