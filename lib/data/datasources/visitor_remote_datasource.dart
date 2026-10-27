import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/visitor_model.dart';

abstract class VisitorRemoteDataSource {
  Future<List<VisitorModel>> getVisitors(String baseUrl);
  Future<VisitorModel> getVisitorById(String baseUrl, String id);
  Future<VisitorModel> createVisitor(String baseUrl, VisitorModel visitor);
  Future<VisitorModel> updateVisitor(String baseUrl, VisitorModel visitor);
  Future<VisitorModel> updateVisitorStatus(
    String baseUrl,
    String id,
    String status,
    String? checkInTime,
    String? checkOutTime,
  );
  Future<void> deleteVisitor(String baseUrl, String id);
}

class VisitorRemoteDataSourceImpl implements VisitorRemoteDataSource {
  final http.Client client;

  VisitorRemoteDataSourceImpl({required this.client});

  String _cleanUrl(String baseUrl, String path) {
    var url = baseUrl.trim();
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return '$url$path';
  }

  @override
  Future<List<VisitorModel>> getVisitors(String baseUrl) async {
    final uri = Uri.parse(_cleanUrl(baseUrl, ApiConstants.visitorsEndpoint));
    final response = await client
        .get(uri, headers: {'Content-Type': 'application/json'})
        .timeout(ApiConstants.connectTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList.map((item) => VisitorModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load visitors (Status: ${response.statusCode})');
    }
  }

  @override
  Future<VisitorModel> getVisitorById(String baseUrl, String id) async {
    final uri = Uri.parse(_cleanUrl(baseUrl, '${ApiConstants.visitorsEndpoint}/$id'));
    final response = await client
        .get(uri, headers: {'Content-Type': 'application/json'})
        .timeout(ApiConstants.connectTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return VisitorModel.fromJson(data);
    } else {
      throw Exception('Visitor not found (Status: ${response.statusCode})');
    }
  }

  @override
  Future<VisitorModel> createVisitor(String baseUrl, VisitorModel visitor) async {
    final uri = Uri.parse(_cleanUrl(baseUrl, ApiConstants.visitorsEndpoint));
    final body = jsonEncode(visitor.toJson());

    final response = await client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(ApiConstants.connectTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return VisitorModel.fromJson(data);
    } else {
      throw Exception('Failed to create visitor (Status: ${response.statusCode})');
    }
  }

  @override
  Future<VisitorModel> updateVisitor(String baseUrl, VisitorModel visitor) async {
    final uri = Uri.parse(_cleanUrl(baseUrl, '${ApiConstants.visitorsEndpoint}/${visitor.id}'));
    final body = jsonEncode(visitor.toJson());

    final response = await client
        .put(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(ApiConstants.connectTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return VisitorModel.fromJson(data);
    } else {
      throw Exception('Failed to update visitor (Status: ${response.statusCode})');
    }
  }

  @override
  Future<VisitorModel> updateVisitorStatus(
    String baseUrl,
    String id,
    String status,
    String? checkInTime,
    String? checkOutTime,
  ) async {
    final uri = Uri.parse(_cleanUrl(baseUrl, '${ApiConstants.visitorsEndpoint}/$id'));
    final Map<String, dynamic> updatePayload = {'status': status};
    if (checkInTime != null) {
      updatePayload['check_in_time'] = checkInTime;
    }
    if (checkOutTime != null) {
      updatePayload['check_out_time'] = checkOutTime;
    }

    final response = await client
        .patch(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updatePayload),
        )
        .timeout(ApiConstants.connectTimeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return VisitorModel.fromJson(data);
    } else {
      // Some mock servers prefer PUT if PATCH is not supported
      final fallbackResponse = await client
          .put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(updatePayload),
          )
          .timeout(ApiConstants.connectTimeout);

      if (fallbackResponse.statusCode >= 200 && fallbackResponse.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(fallbackResponse.body) as Map<String, dynamic>;
        return VisitorModel.fromJson(data);
      }
      throw Exception('Failed to update visit status (Status: ${response.statusCode})');
    }
  }

  @override
  Future<void> deleteVisitor(String baseUrl, String id) async {
    final uri = Uri.parse(_cleanUrl(baseUrl, '${ApiConstants.visitorsEndpoint}/$id'));
    final response = await client
        .delete(uri, headers: {'Content-Type': 'application/json'})
        .timeout(ApiConstants.connectTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete visitor (Status: ${response.statusCode})');
    }
  }
}
