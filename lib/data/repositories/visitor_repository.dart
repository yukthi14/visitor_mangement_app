import '../datasources/visitor_local_datasource.dart';
import '../datasources/visitor_remote_datasource.dart';
import '../models/visitor_model.dart';

abstract class VisitorRepository {
  Future<List<VisitorModel>> getVisitors();
  Future<VisitorModel?> getVisitorById(String id);
  Future<VisitorModel> registerVisitor({
    required String name,
    required String mobile,
    String? email,
    required String visitorType,
    required String project,
    required String purpose,
  });
  Future<VisitorModel> updateVisitor(VisitorModel visitor);
  Future<VisitorModel> checkInVisitor(String id);
  Future<VisitorModel> checkOutVisitor(String id);
  Future<void> deleteVisitor(String id);
  Future<String> getBaseUrl();
  Future<void> setBaseUrl(String url);
}

class VisitorRepositoryImpl implements VisitorRepository {
  final VisitorRemoteDataSource remoteDataSource;
  final VisitorLocalDataSource localDataSource;

  VisitorRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<String> getBaseUrl() async {
    return await localDataSource.getBaseUrl();
  }

  @override
  Future<void> setBaseUrl(String url) async {
    await localDataSource.saveBaseUrl(url);
  }

  @override
  Future<List<VisitorModel>> getVisitors() async {
    final baseUrl = await getBaseUrl();
    try {
      final remoteList = await remoteDataSource.getVisitors(baseUrl);
      if (remoteList.isNotEmpty) {
        await localDataSource.cacheVisitors(remoteList);
        return remoteList;
      }
    } catch (_) {}
    // Return cached visitors smoothly
    return await localDataSource.getCachedVisitors();
  }

  @override
  Future<VisitorModel?> getVisitorById(String id) async {
    final baseUrl = await getBaseUrl();
    try {
      final remoteVisitor = await remoteDataSource.getVisitorById(baseUrl, id);
      if (remoteVisitor != null) {
        await localDataSource.saveVisitorLocally(remoteVisitor);
        return remoteVisitor;
      }
    } catch (_) {}
    return await localDataSource.getVisitorById(id);
  }

  @override
  Future<VisitorModel> registerVisitor({
    required String name,
    required String mobile,
    String? email,
    required String visitorType,
    required String project,
    required String purpose,
  }) async {
    final baseUrl = await getBaseUrl();
    final cached = await localDataSource.getCachedVisitors();

    // Generate formatted ID like VST001, VST002...
    int maxIdNum = 0;
    for (final v in cached) {
      final digits = v.id.replaceAll(RegExp(r'[^0-9]'), '');
      final parsed = int.tryParse(digits);
      if (parsed != null && parsed > maxIdNum) {
        maxIdNum = parsed;
      }
    }
    final nextNumber = (maxIdNum + 1).toString().padLeft(3, '0');
    final newId = 'VST$nextNumber';
    final nowIso = DateTime.now().toIso8601String();

    final newVisitor = VisitorModel(
      id: newId,
      name: name.trim(),
      mobile: mobile.trim(),
      email: email != null && email.trim().isNotEmpty ? email.trim() : null,
      visitorType: visitorType,
      project: project,
      purpose: purpose.trim(),
      status: 'Registered',
      createdAt: nowIso,
      checkInTime: null,
      checkOutTime: null,
    );

    // Save locally first so data is guaranteed persistent
    await localDataSource.saveVisitorLocally(newVisitor);

    try {
      final created = await remoteDataSource.createVisitor(baseUrl, newVisitor);
      if (created != null) {
        await localDataSource.saveVisitorLocally(created);
        return created;
      }
    } catch (_) {}
    return newVisitor;
  }

  @override
  Future<VisitorModel> updateVisitor(VisitorModel visitor) async {
    final baseUrl = await getBaseUrl();
    // Update locally
    await localDataSource.saveVisitorLocally(visitor);

    try {
      final updated = await remoteDataSource.updateVisitor(baseUrl, visitor);
      if (updated != null) {
        await localDataSource.saveVisitorLocally(updated);
        return updated;
      }
    } catch (_) {}
    return visitor;
  }

  @override
  Future<VisitorModel> checkInVisitor(String id) async {
    final baseUrl = await getBaseUrl();
    final nowIso = DateTime.now().toIso8601String();

    // Check existing
    final existing = await localDataSource.getVisitorById(id);
    if (existing == null) {
      throw Exception('Visitor $id not found');
    }
    if (existing.status == 'Checked In') {
      throw Exception('Visitor is already checked in');
    }
    if (existing.status == 'Checked Out') {
      throw Exception('Completed visits cannot be checked in again');
    }

    final updatedModel = existing.copyWith(
      status: 'Checked In',
      checkInTime: nowIso,
    );

    await localDataSource.saveVisitorLocally(updatedModel);

    try {
      final remoteUpdated = await remoteDataSource.updateVisitorStatus(
        baseUrl,
        id,
        'Checked In',
        nowIso,
        null,
      );
      if (remoteUpdated != null) {
        await localDataSource.saveVisitorLocally(remoteUpdated);
        return remoteUpdated;
      }
    } catch (_) {}
    return updatedModel;
  }

  @override
  Future<VisitorModel> checkOutVisitor(String id) async {
    final baseUrl = await getBaseUrl();
    final nowIso = DateTime.now().toIso8601String();

    // Check existing
    final existing = await localDataSource.getVisitorById(id);
    if (existing == null) {
      throw Exception('Visitor $id not found');
    }
    if (existing.status == 'Registered') {
      throw Exception('Visitor must check in before checking out');
    }
    if (existing.status == 'Checked Out') {
      throw Exception('Visitor is already checked out');
    }

    final updatedModel = existing.copyWith(
      status: 'Checked Out',
      checkOutTime: nowIso,
    );

    await localDataSource.saveVisitorLocally(updatedModel);

    try {
      final remoteUpdated = await remoteDataSource.updateVisitorStatus(
        baseUrl,
        id,
        'Checked Out',
        null,
        nowIso,
      );
      if (remoteUpdated != null) {
        await localDataSource.saveVisitorLocally(remoteUpdated);
        return remoteUpdated;
      }
    } catch (_) {}
    return updatedModel;
  }

  @override
  Future<void> deleteVisitor(String id) async {
    final baseUrl = await getBaseUrl();
    await localDataSource.deleteVisitorLocally(id);

    try {
      await remoteDataSource.deleteVisitor(baseUrl, id);
    } catch (_) {}
  }
}
