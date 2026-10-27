import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visitor_mangement_app/core/widgets/status_chip.dart';

void main() {
  testWidgets('StatusChip renders correct status text and style', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusChip(status: 'Checked In'),
        ),
      ),
    );

    expect(find.text('Checked In'), findsOneWidget);
  });
}
