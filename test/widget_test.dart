import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitor_mangement_app/core/utils/validators.dart';
import 'package:visitor_mangement_app/core/widgets/custom_text_field.dart';
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

  testWidgets('CustomTextField with digitsOnly filters out non-digit characters', (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            label: 'Mobile Number',
            hintText: 'Enter 10 digit mobile number',
            controller: controller,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: Validators.validateMobile,
          ),
        ),
      ),
    );

    // Try entering letters and numbers
    await tester.enterText(find.byType(TextFormField), '987abc654!@#');
    await tester.pump();

    // Digits only formatter must strip 'abc' and '!@#'
    expect(controller.text, '987654');

    // Enter full 10-digit number
    await tester.enterText(find.byType(TextFormField), '9876543210');
    await tester.pump();
    expect(controller.text, '9876543210');
  });

  testWidgets('CustomTextField with validateEmail validates format on user interaction', (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            autovalidateMode: AutovalidateMode.always,
            child: CustomTextField(
              label: 'Email',
              hintText: 'Enter email address',
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
          ),
        ),
      ),
    );

    // Enter invalid email
    await tester.enterText(find.byType(TextFormField), 'invalid-email');
    await tester.pump();
    expect(find.text('Please enter a valid email address'), findsOneWidget);

    // Enter valid email - error disappears and input is accepted
    await tester.enterText(find.byType(TextFormField), 'user@example.com');
    await tester.pump();
    expect(find.text('Please enter a valid email address'), findsNothing);
    expect(controller.text, 'user@example.com');
  });
}
