import 'package:flutter_test/flutter_test.dart';

import 'package:admin_app/app.dart';

void main() {
  testWidgets('Admin app shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AdminApp());
    await tester.pumpAndSettle();

    expect(find.text('HydroAlert Admin Login'), findsOneWidget);
    expect(find.text('Remember Me'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
