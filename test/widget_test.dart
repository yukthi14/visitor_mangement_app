import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitor_mangement_app/core/widgets/shimmer_loading.dart';
import 'package:visitor_mangement_app/core/widgets/status_chip.dart';
import 'package:visitor_mangement_app/logic/blocs/auth/auth_bloc.dart';
import 'package:visitor_mangement_app/presentation/screens/auth/login_screen.dart';

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

  testWidgets('VisitorListShimmer renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VisitorListShimmer(),
        ),
      ),
    );

    expect(find.byType(VisitorListShimmer), findsOneWidget);
    expect(find.byType(VisitorCardShimmer), findsWidgets);
  });

  testWidgets('DashboardShimmer renders stat cards and placeholders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DashboardShimmer(),
        ),
      ),
    );

    expect(find.byType(DashboardShimmer), findsOneWidget);
  });

  testWidgets('LoginScreen displays field errors below inputs and no SnackBar', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(sharedPreferences: sharedPrefs),
          ),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify Remember me checkbox is removed
    expect(find.byType(Checkbox), findsNothing);
    expect(find.text('Remember me'), findsNothing);

    // Tap Login without entering username or password
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify error is shown below field, and NO SnackBar is shown
    expect(find.text('Please enter your username'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    // Enter username and weak password without uppercase
    await tester.enterText(find.byType(TextField).at(0), 'admin');
    await tester.enterText(find.byType(TextField).at(1), 'weakpass1@');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Password validation requires uppercase
    expect(find.text('Password must contain at least one uppercase letter'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });
}
