import 'package:flutter_test/flutter_test.dart';
import 'package:visitor_mangement_app/core/utils/validators.dart';
import 'package:visitor_mangement_app/data/models/visitor_model.dart';

void main() {
  group('VisitorModel Tests', () {
    test('VisitorModel correctly deserializes and serializes JSON', () {
      final json = {
        'id': 'VST001',
        'name': 'Rahul Sharma',
        'mobile': '9876543210',
        'email': 'rahul@example.com',
        'visitor_type': 'Customer',
        'project': 'Project A',
        'purpose': 'Site Visit',
        'status': 'Registered',
        'created_at': '2026-10-26T10:00:00',
        'check_in_time': null,
        'check_out_time': null,
      };

      final model = VisitorModel.fromJson(json);

      expect(model.id, 'VST001');
      expect(model.name, 'Rahul Sharma');
      expect(model.mobile, '9876543210');
      expect(model.visitorType, 'Customer');
      expect(model.project, 'Project A');
      expect(model.status, 'Registered');
      expect(model.isRegistered, isTrue);
      expect(model.canCheckIn, isTrue);
      expect(model.canCheckOut, isFalse);

      final outputJson = model.toJson();
      expect(outputJson['id'], 'VST001');
      expect(outputJson['name'], 'Rahul Sharma');
      expect(outputJson['visitor_type'], 'Customer');
    });

    test('Visitor status workflow conditions', () {
      const registered = VisitorModel(
        id: 'VST001',
        name: 'Test',
        mobile: '1234567890',
        visitorType: 'Customer',
        project: 'Project A',
        purpose: 'Test',
        status: 'Registered',
        createdAt: '2026-10-26T10:00:00',
      );
      expect(registered.canCheckIn, isTrue);
      expect(registered.canCheckOut, isFalse);

      final checkedIn = registered.copyWith(status: 'Checked In', checkInTime: '2026-10-26T10:30:00');
      expect(checkedIn.canCheckIn, isFalse);
      expect(checkedIn.canCheckOut, isTrue);

      final checkedOut = checkedIn.copyWith(status: 'Checked Out', checkOutTime: '2026-10-26T11:30:00');
      expect(checkedOut.canCheckIn, isFalse);
      expect(checkedOut.canCheckOut, isFalse);
    });
  });

  group('Validators Tests', () {
    test('validateName validates minimum length and non-empty', () {
      expect(Validators.validateName(''), isNotNull);
      expect(Validators.validateName('A'), isNotNull);
      expect(Validators.validateName('Aarav'), isNull);
    });

    test('validateMobile requires exactly 10 digits', () {
      expect(Validators.validateMobile(''), isNotNull);
      expect(Validators.validateMobile('12345'), isNotNull);
      expect(Validators.validateMobile('abcdefghij'), isNotNull);
      expect(Validators.validateMobile('98765432101'), isNotNull);
      expect(Validators.validateMobile('9876543210'), isNull);
    });

    test('validateEmail allows empty optional or validates format', () {
      expect(Validators.validateEmail(''), isNull);
      expect(Validators.validateEmail(null), isNull);
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail('user@test.com'), isNull);
    });
  });
}
